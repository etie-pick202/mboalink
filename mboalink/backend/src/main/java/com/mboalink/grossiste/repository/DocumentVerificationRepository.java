package com.mboalink.grossiste.repository;

import com.mboalink.grossiste.entity.DocumentVerification;
import com.mboalink.grossiste.entity.FicheGrossiste;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface DocumentVerificationRepository extends JpaRepository<DocumentVerification, UUID> {

    /**
     * Récupère tous les documents de vérification
     * associés à une fiche grossiste.
     */
    List<DocumentVerification> findByFicheGrossiste(FicheGrossiste ficheGrossiste);

    /**
     * Récupère tous les documents de vérification
     * à partir de l'identifiant d'une fiche grossiste.
     */
    List<DocumentVerification> findByFicheGrossisteId(UUID ficheGrossisteId);
}