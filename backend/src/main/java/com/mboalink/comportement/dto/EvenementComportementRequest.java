package com.mboalink.comportement.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class EvenementComportementRequest {

    /**
     * RECHERCHE | VUE_FICHE | CLIC_CATEGORIE | FILTRE_PRIX | FILTRE_VILLE
     */
    @NotBlank(message = "Le type d'action est obligatoire")
    @Pattern(
        regexp = "RECHERCHE|VUE_FICHE|CLIC_CATEGORIE|FILTRE_PRIX|FILTRE_VILLE",
        message = "Type d'action invalide"
    )
    private String typeAction;

    private String valeur;

    private String localisation;
}
