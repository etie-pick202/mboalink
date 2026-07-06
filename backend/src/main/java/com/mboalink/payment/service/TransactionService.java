package com.mboalink.payment.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.payment.dto.MobileMoneyRequestDTO;
import com.mboalink.payment.dto.TransactionRequestDTO;
import com.mboalink.payment.dto.TransactionResponseDTO;
import com.mboalink.payment.entity.Transaction;
import com.mboalink.payment.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final CampayPaymentService campayPaymentService;

    /**
     * Créer une transaction et initier le paiement via Campay
     */
    public Map<String, Object> createTransaction(Utilisateur utilisateur, TransactionRequestDTO request) {
        log.info("[TRANSACTION] Création transaction pour utilisateur: {} | Type: {}",
                utilisateur.getId(), request.getTypeTransaction());

        Transaction transaction = Transaction.builder()
                .utilisateur(utilisateur)
                .typeTransaction(request.getTypeTransaction())
                .montant(request.getMontant())
                .devise(request.getDevise() != null ? request.getDevise() : "XAF")
                .operateur(request.getOperateur())
                .numeroTelephonePaiement(request.getNumeroTelephonePaiement())
                .referenceExterne(null)
                .statut("EN_ATTENTE")
                .description(request.getDescription())
                .creeLe(LocalDateTime.now())
                .build();

        Transaction saved = transactionRepository.save(transaction);

        // Build DTO for Campay
        MobileMoneyRequestDTO mobileMoneyRequest = MobileMoneyRequestDTO.builder()
                .montant(request.getMontant())
                .operateur(request.getOperateur())
                .numeroTelephonePaiement(request.getNumeroTelephonePaiement())
                .typeTransaction(request.getTypeTransaction())
                .devise(request.getDevise() != null ? request.getDevise() : "XAF")
                .description(request.getDescription())
                .build();

        // Initiate payment via Campay
        Map<String, Object> campayResult = campayPaymentService.initiatePayment(saved, mobileMoneyRequest);

        // Reload updated transaction after Campay call
        Transaction updatedTransaction = transactionRepository.findById(saved.getId()).orElse(saved);

        Map<String, Object> finalResult = new java.util.HashMap<>(campayResult);
        finalResult.put("transaction", mapToResponseDTO(updatedTransaction));
        return finalResult;
    }

    /**
     * Confirmer un paiement (appelé par webhook Campay)
     */
    public void confirmPayment(String referenceExterne, String newStatut) {
        log.info("[TRANSACTION] Confirmation paiement: {}", referenceExterne);

        Transaction transaction = transactionRepository.findByReferenceExterne(referenceExterne)
                .orElseThrow(() -> new RuntimeException("Transaction non trouvée: " + referenceExterne));

        transaction.setStatut(newStatut);
        transaction.setTraiteLe(LocalDateTime.now());
        transactionRepository.save(transaction);

        log.info("[TRANSACTION] Transaction {} mise à jour: {}", transaction.getId(), newStatut);
    }

    /**
     * Vérifier le statut d'un paiement Campay
     */
    public Map<String, Object> checkPaymentStatus(String reference) {
        log.info("[TRANSACTION] Vérification statut paiement: {}", reference);
        return campayPaymentService.checkPaymentStatus(reference);
    }

    /**
     * Récupérer une transaction par ID
     */
    public TransactionResponseDTO getTransaction(UUID transactionId) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));
        return mapToResponseDTO(transaction);
    }

    /**
     * Récupérer toutes les transactions d'un utilisateur
     */
    public List<TransactionResponseDTO> getUserTransactions(Utilisateur utilisateur) {
        return transactionRepository.findByUtilisateur(utilisateur).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Récupérer les transactions réussies d'un utilisateur
     */
    public List<TransactionResponseDTO> getSuccessfulTransactions(Utilisateur utilisateur) {
        return transactionRepository.findSuccessfulTransactionsByUser(utilisateur).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Retry des transactions en attente (scheduled job)
     */
    public void retryPendingTransactions() {
        log.info("[TRANSACTION] Retry transactions en attente...");
        LocalDateTime cutoffTime = LocalDateTime.now().minusMinutes(15);
        List<Transaction> pendingTransactions = transactionRepository.findPendingTransactionsForRetry(cutoffTime);

        for (Transaction tx : pendingTransactions) {
            try {
                if (tx.getReferenceExterne() != null) {
                    campayPaymentService.checkPaymentStatus(tx.getReferenceExterne());
                }
            } catch (Exception e) {
                log.error("[TRANSACTION] Erreur retry transaction {}: ", tx.getId(), e);
            }
        }
    }

    /**
     * Map Entity → DTO
     */
    private TransactionResponseDTO mapToResponseDTO(Transaction transaction) {
        String messageStatut = switch (transaction.getStatut()) {
            case "EN_ATTENTE" -> "Paiement en attente de confirmation";
            case "SUCCES" -> "Paiement réussi";
            case "ECHEC" -> "Paiement échoué";
            case "REMBOURSE" -> "Paiement remboursé";
            default -> "Statut inconnu";
        };

        return TransactionResponseDTO.builder()
                .id(transaction.getId())
                .typeTransaction(transaction.getTypeTransaction())
                .montant(transaction.getMontant())
                .devise(transaction.getDevise())
                .operateur(transaction.getOperateur())
                .numeroTelephonePaiement(transaction.getNumeroTelephonePaiement())
                .referenceExterne(transaction.getReferenceExterne())
                .statut(transaction.getStatut())
                .description(transaction.getDescription())
                .creeLe(transaction.getCreeLe())
                .traiteLe(transaction.getTraiteLe())
                .utilisateurId(transaction.getUtilisateur().getId().toString())
                .messageStatut(messageStatut)
                .build();
    }
}