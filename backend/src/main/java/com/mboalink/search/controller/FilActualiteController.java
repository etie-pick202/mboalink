package com.mboalink.search.controller;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.search.dto.FilActualiteResponseDto;
import com.mboalink.search.service.FilActualiteService;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/search/fil-actualite")
@RequiredArgsConstructor
public class FilActualiteController {

    private final FilActualiteService filActualiteService;
    private final UtilisateurRepository utilisateurRepository;

    @GetMapping
    public ResponseEntity<FilActualiteResponseDto> getFilActualite(
            @RequestParam(required = false) Double latitudeUtilisateur,
            @RequestParam(required = false) Double longitudeUtilisateur,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "10") @Min(1) @Max(50) int taille,
            Authentication authentication) {

        Utilisateur utilisateur = resolveUtilisateur(authentication);
        return ResponseEntity.ok(filActualiteService.genererFil(
                utilisateur, latitudeUtilisateur, longitudeUtilisateur, page, taille));
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
