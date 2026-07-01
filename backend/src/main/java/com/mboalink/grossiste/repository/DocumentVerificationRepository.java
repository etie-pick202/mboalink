package com.mboalink.grossiste.repository;

import com.mboalink.grossiste.entity.DocumentVerification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface DocumentVerificationRepository extends JpaRepository<DocumentVerification, UUID> {

    // Récupérer tous les documents d'une fiche donnée
    List<DocumentVerification> findByFicheGrossisteId(UUID ficheGrossisteId);
}