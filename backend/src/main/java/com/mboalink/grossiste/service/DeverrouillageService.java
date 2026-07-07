package com.mboalink.grossiste.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.auth.security.CurrentUser;
import com.mboalink.grossiste.dto.CoordonneesResponse;
import com.mboalink.grossiste.dto.DeverrouillerRequest;
import com.mboalink.grossiste.entity.DeverrouillageCoordonnees;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.payment.entity.Transaction;
import com.mboalink.grossiste.repository.DeverrouillageCoordonneesRepository;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.payment.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DeverrouillageService {

    private final DeverrouillageCoordonneesRepository deverrouillageRepository;
    private final FicheGrossisteRepository ficheRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final TransactionRepository transactionRepository;

    public CoordonneesResponse deverrouiller(UUID utilisateurId, UUID ficheId, DeverrouillerRequest req) {

        // 0. Vérifier que c'est bien un REVENDEUR
        if (!"ROLE_UTILISATEUR".equals(CurrentUser.getRole())) {
            throw new IllegalStateException("Seuls les revendeurs peuvent déverrouiller les coordonnées.");
        }

        // 1. Récupérer la fiche
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new IllegalStateException("Fiche introuvable."));

        // 2. Si déjà déverrouillé → renvoyer directement les coordonnées
        if (deverrouillageRepository.existsByUtilisateurIdAndFicheGrossisteId(utilisateurId, ficheId)) {
            return CoordonneesResponse.depuis(fiche);
        }

        // 3. Vérifier que la transaction existe dans la table de Personne 4
        Transaction transaction = transactionRepository.findById(req.getTransactionId())
                .orElseThrow(() -> new IllegalStateException("Transaction introuvable."));

        // 4. Vérifier que la transaction est confirmée
        if (!"SUCCES".equals(transaction.getStatut())) {
            throw new IllegalStateException("La transaction n'est pas confirmée.");
        }

        // 5. Vérifier que c'est bien CET utilisateur qui a payé
        if (!transaction.getUtilisateur().getId().equals(utilisateurId)) {
            throw new IllegalStateException("Cette transaction ne vous appartient pas.");
        }

        // 6. Récupérer l'utilisateur
        Utilisateur utilisateur = utilisateurRepository.findById(utilisateurId)
                .orElseThrow(() -> new IllegalStateException("Utilisateur introuvable."));

        // 7. Enregistrer le déverrouillage
        DeverrouillageCoordonnees deverrouillage = DeverrouillageCoordonnees.builder()
                .utilisateur(utilisateur)
                .ficheGrossiste(fiche)
                .montantPaye(req.getMontantPaye())
                .referenceTransaction(transaction.getId().toString())
                .build();

        deverrouillageRepository.save(deverrouillage);

        // 8. Renvoyer les coordonnées
        return CoordonneesResponse.depuis(fiche);
    }

    public boolean aDejaDeverrouille(UUID utilisateurId, UUID ficheId) {
        return deverrouillageRepository.existsByUtilisateurIdAndFicheGrossisteId(utilisateurId, ficheId);
    }
}