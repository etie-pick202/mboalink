package com.mboalink.grossiste.service;

import com.mboalink.grossiste.dto.CreerProduitRequest;
import com.mboalink.grossiste.dto.ProduitResponse;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.entity.ProduitGrossiste;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.grossiste.repository.ProduitGrossisteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProduitGrossisteService {

    private final ProduitGrossisteRepository produitRepository;
    private final FicheGrossisteRepository ficheRepository;

    public ProduitResponse ajouterProduit(UUID utilisateurId, UUID ficheId, CreerProduitRequest req) {

        // 1. Récupérer la fiche
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new IllegalStateException("Fiche introuvable."));

        // 2. Sécurité : vérifier que la fiche appartient bien à l'utilisateur connecté
        if (!fiche.getUtilisateur().getId().equals(utilisateurId)) {
            throw new IllegalStateException("Vous ne pouvez ajouter des produits qu'à votre propre fiche.");
        }

        // 3. Construire le produit
        ProduitGrossiste produit = ProduitGrossiste.builder()
                .ficheGrossiste(fiche)
                .nom(req.getNom())
                .description(req.getDescription())
                .categorie(req.getCategorie())
                .prixUnitaire(req.getPrixUnitaire())
                .quantiteMinimale(req.getQuantiteMinimale())
                .uniteMesure(req.getUniteMesure())
                .imageUrl(req.getImageUrl())
                .estDisponible(true)
                .build();

        // 4. Sauvegarder
        ProduitGrossiste sauvegarde = produitRepository.save(produit);

        // 5. Renvoyer la réponse
        return ProduitResponse.depuis(sauvegarde);
    }
}