package com.mboalink.grossiste.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.grossiste.dto.CreerFicheRequest;
import com.mboalink.grossiste.dto.FicheResponse;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.entity.ProduitGrossiste;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.grossiste.repository.ProduitGrossisteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FicheGrossisteService {

    private final FicheGrossisteRepository ficheRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final ProduitGrossisteRepository produitRepository;

    // Créer une fiche grossiste
    public FicheResponse creerFiche(UUID utilisateurId, CreerFicheRequest req) {

        // 1. Vérifier que l'utilisateur n'a pas déjà une fiche
        if (ficheRepository.existsByUtilisateurId(utilisateurId)) {
            throw new IllegalStateException("Vous avez déjà une fiche grossiste.");
        }

        // 2. Récupérer l'utilisateur connecté
        Utilisateur utilisateur = utilisateurRepository.findById(utilisateurId)
                .orElseThrow(() -> new IllegalStateException("Utilisateur introuvable."));

        // 3. Construire la nouvelle fiche
        FicheGrossiste fiche = FicheGrossiste.builder()
                .utilisateur(utilisateur)
                .nomEntreprise(req.getNomEntreprise())
                .description(req.getDescription())
                .secteurActivite(req.getSecteurActivite())
                .ville(req.getVille())
                .quartier(req.getQuartier())
                .adresseComplete(req.getAdresseComplete())
                .telephoneProfessionnel(req.getTelephoneProfessionnel())
                .emailProfessionnel(req.getEmailProfessionnel())
                .siteWeb(req.getSiteWeb())
                .logoUrl(req.getLogoUrl())
                .statutVerification("EN_ATTENTE")
                .build();

        // 4. Sauvegarder en base
        FicheGrossiste sauvegardee = ficheRepository.save(fiche);

        // 5. Renvoyer une réponse propre
        return FicheResponse.depuis(sauvegardee);
    }

    // Liste de toutes les fiches (annuaire public)
    public List<FicheResponse> listerFiches() {
        return ficheRepository.findAll().stream()
                .map(FicheResponse::depuis)
                .collect(Collectors.toList());
    }

    // Détail d'une fiche avec ses produits
    public FicheResponse consulterFiche(UUID ficheId) {
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new IllegalStateException("Fiche introuvable."));

        List<ProduitGrossiste> produits = produitRepository.findByFicheGrossisteId(ficheId);

        return FicheResponse.avecProduits(fiche, produits);
    }
    // Modifier sa propre fiche
    public FicheResponse modifierFiche(UUID utilisateurId, UUID ficheId, CreerFicheRequest req) {

        // 1. Récupérer la fiche existante
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new IllegalStateException("Fiche introuvable."));

        // 2. Sécurité : vérifier que la fiche appartient à l'utilisateur connecté
        if (!fiche.getUtilisateur().getId().equals(utilisateurId)) {
            throw new IllegalStateException("Vous ne pouvez modifier que votre propre fiche.");
        }

        // 3. Mettre à jour les champs
        fiche.setNomEntreprise(req.getNomEntreprise());
        fiche.setDescription(req.getDescription());
        fiche.setSecteurActivite(req.getSecteurActivite());
        fiche.setVille(req.getVille());
        fiche.setQuartier(req.getQuartier());
        fiche.setAdresseComplete(req.getAdresseComplete());
        fiche.setTelephoneProfessionnel(req.getTelephoneProfessionnel());
        fiche.setEmailProfessionnel(req.getEmailProfessionnel());
        fiche.setSiteWeb(req.getSiteWeb());
        fiche.setLogoUrl(req.getLogoUrl());

        // 4. Sauvegarder (Hibernate détecte que la fiche existe déjà et fait un UPDATE)
        FicheGrossiste miseAJour = ficheRepository.save(fiche);

        // 5. Renvoyer la réponse
        return FicheResponse.depuis(miseAJour);
    }
}