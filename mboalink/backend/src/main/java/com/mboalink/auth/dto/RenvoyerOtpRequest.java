package com.mboalink.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RenvoyerOtpRequest {

    @NotBlank(message = "La cible est obligatoire")
    private String cible;

    @NotBlank(message = "Le type est obligatoire")
    private String type;
}