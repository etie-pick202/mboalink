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

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/grossistes")
@RequiredArgsConstructor
public class ProduitGrossisteController {

    private final ProduitGrossisteService produitService;
    private final SupabaseStorageService supabaseService;
    private final FicheGrossisteRepository ficheRepository;

    // ← ROUTE EXISTANTE, pas touchée
    @PostMapping("/{ficheId}/produits")
    public ResponseEntity<ProduitResponse> ajouterProduit(
            @PathVariable UUID ficheId,
            @Valid @RequestBody CreerProduitRequest req) {
        ProduitResponse reponse = produitService.ajouterProduit(
                CurrentUser.getId(), ficheId, req);
        return ResponseEntity.ok(reponse);
    }

    // ← NOUVELLE ROUTE uniquement
    @PostMapping("/{ficheId}/produits/upload-url")
    public ResponseEntity<UploadUrlResponse> genererUrlUploadProduit(
            @PathVariable UUID ficheId,
            @Valid @RequestBody UploadUrlRequest req) {

        // Vérifier que la fiche appartient à l'utilisateur connecté
        ficheRepository.findById(ficheId)
                .filter(f -> f.getUtilisateur().getId().equals(CurrentUser.getId()))
                .orElseThrow(() -> new IllegalStateException("Fiche introuvable ou accès refusé."));

        // Construire le chemin de l'image dans le bucket
        String filePath = "produits/" + ficheId + "/"
                + UUID.randomUUID() + "." + req.getExtension();

        // Générer l'URL signée (valable 5 minutes)
        String uploadUrl = supabaseService.genererUrlUpload(filePath, 300);

        return ResponseEntity.ok(UploadUrlResponse.builder()
                .uploadUrl(uploadUrl)
                .filePath(filePath)
                .expiresIn(300)
                .build());
    }
}