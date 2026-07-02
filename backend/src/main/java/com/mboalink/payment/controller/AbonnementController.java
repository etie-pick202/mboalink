package com.mboalink.payment.controller;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.payment.dto.AbonnementRequestDTO;
import com.mboalink.payment.dto.AbonnementResponseDTO;
import com.mboalink.payment.entity.Transaction;
import com.mboalink.payment.repository.TransactionRepository;
import com.mboalink.payment.service.AbonnementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/abonnements")
@RequiredArgsConstructor
@Slf4j
public class AbonnementController {

    private final AbonnementService abonnementService;
    private final TransactionRepository transactionRepository;
    private final UtilisateurRepository utilisateurRepository;

    /**
     * POST /api/v1/abonnements
     * Create new subscription after successful payment
     */
    @PostMapping
    public ResponseEntity<?> createSubscription(
            @Valid @RequestBody AbonnementRequestDTO request,
            @RequestParam UUID transactionId,
            Authentication authentication) {
        log.info("Création abonnement - Type: {}", request.getTypeAbonnement());

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            // Get transaction
            Transaction transaction = transactionRepository.findById(transactionId)
                    .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));

            // Verify transaction is successful
            if (!"SUCCES".equals(transaction.getStatut())) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                        "success", false,
                        "message", "La transaction doit être réussie pour créer un abonnement"
                ));
            }

            // Create subscription
            AbonnementResponseDTO response = abonnementService.createSubscription(utilisateur, request, transaction);

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Abonnement créé avec succès");
            result.put("data", response);

            return ResponseEntity.status(HttpStatus.CREATED).body(result);
        } catch (Exception e) {
            log.error("Erreur création abonnement: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    /**
     * GET /api/v1/abonnements/my
     * Get authenticated user's subscription
     */
    @GetMapping("/my")
    public ResponseEntity<?> getMySubscription(Authentication authentication) {
        log.info("Récupération abonnement utilisateur");

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
            AbonnementResponseDTO response = abonnementService.getSubscription(utilisateur);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", response
            ));
        } catch (Exception e) {
            log.error("Erreur récupération abonnement: ", e);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "success", false,
                    "message", "Aucun abonnement actif trouvé"
            ));
        }
    }

    /**
     * POST /api/v1/abonnements/renew
     * Renew subscription after payment
     */
    @PostMapping("/renew")
    public ResponseEntity<?> renewSubscription(
            @RequestParam UUID transactionId,
            Authentication authentication) {
        log.info("Renouvellement abonnement - Transaction: {}", transactionId);

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            // Get transaction
            Transaction transaction = transactionRepository.findById(transactionId)
                    .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));

            // Verify transaction is successful
            if (!"SUCCES".equals(transaction.getStatut())) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                        "success", false,
                        "message", "La transaction doit être réussie pour renouveler l'abonnement"
                ));
            }

            // Renew subscription
            AbonnementResponseDTO response = abonnementService.renewSubscription(utilisateur, transaction);

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Abonnement renouvelé avec succès");
            result.put("data", response);

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("Erreur renouvellement abonnement: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    /**
     * POST /api/v1/abonnements/suspend
     * Suspend subscription (admin or system)
     */
    @PostMapping("/suspend")
    public ResponseEntity<?> suspendSubscription(Authentication authentication) {
        log.info("Suspension abonnement");

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
            abonnementService.suspendSubscription(utilisateur);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Abonnement suspendu"
            ));
        } catch (Exception e) {
            log.error("Erreur suspension abonnement: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    /**
     * GET /api/v1/abonnements/expiring
     * Get subscriptions expiring soon (for notifications)
     */
    @GetMapping("/admin/expiring")
    public ResponseEntity<?> getExpiringSubscriptions() {
        log.info("Récupération abonnements expirant bientôt");

        try {
            var subscriptions = abonnementService.getExpiringSubscriptions();

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "count", subscriptions.size(),
                    "data", subscriptions
            ));
        } catch (Exception e) {
            log.error("Erreur récupération abonnements expirant: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "success", false,
                    "message", "Erreur lors de la récupération des abonnements expirant"
            ));
        }
    }
}
