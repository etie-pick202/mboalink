package com.mboalink.grossiste.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.auth.security.CurrentUser;
import com.mboalink.grossiste.dto.CoordonneesResponse;
import com.mboalink.grossiste.dto.DeverrouillerRequest;
import com.mboalink.grossiste.entity.DeverrouillageCoordonnees;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.DeverrouillageCoordonneesRepository;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DeverrouillageService {

    private final DeverrouillageCoordonneesRepository deverrouillageRepository;
    private final FicheGrossisteRepository ficheRepository;
    private final UtilisateurRepository utilisateurRepository;

    // Déverrouiller les coordonnées d'une fiche (après paiement)
    public CoordonneesResponse deverrouiller(UUID utilisateurId, UUID ficheId, DeverrouillerRequest req) {

        // 0. Vérifier que c'est bien un REVENDEUR (UTILISATEUR) qui déverrouille
        if (!"ROLE_UTILISATEUR".equals(CurrentUser.getRole())) {
            throw new IllegalStateException("Seuls les revendeurs peuvent déverrouiller les coordonnées.");
        }

        // 1. Récupérer la fiche
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new IllegalStateException("Fiche introuvable."));

        // 2. Si déjà déverrouillé, on renvoie directement les coordonnées (pas de double paiement)
        if (deverrouillageRepository.existsByUtilisateurIdAndFicheGrossisteId(utilisateurId, ficheId)) {
            return CoordonneesResponse.depuis(fiche);
        }

        // 3. Récupérer l'utilisateur
        Utilisateur utilisateur = utilisateurRepository.findById(utilisateurId)
                .orElseThrow(() -> new IllegalStateException("Utilisateur introuvable."));

        // 4. Enregistrer le déverrouillage (preuve que l'utilisateur a payé)
        DeverrouillageCoordonnees deverrouillage = DeverrouillageCoordonnees.builder()
                .utilisateur(utilisateur)
                .ficheGrossiste(fiche)
                .montantPaye(req.getMontantPaye())
                .referenceTransaction(req.getReferenceTransaction())
                .build();

        deverrouillageRepository.save(deverrouillage);

        // 5. Renvoyer les coordonnées enfin visibles
        return CoordonneesResponse.depuis(fiche);
    }

    // Vérifier si l'utilisateur a déjà déverrouillé cette fiche
    // (permet à Flutter de savoir s'il affiche "Payer" ou directement le numéro)
    public boolean aDejaDeverrouille(UUID utilisateurId, UUID ficheId) {
        return deverrouillageRepository.existsByUtilisateurIdAndFicheGrossisteId(utilisateurId, ficheId);
    }
}