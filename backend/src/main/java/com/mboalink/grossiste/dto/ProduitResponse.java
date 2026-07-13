package com.mboalink.grossiste.dto;

import com.mboalink.grossiste.entity.ProduitGrossiste;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
public class ProduitResponse {

    private UUID id;
    private UUID ficheGrossisteId;
    private String nom;
    private String description;
    private String categorie;
    private BigDecimal prixUnitaire;
    private Integer quantiteMinimale;
    private String uniteMesure;
    private String imageUrl;
    private Boolean estDisponible;

    public static ProduitResponse depuis(ProduitGrossiste p) {
        return ProduitResponse.builder()
                .id(p.getId())
                .ficheGrossisteId(p.getFicheGrossiste() != null ? p.getFicheGrossiste().getId() : null)
                .nom(p.getNom())
                .description(p.getDescription())
                .categorie(p.getCategorie())
                .prixUnitaire(p.getPrixUnitaire())
                .quantiteMinimale(p.getQuantiteMinimale())
                .uniteMesure(p.getUniteMesure())
                .imageUrl(p.getImageUrl())
                .estDisponible(p.getEstDisponible())
                .build();
    }
}