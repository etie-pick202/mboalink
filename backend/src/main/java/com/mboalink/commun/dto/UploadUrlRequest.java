package com.mboalink.commun.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UploadUrlRequest {

    @NotBlank(message = "Le type de fichier est obligatoire")
    private String typeDocument; // ex: REGISTRE_COMMERCE | CNI | PHOTO_LOCAL | PHOTO_PROFIL | LOGO

    @NotBlank(message = "L'extension du fichier est obligatoire")
    private String extension; // ex: pdf | jpg | png

    @NotBlank(message = "Le contexte est obligatoire")
    private String contexte; // ex: grossistes | utilisateurs | produits
}