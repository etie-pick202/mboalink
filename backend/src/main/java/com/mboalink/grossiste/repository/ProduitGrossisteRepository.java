package com.mboalink.grossiste.repository;

import com.mboalink.grossiste.entity.ProduitGrossiste;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProduitGrossisteRepository extends JpaRepository<ProduitGrossiste, UUID> {

    // Récupérer tous les produits d'une fiche donnée
    List<ProduitGrossiste> findByFicheGrossisteId(UUID ficheGrossisteId);
}