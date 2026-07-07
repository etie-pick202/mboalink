package com.mboalink.auth.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class ProfilResponseDto {

    private String utilisateurId;
    private String nom;
    private String prenom;
    private String email;
    private String telephone;
    private String role;
    private Boolean emailVerifie;
    private Boolean telephoneVerifie;
    private LocalDateTime creeLe;
}