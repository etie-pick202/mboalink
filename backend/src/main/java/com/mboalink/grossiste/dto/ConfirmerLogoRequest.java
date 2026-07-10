package com.mboalink.grossiste.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ConfirmerLogoRequest {

    @NotBlank(message = "Le chemin du fichier est obligatoire")
    private String filePath;
}
