package com.mboalink.auth.repository;

import com.mboalink.auth.entity.OtpCode;
import com.mboalink.auth.enums.TypeOtp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface OtpCodeRepository extends JpaRepository<OtpCode, UUID> {

    @Query("""
        SELECT o FROM OtpCode o
        WHERE o.cible = :cible
          AND o.type  = :type
          AND o.utilise = false
          AND o.expirationLe > :maintenant
        ORDER BY o.creeLe DESC
        LIMIT 1
    """)
    Optional<OtpCode> findDernierValide(String cible, TypeOtp type, LocalDateTime maintenant);

    @Modifying
    @Transactional
    @Query("DELETE FROM OtpCode o WHERE o.expirationLe < :maintenant")
    void supprimerExpires(LocalDateTime maintenant);

    @Modifying
    @Transactional
    @Query("""
        UPDATE OtpCode o SET o.utilise = true
        WHERE o.cible = :cible AND o.type = :type AND o.utilise = false
    """)
    void invaliderTousPourCible(String cible, TypeOtp type);
}