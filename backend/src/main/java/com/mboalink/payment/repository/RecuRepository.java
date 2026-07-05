package com.mboalink.payment.repository;

import com.mboalink.payment.entity.Recu;
import com.mboalink.payment.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RecuRepository extends JpaRepository<Recu, UUID> {

    /**
     * Find receipt by receipt number (unique identifier)
     */
    Optional<Recu> findByNumeroRecu(String numeroRecu);

    /**
     * Find receipt by transaction
     */
    Optional<Recu> findByTransaction(Transaction transaction);

    /**
     * Find all receipts created within a date range (for audit/reporting)
     */
    List<Recu> findByCreeLeBetween(LocalDateTime start, LocalDateTime end);

    /**
     * Find receipts with generated PDF (non-null urlPdf)
     */
    @Query("SELECT r FROM Recu r WHERE r.urlPdf IS NOT NULL ORDER BY r.creeLe DESC")
    List<Recu> findReceiptsWithPdf();

    /**
     * Find receipts missing PDF (for batch generation/retry)
     */
    @Query("SELECT r FROM Recu r WHERE r.urlPdf IS NULL ORDER BY r.creeLe ASC")
    List<Recu> findReceiptsMissingPdf();

    /**
     * Count receipts generated (by month/period for statistics)
     */
    long count();

    /**
     * Find recent receipts (for dashboard display)
     */
    @Query("SELECT r FROM Recu r ORDER BY r.creeLe DESC LIMIT :limit")
    List<Recu> findRecentReceipts(@Param("limit") int limit);
}
