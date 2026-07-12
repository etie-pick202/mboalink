package com.mboalink.payment.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.grossiste.entity.DeverrouillageCoordonnees;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.DeverrouillageCoordonneesRepository;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.notification.service.NotificationService;
import com.mboalink.payment.dto.MobileMoneyRequestDTO;
import com.mboalink.payment.entity.Transaction;
import com.mboalink.payment.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class CampayPaymentService {

    private final TransactionRepository transactionRepository;
    private final RestTemplate restTemplate;
    private final RecuService recuService;
    private final DeverrouillageCoordonneesRepository deverrouillageRepository;
    private final FicheGrossisteRepository ficheGrossisteRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final NotificationService notificationService;

    @Value("${campay.base.url}")
    private String campayBaseUrl;

    @Value("${campay.access.token}")
    private String campayAccessToken;

    @Value("${campay.webhook.url}")
    private String campayWebhookUrl;

    @Value("${campay.redirect.url}")
    private String campayRedirectUrl;

    // Phase de test : l'environnement démo Campay rejette les montants élevés
    // (max ~25 FCFA). On plafonne uniquement le montant transmis à Campay ;
    // la transaction, le reçu et l'affichage conservent le vrai montant.
    @Value("${campay.test.mode:false}")
    private boolean campayTestMode;

    @Value("${campay.test.max-amount:25}")
    private int campayTestMaxAmount;

    /**
     * Initiate a mobile money collection request via Campay
     */
    public Map<String, Object> initiatePayment(Transaction transaction, MobileMoneyRequestDTO request) {
        log.info("[CAMPAY] Initiation paiement - Transaction: {}", transaction.getId());

        try {
            Map<String, Object> campayRequest = buildCollectRequest(transaction, request);
            Map<String, Object> campayResponse = callCampayApi("/collect/", campayRequest);

            if (campayResponse != null && campayResponse.get("reference") != null) {
                String reference = (String) campayResponse.get("reference");
                String status = (String) campayResponse.getOrDefault("status", "PENDING");

                // Update transaction with Campay reference
                transaction.setReferenceExterne(reference);
                transaction.setStatut(mapCampayStatus(status));
                transaction.setTraiteLe(LocalDateTime.now());
                transactionRepository.save(transaction);

                log.info("[CAMPAY] Paiement initié - Référence: {}", reference);

                String instruction = "MTN_MOMO".equals(transaction.getOperateur())
                        ? "Composez *126# sur votre téléphone pour valider le paiement"
                        : "Composez #150*50# sur votre téléphone pour valider le paiement";

                Map<String, Object> result = new java.util.HashMap<>();
                result.put("success", true);
                result.put("message", "Paiement initié avec succès");
                result.put("reference", reference);
                result.put("status", status);
                result.put("transactionId", transaction.getId());
                result.put("ussdCode", campayResponse.getOrDefault("ussd_code", ""));
                result.put("instruction", instruction);
                return result;

            } else {
                String errorMsg = campayResponse != null
                        ? (String) campayResponse.getOrDefault("message", "Erreur Campay inconnue")
                        : "Erreur Campay inconnue";

                transaction.setStatut("ECHEC");
                transaction.setTraiteLe(LocalDateTime.now());
                transactionRepository.save(transaction);

                log.error("[CAMPAY] Erreur: {}", errorMsg);

                return Map.of(
                        "success", false,
                        "message", "Erreur lors de l'initiation du paiement: " + errorMsg,
                        "transactionId", transaction.getId()
                );
            }

        } catch (Exception e) {
            log.error("[CAMPAY] Exception initiation paiement: ", e);
            transaction.setStatut("ECHEC");
            transaction.setTraiteLe(LocalDateTime.now());
            transactionRepository.save(transaction);

            return Map.of(
                    "success", false,
                    "message", "Erreur technique: " + e.getMessage(),
                    "transactionId", transaction.getId()
            );
        }
    }

    /**
     * Check payment status with Campay
     */
    public Map<String, Object> checkPaymentStatus(String reference) {
        log.info("[CAMPAY] Vérification statut - Référence: {}", reference);

        try {
            Map<String, Object> statusResponse = callCampayApiGet("/transaction/" + reference + "/");

            if (statusResponse != null) {
                String status = (String) statusResponse.get("status");
                String mappedStatus = mapCampayStatus(status);

                log.info("[CAMPAY] Statut: {} → {}", status, mappedStatus);

                // Update transaction in DB
                transactionRepository.findByReferenceExterne(reference).ifPresent(transaction -> {
                    transaction.setStatut(mappedStatus);
                    transaction.setTraiteLe(LocalDateTime.now());
                    transactionRepository.save(transaction);

                    if ("SUCCES".equals(mappedStatus)) {
                        recuService.generateReceipt(transaction);
                        log.info("[CAMPAY] Reçu généré pour transaction: {}", transaction.getId());
                        declencherDeverrouillageSiApplicable(transaction);
                        notifierRecuDisponible(transaction);
                    }
                });

                return Map.of(
                        "success", "SUCCES".equals(mappedStatus),
                        "message", getStatusMessage(mappedStatus),
                        "status", mappedStatus,
                        "reference", reference,
                        "data", statusResponse
                );
            }

            return Map.of(
                    "success", false,
                    "message", "Impossible de vérifier le statut du paiement",
                    "reference", reference
            );

        } catch (Exception e) {
            log.error("[CAMPAY] Exception vérification statut: ", e);
            return Map.of(
                    "success", false,
                    "message", "Erreur technique: " + e.getMessage()
            );
        }
    }

    /**
     * Process Campay webhook callback
     */
    public Map<String, Object> processWebhook(Map<String, Object> webhookData) {
        log.info("[CAMPAY] Webhook reçu: {}", webhookData);

        try {
            String reference = (String) webhookData.get("reference");
            String status = (String) webhookData.get("status");
            String mappedStatus = mapCampayStatus(status);

            transactionRepository.findByReferenceExterne(reference).ifPresent(transaction -> {
                transaction.setStatut(mappedStatus);
                transaction.setTraiteLe(LocalDateTime.now());
                transactionRepository.save(transaction);
                log.info("[CAMPAY] Webhook: Transaction {} mise à jour → {}", transaction.getId(), mappedStatus);

                if ("SUCCES".equals(mappedStatus)) {
                    recuService.generateReceipt(transaction);
                    log.info("[CAMPAY] Reçu généré automatiquement pour transaction: {}", transaction.getId());
                    declencherDeverrouillageSiApplicable(transaction);
                    notifierRecuDisponible(transaction);
                }
            });

            return Map.of(
                    "success", true,
                    "message", "Webhook traité avec succès"
            );

        } catch (Exception e) {
            log.error("[CAMPAY] Exception webhook: ", e);
            return Map.of(
                    "success", false,
                    "message", "Erreur traitement webhook: " + e.getMessage()
            );
        }
    }

    private void notifierRecuDisponible(Transaction transaction) {
        notificationService.creer(
                transaction.getUtilisateur(),
                "RECU_PAIEMENT",
                "Reçu de paiement disponible",
                (transaction.getDescription() != null ? transaction.getDescription() : "Paiement") +
                        " · " + transaction.getMontant() + " F",
                transaction.getId().toString()
        );
    }

    /**
     * Déclenche le déverrouillage des coordonnées directement via les repositories
     * (appel interne, pas de JWT disponible dans le contexte webhook).
     */
    private void declencherDeverrouillageSiApplicable(Transaction transaction) {
        if (!"DEVERROUILLAGE_COORDONNEES".equals(transaction.getTypeTransaction())) {
            return;
        }
        if (transaction.getFicheGrossisteId() == null) {
            log.error("[CAMPAY] Transaction {} sans ficheGrossisteId, déverrouillage impossible",
                    transaction.getId());
            return;
        }

        try {
            java.util.UUID utilisateurId = transaction.getUtilisateur().getId();
            java.util.UUID ficheId = transaction.getFicheGrossisteId();

            // Si déjà déverrouillé il y a moins de 24h, ne rien faire
            if (deverrouillageRepository.existsByUtilisateurIdAndFicheGrossisteIdAndDeverrouilleLeAfter(
                    utilisateurId, ficheId, java.time.LocalDateTime.now().minusHours(24))) {
                log.info("[CAMPAY] Coordonnées déjà déverrouillées pour utilisateur: {} fiche: {}",
                        utilisateurId, ficheId);
                return;
            }

            // Récupérer la fiche et l'utilisateur
            FicheGrossiste fiche = ficheGrossisteRepository.findById(ficheId)
                    .orElseThrow(() -> new RuntimeException("Fiche introuvable: " + ficheId));

            Utilisateur utilisateur = utilisateurRepository.findById(utilisateurId)
                    .orElseThrow(() -> new RuntimeException("Utilisateur introuvable: " + utilisateurId));

            // Enregistrer ou renouveler le déverrouillage — un seul
            // enregistrement par (utilisateur, fiche) en base (contrainte
            // unique).
            DeverrouillageCoordonnees deverrouillage = deverrouillageRepository
                    .findByUtilisateurIdAndFicheGrossisteId(utilisateurId, ficheId)
                    .orElseGet(() -> DeverrouillageCoordonnees.builder()
                            .utilisateur(utilisateur)
                            .ficheGrossiste(fiche)
                            .build());
            deverrouillage.setMontantPaye(transaction.getMontant());
            deverrouillage.setReferenceTransaction(transaction.getId().toString());
            deverrouillage.setDeverrouilleLe(java.time.LocalDateTime.now());

            deverrouillageRepository.save(deverrouillage);

            log.info("[CAMPAY] Déverrouillage enregistré - Transaction: {} → Fiche: {}",
                    transaction.getId(), ficheId);

        } catch (Exception e) {
            log.error("[CAMPAY] Erreur déclenchement déverrouillage pour transaction {}: ",
                    transaction.getId(), e);
        }
    }

    /**
     * Build Campay collect request body
     */
    private Map<String, Object> buildCollectRequest(Transaction transaction, MobileMoneyRequestDTO request) {
        Map<String, Object> body = new LinkedHashMap<>();

        int amount = request.getMontant().intValue();
        if (campayTestMode && amount > campayTestMaxAmount) {
            log.warn("[CAMPAY] Mode test : montant {} plafonné à {} FCFA pour transaction {}",
                    amount, campayTestMaxAmount, transaction.getId());
            amount = campayTestMaxAmount;
        }
        body.put("amount", amount);
        body.put("currency", request.getDevise() != null ? request.getDevise() : "XAF");
        body.put("from", formatPhoneNumber(request.getNumeroTelephonePaiement()));
        body.put("description", request.getDescription());
        body.put("external_reference", transaction.getId().toString());
        body.put("redirect_url", campayRedirectUrl);
        return body;
    }

    /**
     * Format phone number for Campay (must start with 237)
     */
    private String formatPhoneNumber(String phoneNumber) {
        String cleaned = phoneNumber.replaceAll("[\\s\\-\\+]", "");
        if (cleaned.startsWith("00")) {
            cleaned = cleaned.substring(2);
        } else if (cleaned.startsWith("0")) {
            cleaned = "237" + cleaned.substring(1);
        }
        if (!cleaned.startsWith("237")) {
            cleaned = "237" + cleaned;
        }
        return cleaned;
    }

    /**
     * Map Campay status to MboaLink internal status
     */
    private String mapCampayStatus(String campayStatus) {
        if (campayStatus == null) return "EN_ATTENTE";
        return switch (campayStatus.toUpperCase()) {
            case "SUCCESSFUL" -> "SUCCES";
            case "FAILED" -> "ECHEC";
            case "PENDING" -> "EN_ATTENTE";
            default -> "EN_ATTENTE";
        };
    }

    /**
     * Get French status message
     */
    private String getStatusMessage(String status) {
        return switch (status) {
            case "SUCCES" -> "Paiement réussi";
            case "ECHEC" -> "Paiement échoué";
            case "EN_ATTENTE" -> "Paiement en attente";
            default -> "Statut inconnu";
        };
    }

    /**
     * POST call to Campay API
     */
    private Map<String, Object> callCampayApi(String endpoint, Map<String, Object> payload) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Token " + campayAccessToken);

            String url = campayBaseUrl + endpoint;
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);

            log.debug("[CAMPAY] POST {} → {}", url, payload);
            ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);
            log.debug("[CAMPAY] Réponse: {}", response.getBody());

            return response.getBody();

        } catch (Exception e) {
            log.error("[CAMPAY] Erreur appel API POST: ", e);
            return null;
        }
    }

    /**
     * GET call to Campay API
     */
    private Map<String, Object> callCampayApiGet(String endpoint) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Token " + campayAccessToken);

            String url = campayBaseUrl + endpoint;
            HttpEntity<Void> entity = new HttpEntity<>(headers);

            log.debug("[CAMPAY] GET {}", url);
            ResponseEntity<Map> response = restTemplate.exchange(
                    url,
                    org.springframework.http.HttpMethod.GET,
                    entity,
                    Map.class
            );
            log.debug("[CAMPAY] Réponse: {}", response.getBody());

            return response.getBody();

        } catch (Exception e) {
            log.error("[CAMPAY] Erreur appel API GET: ", e);
            return null;
        }
    }
}