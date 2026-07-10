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

    // Coordonnées de contact — données payantes (déverrouillage), donc
    // renseignées UNIQUEMENT pour le propriétaire consultant sa propre
    // fiche (voir #complet). Restent null sur l'annuaire public et le
    // détail d'une fiche tierce (#depuis / #avecProduits).
    private String adresseComplete;
    private String telephoneProfessionnel;
    private String emailProfessionnel;
    private String siteWeb;

    // La liste des produits de la fiche (peut être vide)
    private List<ProduitResponse> produits;

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

    // Version AVEC produits (pour le détail d'une fiche PUBLIQUE — sans coordonnées)
    public static FicheResponse avecProduits(FicheGrossiste f, List<ProduitGrossiste> produits) {
        FicheResponse reponse = depuis(f);
        reponse.setProduits(mapProduits(produits));
        return reponse;
    }

    // Version COMPLÈTE (propriétaire consultant sa propre fiche) — inclut
    // les coordonnées de contact + les produits. Ne JAMAIS utiliser pour
    // une fiche tierce.
    public static FicheResponse complet(FicheGrossiste f, List<ProduitGrossiste> produits) {
        FicheResponse reponse = depuis(f);
        reponse.setAdresseComplete(f.getAdresseComplete());
        reponse.setTelephoneProfessionnel(f.getTelephoneProfessionnel());
        reponse.setEmailProfessionnel(f.getEmailProfessionnel());
        reponse.setSiteWeb(f.getSiteWeb());
        reponse.setProduits(mapProduits(produits));
        return reponse;
    }

    private static List<ProduitResponse> mapProduits(List<ProduitGrossiste> produits) {
        return produits.stream()
                .map(ProduitResponse::depuis)
                .collect(Collectors.toList());
    }
}