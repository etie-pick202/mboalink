package com.mboalink.grossiste.controller;

import com.mboalink.auth.security.CurrentUser;
import com.mboalink.commun.dto.UploadUrlRequest;
import com.mboalink.commun.dto.UploadUrlResponse;
import com.mboalink.commun.service.SupabaseStorageService;
import com.mboalink.grossiste.dto.CreerProduitRequest;
import com.mboalink.grossiste.dto.ProduitResponse;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.grossiste.service.ProduitGrossisteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/grossistes")
@RequiredArgsConstructor
public class ProduitGrossisteController {

    private final ProduitGrossisteService produitService;
    private final SupabaseStorageService supabaseService;
    private final FicheGrossisteRepository ficheRepository;

    @GetMapping("/{ficheId}/produits")
    public ResponseEntity<List<ProduitResponse>> listerProduits(
            @PathVariable UUID ficheId) {
        return ResponseEntity.ok(
                produitService.listerProduits(CurrentUser.getId(), ficheId));
    }

    @PostMapping("/{ficheId}/produits")
    public ResponseEntity<ProduitResponse> ajouterProduit(
            @PathVariable UUID ficheId,
            @Valid @RequestBody CreerProduitRequest req) {
        ProduitResponse reponse = produitService.ajouterProduit(
                CurrentUser.getId(), ficheId, req);
        return ResponseEntity.ok(reponse);
    }

    @PostMapping("/{ficheId}/produits/upload-url")
    public ResponseEntity<UploadUrlResponse> genererUrlUploadProduit(
            @PathVariable UUID ficheId,
            @Valid @RequestBody UploadUrlRequest req) {

        ficheRepository.findById(ficheId)
                .filter(f -> f.getUtilisateur().getId().equals(CurrentUser.getId()))
                .orElseThrow(() -> new IllegalStateException("Fiche introuvable ou accès refusé."));

        String filePath = "produits/" + ficheId + "/"
                + UUID.randomUUID() + "." + req.getExtension();

        String uploadUrl = supabaseService.genererUrlUpload(filePath, 300);

        return ResponseEntity.ok(UploadUrlResponse.builder()
                .uploadUrl(uploadUrl)
                .filePath(filePath)
                .expiresIn(300)
                .finalUrl(supabaseService.construireUrl(filePath))
                .build());
    }

    @PutMapping("/{ficheId}/produits/{produitId}")
    public ResponseEntity<ProduitResponse> modifierProduit(
            @PathVariable UUID ficheId,
            @PathVariable UUID produitId,
            @Valid @RequestBody CreerProduitRequest req) {
        ProduitResponse reponse = produitService.modifierProduit(
                CurrentUser.getId(), ficheId, produitId, req);
        return ResponseEntity.ok(reponse);
    }

    @DeleteMapping("/{ficheId}/produits/{produitId}")
    public ResponseEntity<Void> supprimerProduit(
            @PathVariable UUID ficheId,
            @PathVariable UUID produitId) {
        produitService.supprimerProduit(CurrentUser.getId(), ficheId, produitId);
        return ResponseEntity.noContent().build();
    }
}
