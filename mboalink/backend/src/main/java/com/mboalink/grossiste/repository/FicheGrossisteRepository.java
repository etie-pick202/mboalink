package com.mboalink.grossiste.repository;

import com.mboalink.grossiste.entity.FicheGrossiste;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface FicheGrossisteRepository extends JpaRepository<FicheGrossiste, UUID>,
        JpaSpecificationExecutor<FicheGrossiste> {

    // ==========================
    // Gestion des fiches grossistes
    // ==========================

    /**
     * Vérifie si un utilisateur possède déjà une fiche grossiste.
     */
    boolean existsByUtilisateurId(UUID utilisateurId);

    /**
     * Récupère la fiche grossiste associée à un utilisateur.
     */
    Optional<FicheGrossiste> findByUtilisateurId(UUID utilisateurId);

    // ==========================
    // Recherche et filtrage
    // ==========================

    /**
     * Retourne la liste des villes disponibles.
     */
    @Query("""
           SELECT DISTINCT LOWER(f.ville)
           FROM FicheGrossiste f
           WHERE f.ville IS NOT NULL
             AND f.ville <> ''
           ORDER BY LOWER(f.ville)
           """)
    List<String> findDistinctVilles();

    /**
     * Retourne la liste des secteurs d'activité disponibles.
     */
    @Query("""
           SELECT DISTINCT LOWER(f.secteurActivite)
           FROM FicheGrossiste f
           WHERE f.secteurActivite IS NOT NULL
             AND f.secteurActivite <> ''
           ORDER BY LOWER(f.secteurActivite)
           """)
    List<String> findDistinctSecteursActivite();

    /**
     * Retourne les fiches actives (VERIFIE ou EN_ATTENTE)
     * triées par note décroissante.
     */
    @Query("""
           SELECT f
           FROM FicheGrossiste f
           WHERE f.statutVerification IN ('VERIFIE', 'EN_ATTENTE')
           ORDER BY f.noteMoyenne DESC
           """)
    List<FicheGrossiste> findActifsOrderByNote(Pageable pageable);

    // ==========================
    // Administration
    // ==========================

    /**
     * Retourne les fiches ayant un statut donné,
     * triées de la plus récente à la plus ancienne.
     */
    List<FicheGrossiste> findByStatutVerificationOrderByCreeLeDesc(String statut);

    /**
     * Compte le nombre de fiches ayant un statut donné.
     */
    long countByStatutVerification(String statut);
}