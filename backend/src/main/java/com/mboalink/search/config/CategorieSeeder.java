package com.mboalink.search.config;

import com.mboalink.search.entity.Categorie;
import com.mboalink.search.repository.CategorieRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Insère les catégories par défaut de l'annuaire au premier démarrage —
 * idempotent (ne fait rien si la table contient déjà des catégories).
 * Les libellés correspondent aux secteurs d'activité les plus courants
 * du marché camerounais du commerce de gros ; l'icône est dérivée du
 * libellé côté application (voir categoryIcon() dans le frontend), donc
 * on ne stocke pas d'iconeUrl ici.
 */
@Component
@Order(1)
@RequiredArgsConstructor
@Slf4j
public class CategorieSeeder implements CommandLineRunner {

    private final CategorieRepository categorieRepository;

    private static final List<String> CATEGORIES_DEFAUT = List.of(
            "Alimentation",
            "Boissons",
            "Cosmétiques",
            "Électronique",
            "Téléphonie",
            "Mode & Vêtements",
            "Chaussures",
            "Quincaillerie",
            "Matériaux de construction",
            "Produits ménagers",
            "Papeterie & Bureautique",
            "Agroalimentaire",
            "Santé & Pharmacie",
            "Automobile & Pièces",
            "Agriculture & Élevage"
    );

    @Override
    public void run(String... args) {
        if (categorieRepository.count() > 0) {
            return;
        }

        CATEGORIES_DEFAUT.forEach(nom -> categorieRepository.save(
                Categorie.builder().nom(nom).estActive(true).build()));

        log.info("[SEED] {} catégories par défaut insérées.", CATEGORIES_DEFAUT.size());
    }
}
