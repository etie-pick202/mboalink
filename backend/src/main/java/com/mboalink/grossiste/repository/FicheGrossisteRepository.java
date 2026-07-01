package com.mboalink.grossiste.repository;

import com.mboalink.grossiste.entity.FicheGrossiste;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface FicheGrossisteRepository extends JpaRepository<FicheGrossiste, UUID> {

    // Vérifier si un utilisateur a déjà une fiche (car @OneToOne unique)
    boolean existsByUtilisateurId(UUID utilisateurId);

    // Récupérer la fiche d'un utilisateur donné
    Optional<FicheGrossiste> findByUtilisateurId(UUID utilisateurId);
}