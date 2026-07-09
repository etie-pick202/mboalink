package com.mboalink.payment.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.payment.dto.NotationRequestDTO;
import com.mboalink.payment.dto.NotationResponseDTO;
import com.mboalink.payment.entity.Notation;
import com.mboalink.payment.entity.Transaction;
import com.mboalink.payment.repository.NotationRepository;
import com.mboalink.payment.repository.TransactionRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class NotationService {

    private final NotationRepository notationRepository;
    private final TransactionRepository transactionRepository;
    private final FicheGrossisteRepository ficheGrossisteRepository;

    /**
     * Create a new rating (only if user has verified transaction)
     */
    public NotationResponseDTO createRating(Utilisateur utilisateur, FicheGrossiste ficheGrossiste, NotationRequestDTO request) {
        log.info("Création notation pour utilisateur: {} | Grossiste: {}", utilisateur.getId(), ficheGrossiste.getId());

        // Verify user hasn't already rated this wholesaler
        Optional<Notation> existing = notationRepository.findByUtilisateurAndFicheGrossiste(utilisateur, ficheGrossiste);
        if (existing.isPresent()) {
            throw new RuntimeException("Vous avez déjà noté ce grossiste");
        }

        // Verify transaction if provided
        boolean transactionVerifiee = false;
        if (request.getReferenceTransaction() != null) {
            Transaction transaction = transactionRepository.findByReferenceExterne(request.getReferenceTransaction())
                    .orElse(null);
            if (transaction != null && "SUCCES".equals(transaction.getStatut())) {
                transactionVerifiee = true;
            }
        }

        Notation notation = Notation.builder()
                .utilisateur(utilisateur)
                .ficheGrossiste(ficheGrossiste)
                .note(request.getNote())
                .commentaire(request.getCommentaire())
                .transactionVerifiee(transactionVerifiee)
                .statut("VISIBLE")
                .creeLe(java.time.LocalDateTime.now())
                .build();

        Notation saved = notationRepository.save(notation);
        log.info("Notation créée: {} | Note: {}", saved.getId(), request.getNote());

        updateFicheGrossisteStats(ficheGrossiste);

        return mapToResponseDTO(saved);
    }

    /**
     * Get all visible ratings for a wholesaler
     */
    public List<NotationResponseDTO> getRatingsForGrossiste(FicheGrossiste ficheGrossiste) {
        return notationRepository.findVisibleRatingsByGrossiste(ficheGrossiste).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get only verified ratings (from users with paid transactions)
     */
    public List<NotationResponseDTO> getVerifiedRatingsForGrossiste(FicheGrossiste ficheGrossiste) {
        return notationRepository.findVerifiedRatingsByGrossiste(ficheGrossiste).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get average rating for wholesaler
     */
    public Double getAverageRatingForGrossiste(FicheGrossiste ficheGrossiste) {
        return notationRepository.findAverageRatingByGrossiste(ficheGrossiste).orElse(0.0);
    }

    /**
     * Get rating breakdown (how many 5-star, 4-star, etc.)
     */
    public NotationBreakdownDTO getRatingBreakdown(FicheGrossiste ficheGrossiste) {
        long count5 = notationRepository.countRatingsByNoteAndGrossiste(ficheGrossiste, 5);
        long count4 = notationRepository.countRatingsByNoteAndGrossiste(ficheGrossiste, 4);
        long count3 = notationRepository.countRatingsByNoteAndGrossiste(ficheGrossiste, 3);
        long count2 = notationRepository.countRatingsByNoteAndGrossiste(ficheGrossiste, 2);
        long count1 = notationRepository.countRatingsByNoteAndGrossiste(ficheGrossiste, 1);

        return NotationBreakdownDTO.builder()
                .fiveStars(count5)
                .fourStars(count4)
                .threeStars(count3)
                .twoStars(count2)
                .oneStar(count1)
                .total(count5 + count4 + count3 + count2 + count1)
                .build();
    }

    /**
     * Flag a rating for moderation
     */
    public void flagRating(UUID ratingId) {
        log.warn("Notation signalée: {}", ratingId);
        Notation notation = notationRepository.findById(ratingId)
                .orElseThrow(() -> new RuntimeException("Note non trouvée"));

        notation.setStatut("SIGNALE");
        notationRepository.save(notation);
    }

    /**
     * Get flagged ratings for moderation
     */
    public List<NotationResponseDTO> getFlaggedRatingsForModeration() {
        return notationRepository.findFlaggedRatingsForModeration().stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Approve/Reject moderated rating
     */
    public void moderateRating(UUID ratingId, String newStatut) {
        log.info("Modération notation: {} | Nouveau statut: {}", ratingId, newStatut);
        Notation notation = notationRepository.findById(ratingId)
                .orElseThrow(() -> new RuntimeException("Note non trouvée"));

        notation.setStatut(newStatut); // VISIBLE | MASQUE
        notation.setMisAJourLe(java.time.LocalDateTime.now());
        notationRepository.save(notation);

        updateFicheGrossisteStats(notation.getFicheGrossiste());
    }

    /**
     * Recompute and persist the wholesaler's rating stats (average + count)
     */
    private void updateFicheGrossisteStats(FicheGrossiste ficheGrossiste) {
        FicheGrossiste managed = ficheGrossisteRepository.findById(ficheGrossiste.getId())
                .orElseThrow(() -> new RuntimeException("Fiche grossiste non trouvée"));

        long nombreAvis = notationRepository.countRatingsByGrossiste(managed);
        Double noteMoyenne = notationRepository.findAverageRatingByGrossiste(managed).orElse(0.0);

        managed.setNombreAvis((int) nombreAvis);
        managed.setNoteMoyenne(noteMoyenne);
        ficheGrossisteRepository.save(managed);

        log.info("[NOTATION] FicheGrossiste {} mise à jour → note_moyenne: {} | nombre_avis: {}",
                managed.getId(), noteMoyenne, nombreAvis);
    }

    /**
     * Delete a rating (soft delete by masking)
     */
    public void deleteRating(UUID ratingId) {
        log.info("Suppression notation: {}", ratingId);
        moderateRating(ratingId, "MASQUE");
    }

    /**
     * Map Entity to DTO
     */
    private NotationResponseDTO mapToResponseDTO(Notation notation) {
        return NotationResponseDTO.builder()
                .id(notation.getId())
                .ficheGrossisteId(notation.getFicheGrossiste().getId())
                .ficheGrossisteName(notation.getFicheGrossiste().getNomEntreprise())
                .utilisateurId(notation.getUtilisateur().getId())
                .utilisateurNom(notation.getUtilisateur().getNom() + " " + notation.getUtilisateur().getPrenom())
                .utilisateurAvatar(null) // No avatar field in Utilisateur yet
                .note(notation.getNote())
                .commentaire(notation.getCommentaire())
                .transactionVerifiee(notation.getTransactionVerifiee())
                .statut(notation.getStatut())
                .creeLe(notation.getCreeLe())
                .misAJourLe(notation.getMisAJourLe())
                .peutEditer(false) // Will be set based on user context
                .build();
    }

    /**
     * DTO for rating breakdown statistics
     */
    public record NotationBreakdownDTO(
            long fiveStars,
            long fourStars,
            long threeStars,
            long twoStars,
            long oneStar,
            long total
    ) {
        public static NotationBreakdownDTOBuilder builder() {
            return new NotationBreakdownDTOBuilder();
        }

        public static class NotationBreakdownDTOBuilder {
            private long fiveStars;
            private long fourStars;
            private long threeStars;
            private long twoStars;
            private long oneStar;
            private long total;

            public NotationBreakdownDTOBuilder fiveStars(long fiveStars) {
                this.fiveStars = fiveStars;
                return this;
            }

            public NotationBreakdownDTOBuilder fourStars(long fourStars) {
                this.fourStars = fourStars;
                return this;
            }

            public NotationBreakdownDTOBuilder threeStars(long threeStars) {
                this.threeStars = threeStars;
                return this;
            }

            public NotationBreakdownDTOBuilder twoStars(long twoStars) {
                this.twoStars = twoStars;
                return this;
            }

            public NotationBreakdownDTOBuilder oneStar(long oneStar) {
                this.oneStar = oneStar;
                return this;
            }

            public NotationBreakdownDTOBuilder total(long total) {
                this.total = total;
                return this;
            }

            public NotationBreakdownDTO build() {
                return new NotationBreakdownDTO(fiveStars, fourStars, threeStars, twoStars, oneStar, total);
            }
        }
    }
}