package com.mboalink.grossiste.controller;

import com.mboalink.auth.security.CurrentUser;
import com.mboalink.grossiste.dto.ConfirmerLogoRequest;
import com.mboalink.grossiste.dto.CreerFicheRequest;
import com.mboalink.grossiste.dto.FicheResponse;
import com.mboalink.grossiste.dto.FicheStatistiquesResponse;
import com.mboalink.grossiste.service.FicheGrossisteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/grossistes")
@RequiredArgsConstructor
public class FicheGrossisteController {

    private final FicheGrossisteService ficheService;

    // POST /api/v1/grossistes  → créer une fiche
    @PostMapping
    public ResponseEntity<FicheResponse> creerFiche(
            @Valid @RequestBody CreerFicheRequest req) {
        FicheResponse reponse = ficheService.creerFiche(CurrentUser.getId(), req);
        return ResponseEntity.ok(reponse);
    }

    // GET /api/v1/grossistes  → liste de l'annuaire
    @GetMapping
    public ResponseEntity<List<FicheResponse>> listerFiches() {
        return ResponseEntity.ok(ficheService.listerFiches());
    }

    // GET /api/v1/grossistes/me  → fiche du grossiste connecté (404 si pas
    // encore créée). Doit être déclaré avant /{ficheId} pour éviter que
    // "me" soit interprété comme un UUID par le path variable.
    @GetMapping("/me")
    public ResponseEntity<FicheResponse> consulterMaFiche() {
        return ResponseEntity.ok(ficheService.consulterMaFiche(CurrentUser.getId()));
    }

    // GET /api/v1/grossistes/{ficheId}  → détail d'une fiche avec ses produits
    @GetMapping("/{ficheId}")
    public ResponseEntity<FicheResponse> consulterFiche(@PathVariable UUID ficheId) {
        return ResponseEntity.ok(ficheService.consulterFiche(ficheId));
    }
    // PUT /api/v1/grossistes/{ficheId}  → modifier sa fiche
    @PutMapping("/{ficheId}")
    public ResponseEntity<FicheResponse> modifierFiche(
            @PathVariable UUID ficheId,
            @Valid @RequestBody CreerFicheRequest req) {
        FicheResponse reponse = ficheService.modifierFiche(
                CurrentUser.getId(), ficheId, req);
        return ResponseEntity.ok(reponse);
    }

    // PATCH /api/v1/grossistes/{ficheId}/logo  → confirmer l'upload Supabase du logo
    @PatchMapping("/{ficheId}/logo")
    public ResponseEntity<FicheResponse> confirmerLogo(
            @PathVariable UUID ficheId,
            @Valid @RequestBody ConfirmerLogoRequest req) {
        FicheResponse reponse = ficheService.confirmerLogo(
                CurrentUser.getId(), ficheId, req.getFilePath());
        return ResponseEntity.ok(reponse);
    }

    // GET /api/v1/grossistes/{ficheId}/statistiques  → dashboard grossiste
    @GetMapping("/{ficheId}/statistiques")
    public ResponseEntity<FicheStatistiquesResponse> consulterStatistiques(
            @PathVariable UUID ficheId) {
        FicheStatistiquesResponse reponse = ficheService.consulterStatistiques(
                CurrentUser.getId(), ficheId);
        return ResponseEntity.ok(reponse);
    }
}