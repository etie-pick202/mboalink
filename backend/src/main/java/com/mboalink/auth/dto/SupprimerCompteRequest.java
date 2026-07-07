package com.mboalink.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SupprimerCompteRequest {

    @NotBlank(message = "Le mot de passe est obligatoire pour confirmer la suppression")
    private String motDePasse;
}