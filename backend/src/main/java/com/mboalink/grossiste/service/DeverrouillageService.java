package com.mboalink.grossiste.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.auth.security.CurrentUser;
import com.mboalink.commun.exception.AccesRefuseException;
import com.mboalink.commun.exception.ConflitMetierException;
import com.mboalink.commun.exception.RessourceIntrouvableException;
import com.mboalink.grossiste.dto.CoordonneesResponse;
import com.mboalink.grossiste.dto.DeverrouillageHistoriqueResponse;
import com.mboalink.grossiste.dto.DeverrouillerRequest;
import com.mboalink.grossiste.entity.DeverrouillageCoordonnees;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.DeverrouillageCoordonneesRepository;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.payment.entity.Transaction;
import com.mboalink.payment.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DeverrouillageService {

    // Durée de validité d'un déverrouillage — au-delà, la fiche redevient
    // verrouillée pour cet utilisateur et un nouveau paiement est requis.
    private static final long DUREE_DEVERROUILLAGE_HEURES = 24;

    private final DeverrouillageCoordonneesRepository deverrouillageRepository;
    private final FicheGrossisteRepository ficheRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final TransactionRepository transactionRepository;

    public CoordonneesResponse deverrouiller(UUID utilisateurId, UUID ficheId, DeverrouillerRequest req) {

        // 0. Vérifier que c'est bien un REVENDEUR
        if (!"ROLE_UTILISATEUR".equals(CurrentUser.getRole())) {
            throw new AccesRefuseException("Seuls les revendeurs peuvent déverrouiller les coordonnées.");
        }

        // 1. Récupérer la fiche
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new RessourceIntrouvableException("Fiche introuvable."));

        // 2. Si déjà déverrouillé il y a moins de 24h → renvoyer directement
        // les coordonnées, sans exiger un nouveau paiement.
        if (aDejaDeverrouille(utilisateurId, ficheId)) {
            return CoordonneesResponse.depuis(fiche);
        }

        // 3. Vérifier que la transaction existe dans la table de Personne 4
        Transaction transaction = transactionRepository.findById(req.getTransactionId())
                .orElseThrow(() -> new RessourceIntrouvableException("Transaction introuvable."));

        // 4. Vérifier que la transaction est confirmée
        if (!"SUCCES".equals(transaction.getStatut())) {
            throw new ConflitMetierException("La transaction n'est pas confirmée.");
        }

        // 5. Vérifier que c'est bien CET utilisateur qui a payé
        if (!transaction.getUtilisateur().getId().equals(utilisateurId)) {
            throw new AccesRefuseException("Cette transaction ne vous appartient pas.");
        }

        // 6. Récupérer l'utilisateur
        Utilisateur utilisateur = utilisateurRepository.findById(utilisateurId)
                .orElseThrow(() -> new RessourceIntrouvableException("Utilisateur introuvable."));

        // 7. Enregistrer ou renouveler le déverrouillage — un seul
        // enregistrement par (utilisateur, fiche) en base (contrainte
        // unique), donc on met à jour l'existant s'il y en a un plutôt
        // que d'en créer un second après expiration des 24h.
        DeverrouillageCoordonnees deverrouillage = deverrouillageRepository
                .findByUtilisateurIdAndFicheGrossisteId(utilisateurId, ficheId)
                .orElseGet(() -> DeverrouillageCoordonnees.builder()
                        .utilisateur(utilisateur)
                        .ficheGrossiste(fiche)
                        .build());
        deverrouillage.setMontantPaye(req.getMontantPaye());
        deverrouillage.setReferenceTransaction(transaction.getId().toString());
        deverrouillage.setDeverrouilleLe(LocalDateTime.now());

        deverrouillageRepository.save(deverrouillage);

        // 8. Renvoyer les coordonnées
        return CoordonneesResponse.depuis(fiche);
    }

    public boolean aDejaDeverrouille(UUID utilisateurId, UUID ficheId) {
        return deverrouillageRepository.existsByUtilisateurIdAndFicheGrossisteIdAndDeverrouilleLeAfter(
                utilisateurId, ficheId, LocalDateTime.now().minusHours(DUREE_DEVERROUILLAGE_HEURES));
    }

    // Écran "Contacts débloqués"
    public List<DeverrouillageHistoriqueResponse> listerMesDeverrouillages(UUID utilisateurId) {
        LocalDateTime seuilValidite = LocalDateTime.now().minusHours(DUREE_DEVERROUILLAGE_HEURES);
        return deverrouillageRepository.findByUtilisateurIdOrderByDeverrouilleLeDesc(utilisateurId).stream()
                .map(d -> DeverrouillageHistoriqueResponse.depuis(
                        d, d.getDeverrouilleLe().isAfter(seuilValidite)))
                .collect(Collectors.toList());
    }
}
