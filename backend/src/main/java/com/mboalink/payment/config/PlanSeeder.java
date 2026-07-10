package com.mboalink.payment.config;

import com.mboalink.payment.entity.Plan;
import com.mboalink.payment.repository.PlanRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

/**
 * Insère les plans grossiste par défaut au premier démarrage — idempotent
 * (ne fait rien si des plans GROSSISTE existent déjà). Remplace les prix
 * qui étaient codés en dur côté app Flutter (15 000 F/mois, 150 000 F/an).
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class PlanSeeder implements CommandLineRunner {

    private final PlanRepository planRepository;

    @Override
    public void run(String... args) {
        if (!planRepository.findByRoleCibleAndEstActifTrueOrderByOrdreAffichageAsc("GROSSISTE").isEmpty()) {
            return;
        }

        planRepository.save(Plan.builder()
                .nom("Mensuel")
                .roleCible("GROSSISTE")
                .prix(BigDecimal.valueOf(15000))
                .periodicite("MENSUEL")
                .avantages(String.join("\n",
                        "Fiche vérifiée et visible dans l'annuaire",
                        "Statistiques de vues",
                        "Produits illimités"))
                .ordreAffichage(0)
                .build());

        planRepository.save(Plan.builder()
                .nom("Annuel")
                .roleCible("GROSSISTE")
                .prix(BigDecimal.valueOf(150000))
                .periodicite("ANNUEL")
                .avantages(String.join("\n",
                        "Fiche vérifiée et visible dans l'annuaire",
                        "Statistiques de vues",
                        "Produits illimités",
                        "2 mois offerts"))
                .ordreAffichage(1)
                .build());

        log.info("[PLANS] Plans grossiste par défaut créés (Mensuel 15000 F, Annuel 150000 F)");
    }
}
