package com.mboalink.search.controller;

import com.mboalink.auth.security.CurrentUser;
import com.mboalink.grossiste.dto.FicheResponse;
import com.mboalink.search.service.FavoriService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/favoris")
@RequiredArgsConstructor
public class FavoriController {

    private final FavoriService favoriService;

    // GET /api/v1/favoris → mes fiches favorites
    @GetMapping
    public ResponseEntity<List<FicheResponse>> listerMesFavoris() {
        return ResponseEntity.ok(favoriService.listerMesFavoris(CurrentUser.getId()));
    }

    // GET /api/v1/favoris/{ficheId}/statut → est-ce déjà un favori ?
    @GetMapping("/{ficheId}/statut")
    public ResponseEntity<Map<String, Boolean>> statut(@PathVariable UUID ficheId) {
        boolean estFavori = favoriService.estFavori(CurrentUser.getId(), ficheId);
        return ResponseEntity.ok(Map.of("estFavori", estFavori));
    }

    // POST /api/v1/favoris/{ficheId} → ajouter aux favoris
    @PostMapping("/{ficheId}")
    public ResponseEntity<Map<String, String>> ajouter(@PathVariable UUID ficheId) {
        favoriService.ajouter(CurrentUser.getId(), ficheId);
        return ResponseEntity.ok(Map.of("message", "Ajouté aux favoris."));
    }

    // DELETE /api/v1/favoris/{ficheId} → retirer des favoris
    @DeleteMapping("/{ficheId}")
    public ResponseEntity<Map<String, String>> retirer(@PathVariable UUID ficheId) {
        favoriService.retirer(CurrentUser.getId(), ficheId);
        return ResponseEntity.ok(Map.of("message", "Retiré des favoris."));
    }
}
