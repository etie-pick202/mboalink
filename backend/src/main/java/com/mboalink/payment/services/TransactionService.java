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
    private final MobileMoneyService mobileMoneyService;

    /**
     * Create and initiate a payment transaction
     */
    public TransactionResponseDTO createTransaction(Utilisateur utilisateur, TransactionRequestDTO request) {
        log.info("Création transaction pour utilisateur: {} | Type: {}", utilisateur.getId(), request.getTypeTransaction());

        Transaction transaction = Transaction.builder()
                .utilisateur(utilisateur)
                .typeTransaction(request.getTypeTransaction())
                .montant(request.getMontant())
                .devise(request.getDevise())
                .operateur(request.getOperateur()) // MTN_MOMO ou ORANGE_MONEY
                .numeroTelephonePaiement(request.getNumeroTelephonePaiement())
                .referenceExterne(request.getReferenceExterne())
                .statut("EN_ATTENTE")
                .description(request.getDescription())
                .creeLe(LocalDateTime.now())
                .build();

        Transaction saved = transactionRepository.save(transaction);

        // Initiate payment with Mobile Money provider
        try {
            if ("MTN_MOMO".equals(request.getOperateur())) {
                mobileMoneyService.initiatePaymentMTN(saved);
            } else if ("ORANGE_MONEY".equals(request.getOperateur())) {
                mobileMoneyService.initiatePaymentOrange(saved);
            }
        } catch (Exception e) {
            log.error("Erreur initiation paiement: ", e);
            saved.setStatut("ECHEC");
            transactionRepository.save(saved);
        }

        return mapToResponseDTO(saved);
    }

    /**
     * Confirm payment success (called by webhook from Mobile Money)
     */
    public void confirmPayment(String referenceExterne, String newStatut) {
        log.info("Confirmation paiement: {}", referenceExterne);

        Transaction transaction = transactionRepository.findByReferenceExterne(referenceExterne)
                .orElseThrow(() -> new RuntimeException("Transaction not found: " + referenceExterne));

        transaction.setStatut(newStatut); // SUCCES ou ECHEC
        transaction.setTraiteLe(LocalDateTime.now());
        transactionRepository.save(transaction);

        log.info("Transaction {} mise à jour: {}", transaction.getId(), newStatut);
    }

    /**
     * Get transaction by ID
     */
    public TransactionResponseDTO getTransaction(UUID transactionId) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
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
     * Retry pending transactions (for scheduled job)
     */
    public void retryPendingTransactions() {
        log.info("Retry pending transactions...");
        LocalDateTime cutoffTime = LocalDateTime.now().minusMinutes(15);
        List<Transaction> pendingTransactions = transactionRepository.findPendingTransactionsForRetry(cutoffTime);

        for (Transaction tx : pendingTransactions) {
            try {
                if ("MTN_MOMO".equals(tx.getOperateur())) {
                    mobileMoneyService.checkPaymentStatusMTN(tx);
                } else if ("ORANGE_MONEY".equals(tx.getOperateur())) {
                    mobileMoneyService.checkPaymentStatusOrange(tx);
                }
            } catch (Exception e) {
                log.error("Erreur retry transaction {}: ", tx.getId(), e);
            }
        }
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
