package com.mboalink.payment.repository;

import com.mboalink.payment.entity.CertificationPremium;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface CertificationPremiumRepository extends JpaRepository<CertificationPremium, UUID> {
    Optional<CertificationPremium> findByFicheGrossisteId(UUID ficheGrossisteId);
}
