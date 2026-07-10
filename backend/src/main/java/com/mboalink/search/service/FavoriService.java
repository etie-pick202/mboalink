package com.mboalink.search.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.commun.exception.RessourceIntrouvableException;
import com.mboalink.grossiste.dto.FicheResponse;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.search.entity.Favori;
import com.mboalink.search.repository.FavoriRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriService {

    private final FavoriRepository favoriRepository;
    private final FicheGrossisteRepository ficheGrossisteRepository;
    private final UtilisateurRepository utilisateurRepository;

    /** Idempotent : ajouter deux fois le même favori ne fait rien la seconde fois. */
    @Transactional
    public void ajouter(UUID utilisateurId, UUID ficheId) {
        if (favoriRepository.existsByUtilisateurIdAndFicheGrossisteId(utilisateurId, ficheId)) {
            return;
        }
        FicheGrossiste fiche = ficheGrossisteRepository.findById(ficheId)
                .orElseThrow(() -> new RessourceIntrouvableException("Fiche introuvable."));

        // Référence JPA légère — pas besoin de charger l'utilisateur entier.
        Utilisateur utilisateur = utilisateurRepository.getReferenceById(utilisateurId);

        Favori favori = Favori.builder()
                .utilisateur(utilisateur)
                .ficheGrossiste(fiche)
                .build();
        favoriRepository.save(favori);
    }

    /** Idempotent : retirer un favori déjà absent ne fait rien. */
    @Transactional
    public void retirer(UUID utilisateurId, UUID ficheId) {
        favoriRepository.deleteByUtilisateurIdAndFicheGrossisteId(utilisateurId, ficheId);
    }

    public boolean estFavori(UUID utilisateurId, UUID ficheId) {
        return favoriRepository.existsByUtilisateurIdAndFicheGrossisteId(utilisateurId, ficheId);
    }

    public List<FicheResponse> listerMesFavoris(UUID utilisateurId) {
        List<UUID> ficheIds = favoriRepository.findFicheIdsParUtilisateur(utilisateurId);
        return ficheGrossisteRepository.findAllById(ficheIds).stream()
                .map(FicheResponse::depuis)
                .collect(Collectors.toList());
    }
}
