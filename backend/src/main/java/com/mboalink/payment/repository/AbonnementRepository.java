package com.mboalink.payment.repository;

import com.mboalink.payment.entity.Abonnement;
import com.mboalink.auth.entity.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AbonnementRepository extends JpaRepository<Abonnement, UUID> {

    /**
     * Find active subscription for a user
     */
    Optional<Abonnement> findByUtilisateurAndStatut(Utilisateur utilisateur, String statut);

    /**
     * Find subscription by utilisateur
     */
    Optional<Abonnement> findByUtilisateur(Utilisateur utilisateur);

    /**
     * Find all expired subscriptions (for reminder/suspension)
     */
    List<Abonnement> findByStatutAndDateFinBefore(String statut, LocalDateTime date);

    /**
     * Find subscriptions expiring soon (for reminders)
     */
    @Query("SELECT a FROM Abonnement a WHERE a.statut = 'ACTIF' AND a.dateFin BETWEEN :now AND :future")
    List<Abonnement> findExpiringSubscriptions(@Param("now") LocalDateTime now, @Param("future") LocalDateTime future);

    /**
     * Find subscriptions with auto-renewal enabled and expired
     */
    @Query("SELECT a FROM Abonnement a WHERE a.renouvellementAuto = true AND a.statut = 'EXPIRE' AND a.dateFin <= :date")
    List<Abonnement> findExpiredWithAutoRenewal(@Param("date") LocalDateTime date);

    /**
     * Count active subscriptions
     */
    long countByStatut(String statut);
}
