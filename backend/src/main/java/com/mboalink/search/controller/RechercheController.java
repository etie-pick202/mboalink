package com.mboalink.search.controller;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.search.dto.RechercheGrossisteRequest;
import com.mboalink.search.dto.RechercheResponseDto;
import com.mboalink.search.service.RechercheService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/search")
@RequiredArgsConstructor
public class RechercheController {

    private final RechercheService rechercheService;
    private final FicheGrossisteRepository ficheGrossisteRepository;
    private final UtilisateurRepository utilisateurRepository;

    @GetMapping("/grossistes")
    public ResponseEntity<RechercheResponseDto> rechercher(
            @Valid @ModelAttribute RechercheGrossisteRequest request,
            Authentication authentication) {

        Utilisateur utilisateur = resolveUtilisateur(authentication);
        return ResponseEntity.ok(rechercheService.rechercherGrossistes(request, utilisateur));
    }

    @GetMapping("/villes")
    public ResponseEntity<List<String>> listerVilles() {
        return ResponseEntity.ok(ficheGrossisteRepository.findDistinctVilles());
    }

    @GetMapping("/secteurs")
    public ResponseEntity<List<String>> listerSecteurs() {
        return ResponseEntity.ok(ficheGrossisteRepository.findDistinctSecteursActivite());
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
