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

    // ---- Méthodes Personne 2 (Fiches Grossistes) ----

    // Vérifier si un utilisateur a déjà une fiche (car @OneToOne unique)
    boolean existsByUtilisateurId(UUID utilisateurId);

    // Récupérer la fiche d'un utilisateur donné
    Optional<FicheGrossiste> findByUtilisateurId(UUID utilisateurId);

    // ---- Méthodes Personne 3 (Recherche & Filtrage) ----

    @Query("SELECT DISTINCT LOWER(f.ville) FROM FicheGrossiste f WHERE f.ville IS NOT NULL AND f.ville <> '' ORDER BY LOWER(f.ville)")
    List<String> findDistinctVilles();

    @Query("SELECT DISTINCT LOWER(f.secteurActivite) FROM FicheGrossiste f WHERE f.secteurActivite IS NOT NULL AND f.secteurActivite <> '' ORDER BY LOWER(f.secteurActivite)")
    List<String> findDistinctSecteursActivite();

    @Query("SELECT f FROM FicheGrossiste f WHERE f.statutVerification IN ('VERIFIE', 'EN_ATTENTE') ORDER BY f.noteMoyenne DESC")
    List<FicheGrossiste> findActifsOrderByNote(Pageable pageable);
    List<FicheGrossiste> findByStatutVerificationOrderByCreeLeDesc(String statut);
long countByStatutVerification(String statut);
    
}
