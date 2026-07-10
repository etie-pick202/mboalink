package com.mboalink.payment.service;

import com.mboalink.payment.dto.RecuResponseDTO;
import com.mboalink.payment.entity.Recu;
import com.mboalink.payment.entity.Transaction;
import com.mboalink.payment.repository.RecuRepository;
import com.mboalink.payment.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class RecuService {

    private final RecuRepository recuRepository;
    private final TransactionRepository transactionRepository;

    /**
     * Generate receipt after successful payment
     */
    public RecuResponseDTO generateReceipt(Transaction transaction) {
        log.info("Génération reçu pour transaction: {}", transaction.getId());

        // Check if receipt already exists
        if (recuRepository.findByTransaction(transaction).isPresent()) {
            log.warn("Reçu déjà existant pour transaction: {}", transaction.getId());
            return mapToResponseDTO(recuRepository.findByTransaction(transaction).get());
        }

        // Generate unique receipt number: RCP-YYYYMMDD-XXXXX
        String numeroRecu = generateReceiptNumber();

        Recu recu = Recu.builder()
                .transaction(transaction)
                .numeroRecu(numeroRecu)
                .montantTotal(transaction.getMontant())
                .urlPdf(null) // Will be generated asynchronously
                .creeLe(LocalDateTime.now())
                .build();

        Recu saved = recuRepository.save(recu);
        log.info("Reçu généré: {} | Numéro: {}", saved.getId(), numeroRecu);

        // Trigger async PDF generation
        generateReceiptPdfAsync(saved);

        return mapToResponseDTO(saved);
    }

    /**
     * Get receipt by number
     */
    public RecuResponseDTO getReceiptByNumber(String numeroRecu) {
        Recu recu = recuRepository.findByNumeroRecu(numeroRecu)
                .orElseThrow(() -> new RuntimeException("Reçu non trouvé: " + numeroRecu));
        return mapToResponseDTO(recu);
    }

    /**
     * Get receipt by transaction
     */
    public RecuResponseDTO getReceiptByTransaction(UUID transactionId) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));

        Recu recu = recuRepository.findByTransaction(transaction)
                .orElseThrow(() -> new RuntimeException("Reçu non trouvé pour cette transaction"));

        return mapToResponseDTO(recu);
    }

    /**
     * Get all receipts within date range (for accounting)
     */
    public List<RecuResponseDTO> getReceiptsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return recuRepository.findByCreeLeBetween(startDate, endDate).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get receipts missing PDF (for batch generation)
     */
    public List<Recu> getReceiptsMissingPdf() {
        log.info("Récupération reçus sans PDF...");
        return recuRepository.findReceiptsMissingPdf();
    }

    /**
     * Get recent receipts globally (admin/statistiques uniquement).
     */
    public List<RecuResponseDTO> getRecentReceipts(int limit) {
        return recuRepository.findRecentReceipts(limit).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Reçus récents de l'utilisateur connecté (écran "Reçus & paiements").
     */
    public List<RecuResponseDTO> getRecentReceiptsForUser(
            com.mboalink.auth.entity.Utilisateur utilisateur, int limit) {
        return recuRepository.findRecentReceiptsByUser(utilisateur, limit).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Update receipt with PDF URL
     */
    public void updateReceiptPdfUrl(UUID recuId, String urlPdf) {
        log.info("Mise à jour URL PDF pour reçu: {}", recuId);
        Recu recu = recuRepository.findById(recuId)
                .orElseThrow(() -> new RuntimeException("Reçu non trouvé"));

        recu.setUrlPdf(urlPdf);
        recuRepository.save(recu);
    }

    /**
     * Generate receipt number format: RCP-20260701-12345
     */
    private String generateReceiptNumber() {
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        String dateStr = now.format(formatter);
        String randomStr = UUID.randomUUID().toString().substring(0, 5).toUpperCase();
        return "RCP-" + dateStr + "-" + randomStr;
    }

    /**
     * Async PDF generation (trigger in separate thread/job)
     */
    private void generateReceiptPdfAsync(Recu recu) {
        log.info("Déclenchement génération PDF asynchrone pour reçu: {}", recu.getId());
        // TODO: Call PDF generation service (async task)
        // This should be handled by a separate scheduled job or async task
        // Example: pdfGenerationService.generateAsync(recu);
    }

    /**
     * Map Entity to DTO
     */
    private RecuResponseDTO mapToResponseDTO(Recu recu) {
        boolean pdfDisponible = recu.getUrlPdf() != null && !recu.getUrlPdf().isEmpty();

        return RecuResponseDTO.builder()
                .id(recu.getId())
                .numeroRecu(recu.getNumeroRecu())
                .montantTotal(recu.getMontantTotal())
                .urlPdf(recu.getUrlPdf())
                .creeLe(recu.getCreeLe())
                .transactionId(recu.getTransaction().getId())
                .typeTransaction(recu.getTransaction().getTypeTransaction())
                .operateur(recu.getTransaction().getOperateur())
                .utilisateurId(recu.getTransaction().getUtilisateur().getId().toString())
                .pdfDisponible(pdfDisponible)
                .lienTelechargement(pdfDisponible ? "/api/recus/" + recu.getId() + "/download" : null)
                .build();
    }
}