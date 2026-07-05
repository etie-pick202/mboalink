package com.mboalink.search.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class RechercheGrossisteRequest {

    private String motCle;

    private String ville;

    private String categorie;

    @DecimalMin(value = "0.0", message = "Le prix minimum doit être positif")
    private BigDecimal prixMin;

    @DecimalMin(value = "0.0", message = "Le prix maximum doit être positif")
    private BigDecimal prixMax;

    private Boolean certifie;

    private Double latitudeUtilisateur;

    private Double longitudeUtilisateur;

    /** NOTE_DESC | NOTE_ASC | NOM_ASC | NOM_DESC | CERTIFICATION | PROXIMITE */
    private String tri = "NOTE_DESC";

    @Min(0)
    private int page = 0;

    @Min(1)
    @Max(50)
    private int taille = 10;
}
