package com.mboalink.grossiste.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreerFicheRequest {

    @NotBlank(message = "Le nom de l'entreprise est obligatoire")
    private String nomEntreprise;

    private String description;
    private String secteurActivite;
    private String ville;
    private String quartier;
    private String adresseComplete;
    private String telephoneProfessionnel;
    private String emailProfessionnel;
    private String siteWeb;
    private String logoUrl;
    private Integer anneeCreation;
}