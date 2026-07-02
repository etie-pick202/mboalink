package com.mboalink.payment.service;

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

    @Value("${campay.base.url}")
    private String campayBaseUrl;

    @Value("${campay.access.token}")
    private String campayAccessToken;

    @Value("${campay.webhook.url}")
    private String campayWebhookUrl;

    @Value("${campay.redirect.url}")
    private String campayRedirectUrl;

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

                return Map.of(
                        "success", true,
                        "message", "Paiement initié avec succès",
                        "reference", reference,
                        "status", status,
                        "transactionId", transaction.getId()
                );

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

    /**
     * Build Campay collect request body
     */
    private Map<String, Object> buildCollectRequest(Transaction transaction, MobileMoneyRequestDTO request) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("amount", request.getMontant().intValue()); // Campay doesn't allow decimals
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