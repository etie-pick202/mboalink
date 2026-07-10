package com.mboalink.grossiste.dto;

import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.entity.ProduitGrossiste;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Data
@Builder
public class FicheResponse {

    private UUID id;
    private String nomEntreprise;
    private String description;
    private String secteurActivite;
    private String ville;
    private String quartier;
    private String logoUrl;
    private String statutVerification;
    private Double noteMoyenne;
    private Integer nombreAvis;
    private Integer anneeCreation;

    /** Prix actuel du déverrouillage des coordonnées (varie avec la popularité). */
    private BigDecimal prixDeverrouillageActuel;

    private Boolean certifiePremium;

    // La liste des produits de la fiche (peut être vide)
    private List<ProduitResponse> produits;

    // NOTE : on n'inclut PAS telephoneProfessionnel ni emailProfessionnel
    // car ce sont des données payantes (déverrouillage)

    // Version SANS produits (pour la liste de l'annuaire)
    public static FicheResponse depuis(FicheGrossiste f) {
        return FicheResponse.builder()
                .id(f.getId())
                .nomEntreprise(f.getNomEntreprise())
                .description(f.getDescription())
                .secteurActivite(f.getSecteurActivite())
                .ville(f.getVille())
                .quartier(f.getQuartier())
                .logoUrl(f.getLogoUrl())
                .statutVerification(f.getStatutVerification())
                .noteMoyenne(f.getNoteMoyenne())
                .nombreAvis(f.getNombreAvis())
                .anneeCreation(f.getAnneeCreation())
                .prixDeverrouillageActuel(f.getPrixDeverrouillageActuel())
                .certifiePremium(f.getCertifiePremium())
                .build();
    }

    // Version AVEC produits (pour le détail d'une fiche)
    public static FicheResponse avecProduits(FicheGrossiste f, List<ProduitGrossiste> produits) {
        FicheResponse reponse = depuis(f);
        reponse.setProduits(
                produits.stream()
                        .map(ProduitResponse::depuis)
                        .collect(Collectors.toList())
        );
        return reponse;
    }
}