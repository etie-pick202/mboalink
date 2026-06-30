package com.mboalink.auth.repository;

import com.mboalink.auth.entity.Consentement;
import com.mboalink.auth.entity.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ConsentementRepository extends JpaRepository<Consentement, java.util.UUID> {

    Optional<Consentement> findByUtilisateur(Utilisateur utilisateur);

    Optional<Consentement> findByUtilisateurId(java.util.UUID utilisateurId);
}