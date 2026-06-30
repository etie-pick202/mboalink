package com.mboalink.auth.controller;

import com.mboalink.auth.dto.*;
import com.mboalink.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/inscription")
    public ResponseEntity<AuthResponseDto> inscrire(
            @Valid @RequestBody InscriptionRequest req) {
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(authService.inscrire(req));
    }

    @PostMapping("/verifier-otp")
    public ResponseEntity<AuthResponseDto> verifierOtp(
            @Valid @RequestBody OtpVerificationRequest req) {
        return ResponseEntity.ok(authService.verifierOtp(req));
    }

    @PostMapping("/renvoyer-otp")
    public ResponseEntity<Map<String, String>> renvoyerOtp(
            @Valid @RequestBody RenvoyerOtpRequest req) {
        authService.renvoyerOtp(req);
        return ResponseEntity.ok(Map.of(
                "statut", "success",
                "message", "Code OTP renvoyé."
        ));
    }

    @PostMapping("/connexion")
    public ResponseEntity<AuthResponseDto> connecter(
            @Valid @RequestBody ConnexionRequest req) {
        return ResponseEntity.ok(authService.connecter(req));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponseDto> rafraichir(
            @Valid @RequestBody RefreshTokenRequest req) {
        return ResponseEntity.ok(authService.rafraichirToken(req));
    }

    @PostMapping("/logout")
    public ResponseEntity<Map<String, String>> deconnecter(
            @Valid @RequestBody LogoutRequest req) {
        authService.deconnecter(req);
        return ResponseEntity.ok(Map.of(
                "statut", "success",
                "message", "Déconnexion réussie."
        ));
    }

    @PostMapping("/mot-de-passe-oublie")
    public ResponseEntity<Map<String, String>> motDePasseOublie(
            @Valid @RequestBody MotDePasseOublieRequest req) {
        authService.demanderReinitialisationMotDePasse(req);
        return ResponseEntity.ok(Map.of(
                "statut", "success",
                "message", "Un code de réinitialisation vous a été envoyé."
        ));
    }

    @PostMapping("/reinitialiser-mot-de-passe")
    public ResponseEntity<Map<String, String>> reinitialiserMotDePasse(
            @Valid @RequestBody ReinitialisationMotDePasseRequest req) {
        authService.reinitialiserMotDePasse(req);
        return ResponseEntity.ok(Map.of(
                "statut", "success",
                "message", "Mot de passe réinitialisé. Vous pouvez vous reconnecter."
        ));
    }
}