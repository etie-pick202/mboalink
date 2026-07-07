package com.mboalink.grossiste.repository;

import com.mboalink.grossiste.entity.DeverrouillageCoordonnees;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface DeverrouillageCoordonneesRepository extends JpaRepository<DeverrouillageCoordonnees, UUID> {

    /**
     * Vérifie si un utilisateur a déjà déverrouillé
     * les coordonnées d'une fiche grossiste.
     */
    boolean existsByUtilisateurIdAndFicheGrossisteId(UUID utilisateurId, UUID ficheGrossisteId);

    /**
     * Retourne le nombre d'utilisateurs distincts
     * ayant déverrouillé au moins une fiche.
     */
    @Query("SELECT COUNT(DISTINCT d.utilisateur.id) FROM DeverrouillageCoordonnees d")
    long countUtilisateursDistincts();
}