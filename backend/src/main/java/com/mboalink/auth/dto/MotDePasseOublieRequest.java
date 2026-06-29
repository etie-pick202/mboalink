package com.mboalink.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class MotDePasseOublieRequest {

    @NotBlank(message = "L'identifiant est obligatoire")
    private String identifiant;
}