package com.mboalink.search.repository;

import com.mboalink.search.entity.Favori;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface FavoriRepository extends JpaRepository<Favori, UUID> {

    @Query("SELECT f.ficheGrossiste.id FROM Favori f WHERE f.utilisateur.id = :utilisateurId")
    List<UUID> findFicheIdsParUtilisateur(@Param("utilisateurId") UUID utilisateurId);

    // Notifications "favori certifié" / "baisse de prix" — utilisateurs à alerter
    // quand la fiche qu'ils suivent change.
    @Query("SELECT f.utilisateur.id FROM Favori f WHERE f.ficheGrossiste.id = :ficheId")
    List<UUID> findUtilisateurIdsParFiche(@Param("ficheId") UUID ficheId);

    long countByFicheGrossisteId(UUID ficheGrossisteId);

    boolean existsByUtilisateurIdAndFicheGrossisteId(UUID utilisateurId, UUID ficheGrossisteId);

    Optional<Favori> findByUtilisateurIdAndFicheGrossisteId(UUID utilisateurId, UUID ficheGrossisteId);

    void deleteByUtilisateurIdAndFicheGrossisteId(UUID utilisateurId, UUID ficheGrossisteId);
}
