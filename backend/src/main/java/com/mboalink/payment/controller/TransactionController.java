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
     * Créer une nouvelle transaction
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

            TransactionResponseDTO transactionResponse = transactionService.createTransaction(utilisateur, request);

            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                    "success", true,
                    "message", "Transaction créée avec succès",
                    "data", transactionResponse
            ));

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

            // Verify ownership
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

    /**
     * Confirmer une transaction après paiement réussi
     */
    @PostMapping("/{transactionId}/confirm")
    public ResponseEntity<?> confirmTransaction(
            @PathVariable UUID transactionId,
            Authentication authentication) {
        log.info("[TRANSACTION] Confirmation transaction: {}", transactionId);

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

            transactionService.confirmPayment(transaction.getReferenceExterne(), "SUCCES");

            Transaction updatedTransaction = transactionRepository.findById(transactionId)
                    .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Transaction confirmée",
                    "data", transactionService.getTransaction(updatedTransaction.getId())
            ));

        } catch (Exception e) {
            log.error("[TRANSACTION] Erreur confirmation: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", "Erreur confirmation transaction"
            ));
        }
    }
}