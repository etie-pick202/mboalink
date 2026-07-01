package com.mboalink.search.repository;

import com.mboalink.search.entity.HistoriqueRecherche;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface HistoriqueRechercheRepository extends JpaRepository<HistoriqueRecherche, UUID> {

    @Query("SELECT h FROM HistoriqueRecherche h WHERE h.utilisateur.id = :utilisateurId ORDER BY h.creeLe DESC")
    List<HistoriqueRecherche> findByUtilisateurIdRecent(@Param("utilisateurId") UUID utilisateurId, Pageable pageable);
}
