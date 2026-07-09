package com.mboalink.grossiste.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ConfirmerUploadRequest {

    @NotBlank(message = "Le chemin du fichier est obligatoire")
    private String filePath;

    @NotBlank(message = "Le type de document est obligatoire")
    private String typeDocument;
}