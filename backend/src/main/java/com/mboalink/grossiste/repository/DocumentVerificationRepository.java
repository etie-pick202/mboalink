package com.mboalink.grossiste.repository;

import com.mboalink.grossiste.entity.DocumentVerification;
import com.mboalink.grossiste.entity.FicheGrossiste;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface DocumentVerificationRepository extends JpaRepository<DocumentVerification, UUID> {
    List<DocumentVerification> findByFicheGrossiste(FicheGrossiste ficheGrossiste);
    List<DocumentVerification> findByFicheGrossisteId(UUID ficheGrossisteId);
}