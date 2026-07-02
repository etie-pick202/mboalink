package com.mboalink.payment.service;

import com.mboalink.auth.entity.Utilisateur;
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
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class TransactionService {

    private final TransactionRepository transactionRepository;

    /**
     * Create a transaction
     */
    public TransactionResponseDTO createTransaction(Utilisateur utilisateur, TransactionRequestDTO request) {
        log.info("[TRANSACTION] Création transaction pour utilisateur: {} | Type: {}", 
            utilisateur.getId(), request.getTypeTransaction());

        Transaction transaction = Transaction.builder()
                .utilisateur(utilisateur)
                .typeTransaction(request.getTypeTransaction())
                .montant(request.getMontant())
                .devise(request.getDevise())
                .operateur(request.getOperateur())
                .numeroTelephonePaiement(request.getNumeroTelephonePaiement())
                .referenceExterne(request.getReferenceExterne())
                .statut("EN_ATTENTE")
                .description(request.getDescription())
                .creeLe(LocalDateTime.now())
                .build();

        Transaction saved = transactionRepository.save(transaction);
        log.info("[TRANSACTION] Transaction créée: {}", saved.getId());

        return mapToResponseDTO(saved);
    }

    /**
     * Confirm payment success
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
     * Get transaction by ID
     */
    public TransactionResponseDTO getTransaction(UUID transactionId) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));
        return mapToResponseDTO(transaction);
    }

    /**
     * Get all transactions for a user
     */
    public List<TransactionResponseDTO> getUserTransactions(Utilisateur utilisateur) {
        return transactionRepository.findByUtilisateur(utilisateur).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get successful transactions only
     */
    public List<TransactionResponseDTO> getSuccessfulTransactions(Utilisateur utilisateur) {
        return transactionRepository.findSuccessfulTransactionsByUser(utilisateur).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Retry pending transactions (scheduled job)
     */
    public void retryPendingTransactions() {
        log.info("[TRANSACTION] Retry pending transactions...");
        LocalDateTime cutoffTime = LocalDateTime.now().minusMinutes(15);
        List<Transaction> pendingTransactions = transactionRepository.findPendingTransactionsForRetry(cutoffTime);

        log.info("[TRANSACTION] Found {} pending transactions to retry", pendingTransactions.size());
    }

    /**
     * Map Entity to DTO
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