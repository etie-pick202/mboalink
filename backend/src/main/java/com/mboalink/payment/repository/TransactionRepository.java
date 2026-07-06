package com.mboalink.payment.repository;

import com.mboalink.payment.entity.Transaction;
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
public interface TransactionRepository extends JpaRepository<Transaction, UUID> {

    /**
     * Find transaction by external reference (Mobile Money transaction ID)
     */
    Optional<Transaction> findByReferenceExterne(String referenceExterne);

    /**
     * Find all transactions for a user
     */
    List<Transaction> findByUtilisateur(Utilisateur utilisateur);

    /**
     * Find transactions by status
     */
    List<Transaction> findByStatut(String statut);

    /**
     * Find pending transactions (awaiting payment confirmation)
     */
    List<Transaction> findByStatutAndCreeLeBefore(String statut, LocalDateTime date);

    /**
     * Find successful transactions for a user
     */
    @Query("SELECT t FROM Transaction t WHERE t.utilisateur = :utilisateur AND t.statut = 'SUCCES' ORDER BY t.creeLe DESC")
    List<Transaction> findSuccessfulTransactionsByUser(@Param("utilisateur") Utilisateur utilisateur);

    /**
     * Find transactions by type and status
     */
    List<Transaction> findByTypeTransactionAndStatut(String typeTransaction, String statut);

    /**
     * Find transactions by operator (Mobile Money provider)
     */
    List<Transaction> findByOperateur(String operateur);

    /**
     * Find pending transactions for retry
     */
    @Query("SELECT t FROM Transaction t WHERE t.statut = 'EN_ATTENTE' AND t.creeLe < :cutoffTime ORDER BY t.creeLe ASC")
    List<Transaction> findPendingTransactionsForRetry(@Param("cutoffTime") LocalDateTime cutoffTime);

    /**
     * Count successful transactions
     */
    long countByStatut(String statut);

    /**
     * Get monthly revenue totals for a given year and month range
     */
    @Query(value = """
        SELECT EXTRACT(MONTH FROM cree_le) AS mois, COALESCE(SUM(montant), 0) AS total
        FROM transactions
        WHERE statut = 'SUCCES'
          AND EXTRACT(YEAR FROM cree_le) = :annee
          AND EXTRACT(MONTH FROM cree_le) BETWEEN :moisDebut AND :moisFin
        GROUP BY EXTRACT(MONTH FROM cree_le)
        ORDER BY mois
        """, nativeQuery = true)
    List<Object[]> getRevenusParMois(@Param("annee") int annee,
                                      @Param("moisDebut") int moisDebut,
                                      @Param("moisFin") int moisFin);
}