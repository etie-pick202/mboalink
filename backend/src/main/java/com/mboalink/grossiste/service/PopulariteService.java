package com.mboalink.grossiste.service;

import com.mboalink.auth.repository.ComportementUtilisateurRepository;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.DeverrouillageCoordonneesRepository;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.search.repository.FavoriRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Calcule le score de popularité de chaque fiche grossiste et en déduit
 * le prix de déverrouillage des coordonnées — plus une fiche est
 * demandée, plus l'accès à ses coordonnées coûte cher.
 *
 * Recalcul en tâche planifiée (nocturne), pas à la volée à chaque
 * événement : un prix qui change en cours de paiement serait source de
 * confusion et de litiges pour l'utilisateur.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PopulariteService {

    /** Prix plancher — même montant pour toutes les fiches, quelle que soit la catégorie. */
    static final BigDecimal PRIX_PLANCHER = BigDecimal.valueOf(5000);

    /** Poids relatifs de chaque signal dans le score composite. */
    private static final double POIDS_DEVERROUILLAGES = 3.0;
    private static final double POIDS_FAVORIS = 2.0;
    private static final double POIDS_VUES = 0.1;
    private static final double POIDS_AVIS = 0.5;

    /** Fenêtre glissante pour le signal "vues" (le seul historisé en continu). */
    private static final long FENETRE_VUES_JOURS = 30;

    private final FicheGrossisteRepository ficheRepository;
    private final FavoriRepository favoriRepository;
    private final DeverrouillageCoordonneesRepository deverrouillageRepository;
    private final ComportementUtilisateurRepository comportementRepository;

    /** Recalcul nocturne — 3h du matin, heure serveur. */
    @Scheduled(cron = "0 0 3 * * *")
    @Transactional
    public void recalculerToutesLesFiches() {
        log.info("[POPULARITE] Début du recalcul nocturne des scores de popularité");
        List<FicheGrossiste> fiches = ficheRepository.findAll();
        for (FicheGrossiste fiche : fiches) {
            recalculerUneFiche(fiche);
        }
        ficheRepository.saveAll(fiches);
        log.info("[POPULARITE] Recalcul terminé — {} fiches mises à jour", fiches.size());
    }

    private void recalculerUneFiche(FicheGrossiste fiche) {
        long nbDeverrouillages = deverrouillageRepository.countByFicheGrossisteId(fiche.getId());
        long nbFavoris = favoriRepository.countByFicheGrossisteId(fiche.getId());
        long nbVues = comportementRepository.countVuesFiche(
                fiche.getId().toString(),
                LocalDateTime.now().minusDays(FENETRE_VUES_JOURS));
        double noteMoyenne = fiche.getNoteMoyenne() != null ? fiche.getNoteMoyenne() : 0.0;
        int nombreAvis = fiche.getNombreAvis() != null ? fiche.getNombreAvis() : 0;

        double score = (nbDeverrouillages * POIDS_DEVERROUILLAGES)
                + (nbFavoris * POIDS_FAVORIS)
                + (nbVues * POIDS_VUES)
                + (noteMoyenne * nombreAvis * POIDS_AVIS);

        fiche.setScorePopularite(score);
        fiche.setPrixDeverrouillageActuel(calculerPrix(score));
    }

    /**
     * Traduction du score en prix par paliers (pas de formule continue) —
     * plus lisible et prévisible pour l'utilisateur, et plus facile à
     * ajuster (déplacer un seuil) sans changer le modèle.
     */
    BigDecimal calculerPrix(double score) {
        double multiplicateur;
        if (score < 20) {
            multiplicateur = 1.0;
        } else if (score < 60) {
            multiplicateur = 1.3;
        } else if (score < 150) {
            multiplicateur = 1.6;
        } else {
            multiplicateur = 2.0; // plafond
        }

        return PRIX_PLANCHER
                .multiply(BigDecimal.valueOf(multiplicateur))
                // Arrondi à la centaine la plus proche — un prix "propre" en FCFA.
                .setScale(-2, RoundingMode.HALF_UP);
    }
}
