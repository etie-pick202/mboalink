package com.mboalink.grossiste.controller;

import com.mboalink.auth.security.CurrentUser;
import com.mboalink.grossiste.dto.CoordonneesResponse;
import com.mboalink.grossiste.dto.DeverrouillerRequest;
import com.mboalink.grossiste.service.DeverrouillageService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/grossistes")
@RequiredArgsConstructor
public class DeverrouillageController {

    private final DeverrouillageService deverrouillageService;

    // POST /api/v1/grossistes/{ficheId}/deverrouiller  → payer et voir les coordonnées
    @PostMapping("/{ficheId}/deverrouiller")
    public ResponseEntity<CoordonneesResponse> deverrouiller(
            @PathVariable UUID ficheId,
            @Valid @RequestBody DeverrouillerRequest req) {
        CoordonneesResponse reponse = deverrouillageService.deverrouiller(
                CurrentUser.getId(), ficheId, req);
        return ResponseEntity.ok(reponse);
    }

    // GET /api/v1/grossistes/{ficheId}/deverrouille  → vérifier si déjà déverrouillé
    @GetMapping("/{ficheId}/deverrouille")
    public ResponseEntity<Map<String, Boolean>> verifierDeverrouillage(
            @PathVariable UUID ficheId) {
        boolean deverrouille = deverrouillageService.aDejaDeverrouille(
                CurrentUser.getId(), ficheId);
        return ResponseEntity.ok(Map.of("deverrouille", deverrouille));
    }
}