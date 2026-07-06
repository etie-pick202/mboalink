package com.mboalink.grossiste.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreerDocumentRequest {

    @NotBlank(message = "Le type de document est obligatoire")
    private String typeDocument;  // REGISTRE_COMMERCE | CNI | PHOTO_LOCAL | AUTRE

    @NotBlank(message = "L'URL du document est obligatoire")
    private String urlDocument;   // l'URL Firebase envoyée par Flutter
}