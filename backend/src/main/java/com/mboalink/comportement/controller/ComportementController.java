package com.mboalink.comportement.controller;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.auth.repository.ConsentementRepository;
import com.mboalink.comportement.dto.EvenementComportementRequest;
import com.mboalink.comportement.service.ComportementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/comportement")
@RequiredArgsConstructor
public class ComportementController {

    private final ComportementService comportementService;
    private final UtilisateurRepository utilisateurRepository;
    private final ConsentementRepository consentementRepository;

    @PostMapping("/evenement")
    public ResponseEntity<Map<String, String>> enregistrerEvenement(
            @Valid @RequestBody EvenementComportementRequest request,
            Authentication authentication) {

        Utilisateur utilisateur = resolveUtilisateur(authentication);
        if (utilisateur == null) {
            return ResponseEntity.ok(Map.of("message", "Non authentifié, événement ignoré"));
        }

        comportementService.enregistrer(
                utilisateur,
                request.getTypeAction(),
                request.getValeur(),
                request.getLocalisation()
        );

        return ResponseEntity.ok(Map.of("message", "Événement enregistré"));
    }

    @GetMapping("/consentement")
    public ResponseEntity<Map<String, Object>> getConsentementTracking(Authentication authentication) {
        Utilisateur utilisateur = resolveUtilisateur(authentication);
        if (utilisateur == null) {
            return ResponseEntity.ok(Map.of("trackingAccepte", false));
        }

        boolean trackingAccepte = consentementRepository
                .findByUtilisateurId(utilisateur.getId())
                .map(c -> Boolean.TRUE.equals(c.getTrackingAccepte()))
                .orElse(false);

        return ResponseEntity.ok(Map.of("trackingAccepte", trackingAccepte));
    }

    private Utilisateur resolveUtilisateur(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) return null;
        try {
            return utilisateurRepository.findById(UUID.fromString(authentication.getName())).orElse(null);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
