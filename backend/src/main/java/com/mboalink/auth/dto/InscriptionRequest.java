package com.mboalink.auth.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class InscriptionRequest {

    @Size(max = 100, message = "Nom trop long")
    private String nom;

    @Size(max = 100, message = "Prénom trop long")
    private String prenom;

    @Email(message = "Adresse email invalide")
    @Size(max = 150)
    private String email;

    // Format camerounais : 6XXXXXXXX ou +2376XXXXXXXX
    @Pattern(
            regexp = "^(\\+237)?6[0-9]{8}$",
            message = "Numéro invalide. Format attendu : 6XXXXXXXX ou +2376XXXXXXXX"
    )
    private String telephone;

    @NotBlank(message = "Le mot de passe est obligatoire")
    @Size(min = 8, max = 72, message = "Le mot de passe doit contenir entre 8 et 72 caractères")
    @Pattern(
            regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&._\\-#])[A-Za-z\\d@$!%*?&._\\-#]{8,}$",
            message = "Le mot de passe doit contenir au moins : une majuscule, une minuscule, un chiffre et un caractère spécial (@$!%*?&._-#)"
    )
    private String motDePasse;

    private String role;
}