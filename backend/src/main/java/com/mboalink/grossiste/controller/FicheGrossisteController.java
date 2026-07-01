package com.mboalink.grossiste.controller;

import com.mboalink.auth.security.CurrentUser;
import com.mboalink.grossiste.dto.CreerFicheRequest;
import com.mboalink.grossiste.dto.FicheResponse;
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

    // GET /api/v1/grossistes/{ficheId}  → détail d'une fiche avec ses produits
    @GetMapping("/{ficheId}")
    public ResponseEntity<FicheResponse> consulterFiche(@PathVariable UUID ficheId) {
        return ResponseEntity.ok(ficheService.consulterFiche(ficheId));
    }
}