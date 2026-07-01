package com.mboalink.grossiste.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.grossiste.dto.CreerFicheRequest;
import com.mboalink.grossiste.dto.FicheResponse;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FicheGrossisteService {

    private final FicheGrossisteRepository ficheRepository;
    private final UtilisateurRepository utilisateurRepository;

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
}