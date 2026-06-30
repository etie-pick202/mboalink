package com.mboalink.auth.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ModifierProfilRequest {

    @Size(max = 100, message = "Nom trop long")
    private String nom;

    @Size(max = 100, message = "Prénom trop long")
    private String prenom;
}