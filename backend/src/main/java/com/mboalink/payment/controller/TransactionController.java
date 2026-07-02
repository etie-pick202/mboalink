package com.mboalink.payment.controller;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.payment.dto.TransactionRequestDTO;
import com.mboalink.payment.dto.TransactionResponseDTO;
import com.mboalink.payment.entity.Transaction;
import com.mboalink.payment.repository.TransactionRepository;
import com.mboalink.payment.service.TransactionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/transactions")
@RequiredArgsConstructor
@Slf4j
public class TransactionController {

    private final TransactionService transactionService;
    private final TransactionRepository transactionRepository;
    private final UtilisateurRepository utilisateurRepository;

    /**
     * Créer une nouvelle transaction et initier paiement Campay
     */
    @PostMapping
    public ResponseEntity<?> createTransaction(
            @Valid @RequestBody TransactionRequestDTO request,
            Authentication authentication) {
        log.info("[TRANSACTION] Création transaction - Type: {}, Montant: {}",
                request.getTypeTransaction(), request.getMontant());

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            Map<String, Object> result = transactionService.createTransaction(utilisateur, request);

            boolean success = (Boolean) result.getOrDefault("success", false);
            return success
                    ? ResponseEntity.status(HttpStatus.CREATED).body(result)
                    : ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);

        } catch (Exception e) {
            log.error("[TRANSACTION] Erreur création transaction: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", "Erreur: " + e.getMessage()
            ));
        }
    }

    /**
     * Récupérer historique des transactions de l'utilisateur
     */
    @GetMapping("/user/history")
    public ResponseEntity<?> getUserTransactionHistory(Authentication authentication) {
        log.info("[TRANSACTION] Récupération historique transactions");

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            var transactions = transactionService.getUserTransactions(utilisateur);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "count", transactions.size(),
                    "data", transactions
            ));

        } catch (Exception e) {
            log.error("[TRANSACTION] Erreur récupération historique: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "success", false,
                    "message", "Erreur récupération historique transactions"
            ));
        }
    }

    /**
     * Récupérer les transactions réussies de l'utilisateur
     */
    @GetMapping("/user/successful")
    public ResponseEntity<?> getSuccessfulTransactions(Authentication authentication) {
        log.info("[TRANSACTION] Récupération transactions réussies");

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            var transactions = transactionService.getSuccessfulTransactions(utilisateur);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "count", transactions.size(),
                    "data", transactions
            ));

        } catch (Exception e) {
            log.error("[TRANSACTION] Erreur récupération transactions réussies: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "success", false,
                    "message", "Erreur récupération transactions réussies"
            ));
        }
    }

    /**
     * Vérifier le statut d'une transaction Campay
     */
    @GetMapping("/{transactionId}/status")
    public ResponseEntity<?> checkTransactionStatus(
            @PathVariable UUID transactionId,
            Authentication authentication) {
        log.info("[TRANSACTION] Vérification statut transaction: {}", transactionId);

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            Transaction transaction = transactionRepository.findById(transactionId)
                    .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));

            if (!transaction.getUtilisateur().getId().equals(utilisateur.getId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of(
                        "success", false,
                        "message", "Accès non autorisé"
                ));
            }

            // Use Campay reference to check status
            if (transaction.getReferenceExterne() == null) {
                return ResponseEntity.ok(Map.of(
                        "success", false,
                        "message", "Aucune référence de paiement trouvée",
                        "statut", transaction.getStatut()
                ));
            }

            Map<String, Object> statusResult = transactionService.checkPaymentStatus(
                    transaction.getReferenceExterne());

            return ResponseEntity.ok(statusResult);

        } catch (Exception e) {
            log.error("[TRANSACTION] Erreur vérification statut: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "success", false,
                    "message", "Erreur vérification statut"
            ));
        }
    }

    /**
     * Récupérer une transaction par ID
     */
    @GetMapping("/{transactionId}")
    public ResponseEntity<?> getTransaction(
            @PathVariable UUID transactionId,
            Authentication authentication) {
        log.info("[TRANSACTION] Récupération transaction: {}", transactionId);

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            Transaction transaction = transactionRepository.findById(transactionId)
                    .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));

            if (!transaction.getUtilisateur().getId().equals(utilisateur.getId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of(
                        "success", false,
                        "message", "Accès non autorisé"
                ));
            }

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", transactionService.getTransaction(transactionId)
            ));

        } catch (Exception e) {
            log.error("[TRANSACTION] Erreur récupération transaction: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "success", false,
                    "message", "Erreur récupération transaction"
            ));
        }
    }
}