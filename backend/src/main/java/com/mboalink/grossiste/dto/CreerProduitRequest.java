package com.mboalink.grossiste.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class CreerProduitRequest {

    @NotBlank(message = "Le nom du produit est obligatoire")
    private String nom;

    private String description;
    private String categorie;
    private BigDecimal prixUnitaire;
    private Integer quantiteMinimale;
    private String uniteMesure;
    private String imageUrl;
}