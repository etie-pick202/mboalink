package com.mboalink.auth.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class ReinitialisationMotDePasseRequest {

    @NotBlank(message = "La cible est obligatoire")
    private String cible;

    @NotBlank(message = "Le code OTP est obligatoire")
    @Size(min = 6, max = 6, message = "Code OTP invalide")
    private String codeOtp;

    @NotBlank(message = "Le nouveau mot de passe est obligatoire")
    @Size(min = 8, max = 72, message = "Le mot de passe doit contenir entre 8 et 72 caractères")
    @Pattern(
            regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&._\\-#])[A-Za-z\\d@$!%*?&._\\-#]{8,}$",
            message = "Le mot de passe doit contenir au moins : une majuscule, une minuscule, un chiffre et un caractère spécial"
    )
    private String nouveauMotDePasse;
}