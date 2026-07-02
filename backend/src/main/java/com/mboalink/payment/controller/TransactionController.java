package com.mboalink.payment.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.payment.dto.TransactionRequestDTO;
import com.mboalink.payment.dto.TransactionResponseDTO;
import com.mboalink.payment.service.TransactionService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/v1/transactions")
@RequiredArgsConstructor
@Slf4j
public class TransactionController {

    private final TransactionService transactionService;
    private final UtilisateurRepository utilisateurRepository;
    
    /**
     * POST /api/v1/transactions
     * Initiate a new payment transaction
     */
    @PostMapping
    public ResponseEntity<?> createTransaction(
            @Valid @RequestBody TransactionRequestDTO request,
            Authentication authentication) {
        log.info("Création transaction - Type: {}, Montant: {}", request.getTypeTransaction(), request.getMontant());

        try {
            // Get authenticated user
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            // Create transaction
            TransactionResponseDTO response = transactionService.createTransaction(utilisateur, request);

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Paiement lancé. Vérifiez votre téléphone.");
            result.put("data", response);

            return ResponseEntity.status(HttpStatus.CREATED).body(result);
        } catch (Exception e) {
            log.error("Erreur création transaction: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    /**
     * GET /api/v1/transactions/{transactionId}
     * Get transaction status
     */
    @GetMapping("/{transactionId}")
    public ResponseEntity<?> getTransaction(
            @PathVariable UUID transactionId,
            Authentication authentication) {
        log.info("Récupération transaction: {}", transactionId);

        try {
            TransactionResponseDTO response = transactionService.getTransaction(transactionId);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", response
            ));
        } catch (Exception e) {
            log.error("Erreur récupération transaction: ", e);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "success", false,
                    "message", "Transaction non trouvée"
            ));
        }
    }

    /**
     * GET /api/v1/transactions/user/history
     * Get all transactions for authenticated user
     */
    @GetMapping("/user/history")
    public ResponseEntity<?> getUserTransactions(Authentication authentication) {
        log.info("Récupération historique transactions utilisateur");

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
            List<TransactionResponseDTO> responses = transactionService.getUserTransactions(utilisateur);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "count", responses.size(),
                    "data", responses
            ));
        } catch (Exception e) {
            log.error("Erreur récupération historique: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "success", false,
                    "message", "Erreur lors de la récupération de l'historique des transactions"
            ));
        }
    }

    /**
     * GET /api/v1/transactions/user/successful
     * Get only successful transactions
     */
    @GetMapping("/user/successful")
    public ResponseEntity<?> getSuccessfulTransactions(Authentication authentication) {
        log.info("Récupération transactions réussies");

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
            List<TransactionResponseDTO> responses = transactionService.getSuccessfulTransactions(utilisateur);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "count", responses.size(),
                    "data", responses
            ));
        } catch (Exception e) {
            log.error("Erreur récupération transactions réussies: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "success", false,
                    "message", "Erreur lors de la récupération des transactions réussies"
            ));
        }
    }

    /**
     * POST /api/v1/transactions/{referenceExterne}/confirm
     * Confirm payment (webhook endpoint for Mobile Money providers)
     */
    @PostMapping("/{referenceExterne}/confirm")
    public ResponseEntity<?> confirmPayment(
            @PathVariable String referenceExterne,
            @RequestParam String newStatut) {
        log.info("Confirmation paiement: {} -> {}", referenceExterne, newStatut);

        try {
            transactionService.confirmPayment(referenceExterne, newStatut);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Paiement confirmé"
            ));
        } catch (Exception e) {
            log.error("Erreur confirmation paiement: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }
}