package com.mboalink.auth.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AuthResponseDto {

    private String accessToken;
    private String refreshToken;
    private String role;
    private String utilisateurId;
    private String nom;
    private String prenom;
    private String email;
    private String telephone;
    private Boolean emailVerifie;
    private Boolean telephoneVerifie;
    private String message;
}