package com.mboalink.admin.repository;

import com.mboalink.admin.entity.Signalement;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface SignalementRepository extends JpaRepository<Signalement, UUID> {
    List<Signalement> findByStatutOrderByCreeLeDesc(String statut);
    long countByStatut(String statut);
}