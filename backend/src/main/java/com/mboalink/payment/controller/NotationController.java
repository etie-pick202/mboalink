package com.mboalink.payment.controller;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.payment.dto.NotationRequestDTO;
import com.mboalink.payment.dto.NotationResponseDTO;
import com.mboalink.payment.service.NotationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/notations")
@RequiredArgsConstructor
@Slf4j
public class NotationController {

    private final NotationService notationService;
    private final FicheGrossisteRepository ficheGrossisteRepository;

    /**
     * POST /api/v1/notations
     * Create a new rating (only verified transactions)
     */
    @PostMapping
    public ResponseEntity<?> createRating(
            @Valid @RequestBody NotationRequestDTO request,
            Authentication authentication) {
        log.info("Création notation - Grossiste: {}, Note: {}", request.getFicheGrossisteId(), request.getNote());

        try {
            Utilisateur utilisateur = (Utilisateur) authentication.getPrincipal();

            // Get wholesaler
            FicheGrossiste ficheGrossiste = ficheGrossisteRepository.findById(request.getFicheGrossisteId())
                    .orElseThrow(() -> new RuntimeException("Wholesaler not found"));

            // Create rating
            NotationResponseDTO response = notationService.createRating(utilisateur, ficheGrossiste, request);

            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Note ajoutée avec succès");
            result.put("data", response);

            return ResponseEntity.status(HttpStatus.CREATED).body(result);
        } catch (Exception e) {
            log.error("Erreur création notation: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    /**
     * GET /api/v1/notations/grossiste/{ficheGrossisteId}
     * Get all visible ratings for a wholesaler
     */
    @GetMapping("/grossiste/{ficheGrossisteId}")
    public ResponseEntity<?> getRatingsForGrossiste(
            @PathVariable UUID ficheGrossisteId) {
        log.info("Récupération notations pour grossiste: {}", ficheGrossisteId);

        try {
            FicheGrossiste ficheGrossiste = ficheGrossisteRepository.findById(ficheGrossisteId)
                    .orElseThrow(() -> new RuntimeException("Wholesaler not found"));

            List<NotationResponseDTO> ratings = notationService.getRatingsForGrossiste(ficheGrossiste);
            Double averageRating = notationService.getAverageRatingForGrossiste(ficheGrossiste);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "averageRating", averageRating,
                    "count", ratings.size(),
                    "data", ratings
            ));
        } catch (Exception e) {
            log.error("Erreur récupération notations: ", e);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "success", false,
                    "message", "Wholesaler not found"
            ));
        }
    }

    /**
     * GET /api/v1/notations/grossiste/{ficheGrossisteId}/verified
     * Get only verified ratings (from paid transactions)
     */
    @GetMapping("/grossiste/{ficheGrossisteId}/verified")
    public ResponseEntity<?> getVerifiedRatings(
            @PathVariable UUID ficheGrossisteId) {
        log.info("Récupération notations vérifiées pour grossiste: {}", ficheGrossisteId);

        try {
            FicheGrossiste ficheGrossiste = ficheGrossisteRepository.findById(ficheGrossisteId)
                    .orElseThrow(() -> new RuntimeException("Wholesaler not found"));

            List<NotationResponseDTO> ratings = notationService.getVerifiedRatingsForGrossiste(ficheGrossiste);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "count", ratings.size(),
                    "data", ratings
            ));
        } catch (Exception e) {
            log.error("Erreur récupération notations vérifiées: ", e);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "success", false,
                    "message", "Wholesaler not found"
            ));
        }
    }

    /**
     * GET /api/v1/notations/grossiste/{ficheGrossisteId}/breakdown
     * Get rating statistics (5-star, 4-star, etc.)
     */
    @GetMapping("/grossiste/{ficheGrossisteId}/breakdown")
    public ResponseEntity<?> getRatingBreakdown(
            @PathVariable UUID ficheGrossisteId) {
        log.info("Récupération statistiques notations pour grossiste: {}", ficheGrossisteId);

        try {
            FicheGrossiste ficheGrossiste = ficheGrossisteRepository.findById(ficheGrossisteId)
                    .orElseThrow(() -> new RuntimeException("Wholesaler not found"));

            var breakdown = notationService.getRatingBreakdown(ficheGrossiste);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "data", breakdown
            ));
        } catch (Exception e) {
            log.error("Erreur récupération statistiques: ", e);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "success", false,
                    "message", "Wholesaler not found"
            ));
        }
    }

    /**
     * POST /api/v1/notations/{ratingId}/flag
     * Flag rating for moderation
     */
    @PostMapping("/{ratingId}/flag")
    public ResponseEntity<?> flagRating(@PathVariable UUID ratingId) {
        log.info("Signalement notation: {}", ratingId);

        try {
            notationService.flagRating(ratingId);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Notation signalée pour modération"
            ));
        } catch (Exception e) {
            log.error("Erreur signalement notation: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    /**
     * GET /api/v1/notations/admin/flagged
     * Get flagged ratings for moderation
     */
    @GetMapping("/admin/flagged")
    public ResponseEntity<?> getFlaggedRatings() {
        log.info("Récupération notations signalées");

        try {
            List<NotationResponseDTO> flagged = notationService.getFlaggedRatingsForModeration();

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "count", flagged.size(),
                    "data", flagged
            ));
        } catch (Exception e) {
            log.error("Erreur récupération notations signalées: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "success", false,
                    "message", "Error fetching flagged ratings"
            ));
        }
    }

    /**
     * POST /api/v1/notations/{ratingId}/moderate
     * Approve or reject moderated rating
     */
    @PostMapping("/{ratingId}/moderate")
    public ResponseEntity<?> moderateRating(
            @PathVariable UUID ratingId,
            @RequestParam String newStatut) {
        log.info("Modération notation: {} -> {}", ratingId, newStatut);

        try {
            if (!newStatut.matches("VISIBLE|MASQUE")) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                        "success", false,
                        "message", "Status must be VISIBLE or MASQUE"
                ));
            }

            notationService.moderateRating(ratingId, newStatut);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Notation modérée"
            ));
        } catch (Exception e) {
            log.error("Erreur modération notation: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    /**
     * DELETE /api/v1/notations/{ratingId}
     * Delete rating (soft delete)
     */
    @DeleteMapping("/{ratingId}")
    public ResponseEntity<?> deleteRating(@PathVariable UUID ratingId) {
        log.info("Suppression notation: {}", ratingId);

        try {
            notationService.deleteRating(ratingId);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Notation supprimée"
            ));
        } catch (Exception e) {
            log.error("Erreur suppression notation: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }
}
