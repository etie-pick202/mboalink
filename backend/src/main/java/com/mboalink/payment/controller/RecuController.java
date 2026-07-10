package com.mboalink.payment.controller;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.payment.dto.RecuResponseDTO;
import com.mboalink.payment.entity.Recu;
import com.mboalink.payment.service.RecuService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/recus")
@RequiredArgsConstructor
@Slf4j
public class RecuController {

    private final RecuService recuService;
    private final UtilisateurRepository utilisateurRepository;

    /**
     * GET /api/v1/recus/{numeroRecu}
     * Get receipt by number
     */
    @GetMapping("/{numeroRecu}")
    public ResponseEntity<?> getReceiptByNumber(
            @PathVariable String numeroRecu,
            Authentication authentication) {
        log.info("Récupération reçu: {}", numeroRecu);

        try {
            RecuResponseDTO response = recuService.getReceiptByNumber(numeroRecu);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", response
            ));
        } catch (Exception e) {
            log.error("Erreur récupération reçu: ", e);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "success", false,
                    "message", "Reçu non trouvé"
            ));
        }
    }

    /**
     * GET /api/v1/recus/transaction/{transactionId}
     * Get receipt for a transaction
     */
    @GetMapping("/transaction/{transactionId}")
    public ResponseEntity<?> getReceiptByTransaction(
            @PathVariable UUID transactionId,
            Authentication authentication) {
        log.info("Récupération reçu pour transaction: {}", transactionId);

        try {
            RecuResponseDTO response = recuService.getReceiptByTransaction(transactionId);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", response
            ));
        } catch (Exception e) {
            log.error("Erreur récupération reçu: ", e);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "success", false,
                    "message", "Reçu non trouvé"
            ));
        }
    }

    /**
     * GET /api/v1/recus/month/{yearMonth}
     * Get receipts for a specific month (for accounting)
     * Format: 2026-07 (YYYY-MM)
     */
    @GetMapping("/month/{yearMonth}")
    public ResponseEntity<?> getReceiptsByMonth(
            @PathVariable String yearMonth,
            Authentication authentication) {
        log.info("Récupération reçus pour mois: {}", yearMonth);

        try {
            YearMonth ym = YearMonth.parse(yearMonth);
            LocalDateTime start = ym.atDay(1).atStartOfDay();
            LocalDateTime end = ym.atEndOfMonth().atTime(23, 59, 59);

            List<RecuResponseDTO> receipts = recuService.getReceiptsByDateRange(start, end);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "month", yearMonth,
                    "count", receipts.size(),
                    "data", receipts
            ));
        } catch (Exception e) {
            log.error("Erreur récupération reçus par mois: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", "Format de mois invalide (utiliser YYYY-MM)"
            ));
        }
    }

    /**
     * GET /api/v1/recus/user/recent
     * Get recent receipts for authenticated user
     */
    @GetMapping("/user/recent")
    public ResponseEntity<?> getRecentReceipts(
            @RequestParam(defaultValue = "10") int limit,
            Authentication authentication) {
        log.info("Récupération reçus récents (limit: {})", limit);

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            // Validate limit
            if (limit < 1 || limit > 100) {
                limit = 10;
            }

            List<RecuResponseDTO> receipts = recuService.getRecentReceiptsForUser(utilisateur, limit);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "count", receipts.size(),
                    "data", receipts
            ));
        } catch (Exception e) {
            log.error("Erreur récupération reçus récents: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "success", false,
                    "message", "Erreur lors de la récupération des reçus récents"
            ));
        }
    }

    /**
     * GET /api/v1/recus/{recuId}/download
     * Download receipt PDF
     */
    @GetMapping("/{recuId}/download")
    public ResponseEntity<?> downloadReceiptPdf(
            @PathVariable UUID recuId,
            Authentication authentication) {
        log.info("Téléchargement PDF reçu: {}", recuId);

        try {
            String userId = authentication.getName();
            Utilisateur utilisateur = utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            // TODO: Implement PDF download
            // For now, return placeholder
            return ResponseEntity.ok(Map.of(
                    "success", false,
                    "message", "Génération du PDF en cours"
            ));
        } catch (Exception e) {
            log.error("Erreur téléchargement PDF: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", "PDF du reçu non disponible"
            ));
        }
    }

    /**
     * GET /api/v1/recus/admin/missing-pdf
     * Get receipts missing PDF (for batch generation)
     */
    @GetMapping("/admin/missing-pdf")
    public ResponseEntity<?> getReceiptsMissingPdf() {
        log.info("Récupération reçus sans PDF");

        try {
            List<Recu> receipts = recuService.getReceiptsMissingPdf();

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("count", receipts.size());
            result.put("message", receipts.size() + " reçus nécessitent une génération de PDF");

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("Erreur récupération reçus sans PDF: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "success", false,
                    "message", "Erreur lors de la récupération des reçus"
            ));
        }
    }

    /**
     * POST /api/v1/recus/{recuId}/pdf-url
     * Update receipt with PDF URL (after generation)
     */
    @PostMapping("/{recuId}/pdf-url")
    public ResponseEntity<?> updateReceiptPdfUrl(
            @PathVariable UUID recuId,
            @RequestParam String urlPdf) {
        log.info("Mise à jour URL PDF pour reçu: {}", recuId);

        try {
            recuService.updateReceiptPdfUrl(recuId, urlPdf);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "URL du PDF du reçu mise à jour"
            ));
        } catch (Exception e) {
            log.error("Erreur mise à jour URL PDF: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }
}
