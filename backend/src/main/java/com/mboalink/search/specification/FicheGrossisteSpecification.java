package com.mboalink.search.specification;

import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.entity.ProduitGrossiste;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import org.springframework.data.jpa.domain.Specification;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class FicheGrossisteSpecification {

    private FicheGrossisteSpecification() {}

    public static Specification<FicheGrossiste> avecFiltres(
            String motCle,
            String ville,
            String categorie,
            BigDecimal prixMin,
            BigDecimal prixMax,
            Boolean certifie,
            Boolean certifiePremium) {

        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (motCle != null && !motCle.isBlank()) {
                String pattern = "%" + motCle.toLowerCase().trim() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("nomEntreprise")), pattern),
                        cb.like(cb.lower(root.get("description")), pattern),
                        cb.like(cb.lower(root.get("secteurActivite")), pattern)
                ));
            }

            if (ville != null && !ville.isBlank()) {
                predicates.add(cb.like(
                        cb.lower(root.get("ville")),
                        "%" + ville.toLowerCase().trim() + "%"
                ));
            }

            if (categorie != null && !categorie.isBlank()) {
                String pattern = "%" + categorie.toLowerCase().trim() + "%";
                predicates.add(cb.like(cb.lower(root.get("secteurActivite")), pattern));
            }

            if (prixMin != null || prixMax != null) {
                Subquery<UUID> subquery = query.subquery(UUID.class);
                Root<ProduitGrossiste> produit = subquery.from(ProduitGrossiste.class);
                subquery.select(produit.get("ficheGrossiste").get("id"));

                List<Predicate> prixPredicates = new ArrayList<>();
                prixPredicates.add(cb.isTrue(produit.get("estDisponible")));
                prixPredicates.add(cb.isNotNull(produit.get("prixUnitaire")));

                if (prixMin != null) {
                    prixPredicates.add(cb.greaterThanOrEqualTo(produit.get("prixUnitaire"), prixMin));
                }
                if (prixMax != null) {
                    prixPredicates.add(cb.lessThanOrEqualTo(produit.get("prixUnitaire"), prixMax));
                }
                subquery.where(prixPredicates.toArray(new Predicate[0]));
                predicates.add(root.get("id").in(subquery));
            }

            if (Boolean.TRUE.equals(certifie)) {
                predicates.add(cb.equal(root.get("statutVerification"), "VERIFIE"));
            }

            if (Boolean.TRUE.equals(certifiePremium)) {
                predicates.add(cb.isTrue(root.get("certifiePremium")));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
