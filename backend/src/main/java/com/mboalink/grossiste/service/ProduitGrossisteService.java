package com.mboalink.grossiste.service;

import com.mboalink.commun.exception.AccesRefuseException;
import com.mboalink.commun.exception.RessourceIntrouvableException;
import com.mboalink.grossiste.dto.CreerProduitRequest;
import com.mboalink.grossiste.dto.ProduitResponse;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.entity.ProduitGrossiste;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.grossiste.repository.ProduitGrossisteRepository;
import com.mboalink.notification.service.NotificationService;
import com.mboalink.search.repository.FavoriRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProduitGrossisteService {

    private final ProduitGrossisteRepository produitRepository;
    private final FicheGrossisteRepository ficheRepository;
    private final FavoriRepository favoriRepository;
    private final NotificationService notificationService;

    // Liste les produits d'une fiche pour son propriétaire (écran "Ma boutique").
    @Transactional(readOnly = true)
    public java.util.List<ProduitResponse> listerProduits(UUID utilisateurId, UUID ficheId) {
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new RessourceIntrouvableException("Fiche introuvable."));

        if (!fiche.getUtilisateur().getId().equals(utilisateurId)) {
            throw new AccesRefuseException("Vous ne pouvez consulter que les produits de votre propre fiche.");
        }

        return produitRepository.findByFicheGrossisteId(ficheId).stream()
                .map(ProduitResponse::depuis)
                .toList();
    }

    public ProduitResponse ajouterProduit(UUID utilisateurId, UUID ficheId, CreerProduitRequest req) {

        // 1. Récupérer la fiche
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new RessourceIntrouvableException("Fiche introuvable."));

        // 2. Sécurité : vérifier que la fiche appartient bien à l'utilisateur connecté
        if (!fiche.getUtilisateur().getId().equals(utilisateurId)) {
            throw new AccesRefuseException("Vous ne pouvez ajouter des produits qu'à votre propre fiche.");
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

    public ProduitResponse modifierProduit(UUID utilisateurId, UUID ficheId, UUID produitId, CreerProduitRequest req) {
        ProduitGrossiste produit = produitRepository.findById(produitId)
                .orElseThrow(() -> new RessourceIntrouvableException("Produit introuvable."));

        if (!produit.getFicheGrossiste().getId().equals(ficheId)
                || !produit.getFicheGrossiste().getUtilisateur().getId().equals(utilisateurId)) {
            throw new AccesRefuseException("Vous ne pouvez modifier que les produits de votre propre fiche.");
        }

        BigDecimal ancienPrix = produit.getPrixUnitaire();

        produit.setNom(req.getNom());
        produit.setDescription(req.getDescription());
        produit.setCategorie(req.getCategorie());
        produit.setPrixUnitaire(req.getPrixUnitaire());
        produit.setQuantiteMinimale(req.getQuantiteMinimale());
        produit.setUniteMesure(req.getUniteMesure());
        produit.setImageUrl(req.getImageUrl());

        ProduitGrossiste sauvegarde = produitRepository.save(produit);

        if (ancienPrix != null && req.getPrixUnitaire() != null
                && req.getPrixUnitaire().compareTo(ancienPrix) < 0) {
            notifierBaisseDePrix(sauvegarde);
        }

        return ProduitResponse.depuis(sauvegarde);
    }

    // "Baisse de prix" — alerte les utilisateurs ayant mis cette fiche en favori.
    private void notifierBaisseDePrix(ProduitGrossiste produit) {
        FicheGrossiste fiche = produit.getFicheGrossiste();
        favoriRepository.findUtilisateurIdsParFiche(fiche.getId()).forEach(utilisateurId ->
                notificationService.creerPourUtilisateurId(
                        utilisateurId,
                        "BAISSE_PRIX",
                        "Baisse de prix sur " + produit.getNom(),
                        fiche.getNomEntreprise() + " · " + produit.getPrixUnitaire() + " F",
                        fiche.getId().toString()
                ));
    }

    public void supprimerProduit(UUID utilisateurId, UUID ficheId, UUID produitId) {
        ProduitGrossiste produit = produitRepository.findById(produitId)
                .orElseThrow(() -> new RessourceIntrouvableException("Produit introuvable."));

        if (!produit.getFicheGrossiste().getId().equals(ficheId)
                || !produit.getFicheGrossiste().getUtilisateur().getId().equals(utilisateurId)) {
            throw new AccesRefuseException("Vous ne pouvez supprimer que les produits de votre propre fiche.");
        }

        produitRepository.delete(produit);
    }
}