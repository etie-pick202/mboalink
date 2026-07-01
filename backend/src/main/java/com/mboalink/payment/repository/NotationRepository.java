package com.mboalink.payment.repository;

import com.mboalink.payment.entity.Notation;
import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.grossiste.entity.FicheGrossiste;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface NotationRepository extends JpaRepository<Notation, UUID> {

    /**
     * Find all ratings for a wholesaler (excluding hidden/flagged)
     */
    @Query("SELECT n FROM Notation n WHERE n.ficheGrossiste = :ficheGrossiste AND n.statut = 'VISIBLE' ORDER BY n.creeLe DESC")
    List<Notation> findVisibleRatingsByGrossiste(@Param("ficheGrossiste") FicheGrossiste ficheGrossiste);

    /**
     * Find all ratings by a user
     */
    List<Notation> findByUtilisateur(Utilisateur utilisateur);

    /**
     * Check if user already rated a wholesaler (one rating per user per wholesaler)
     */
    Optional<Notation> findByUtilisateurAndFicheGrossiste(Utilisateur utilisateur, FicheGrossiste ficheGrossiste);

    /**
     * Find only verified ratings (from users with verified transactions)
     */
    @Query("SELECT n FROM Notation n WHERE n.ficheGrossiste = :ficheGrossiste AND n.transactionVerifiee = true AND n.statut = 'VISIBLE' ORDER BY n.creeLe DESC")
    List<Notation> findVerifiedRatingsByGrossiste(@Param("ficheGrossiste") FicheGrossiste ficheGrossiste);

    /**
     * Calculate average rating for a wholesaler
     */
    @Query("SELECT AVG(n.note) FROM Notation n WHERE n.ficheGrossiste = :ficheGrossiste AND n.statut = 'VISIBLE'")
    Optional<Double> findAverageRatingByGrossiste(@Param("ficheGrossiste") FicheGrossiste ficheGrossiste);

    /**
     * Count ratings by note level for a wholesaler
     */
    @Query("SELECT COUNT(n) FROM Notation n WHERE n.ficheGrossiste = :ficheGrossiste AND n.note = :note AND n.statut = 'VISIBLE'")
    long countRatingsByNoteAndGrossiste(@Param("ficheGrossiste") FicheGrossiste ficheGrossiste, @Param("note") Integer note);

    /**
     * Find flagged ratings for moderation
     */
    @Query("SELECT n FROM Notation n WHERE n.statut = 'SIGNALE' ORDER BY n.creeLe DESC")
    List<Notation> findFlaggedRatingsForModeration();

    /**
     * Find ratings needing verification (from verified transactions)
     */
    @Query("SELECT n FROM Notation n WHERE n.transactionVerifiee = false AND n.statut = 'VISIBLE'")
    List<Notation> findUnverifiedRatings();

    /**
     * Count total ratings for a wholesaler
     */
    @Query("SELECT COUNT(n) FROM Notation n WHERE n.ficheGrossiste = :ficheGrossiste AND n.statut = 'VISIBLE'")
    long countRatingsByGrossiste(@Param("ficheGrossiste") FicheGrossiste ficheGrossiste);
}
