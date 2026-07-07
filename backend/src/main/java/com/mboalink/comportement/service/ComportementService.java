package com.mboalink.comportement.service;

import com.mboalink.auth.entity.ComportementUtilisateur;
import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.ComportementUtilisateurRepository;
import com.mboalink.auth.repository.ConsentementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ComportementService {

    private final ComportementUtilisateurRepository comportementRepository;
    private final ConsentementRepository consentementRepository;

    @Transactional
    public void enregistrer(Utilisateur utilisateur, String typeAction, String valeur, String localisation) {
        if (utilisateur == null) return;
        if (!aConsentementTracking(utilisateur)) return;
        if (valeur == null && localisation == null) return;

        ComportementUtilisateur comportement = ComportementUtilisateur.builder()
                .utilisateur(utilisateur)
                .typeAction(typeAction)
                .valeur(valeur != null ? valeur.trim() : null)
                .localisation(localisation != null ? localisation.trim() : null)
                .build();

        comportementRepository.save(comportement);
    }

    private boolean aConsentementTracking(Utilisateur utilisateur) {
        return consentementRepository.findByUtilisateurId(utilisateur.getId())
                .map(c -> Boolean.TRUE.equals(c.getTrackingAccepte()))
                .orElse(false);
    }
}
