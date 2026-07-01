package com.mboalink.grossiste.controller;

import com.mboalink.auth.security.CurrentUser;
import com.mboalink.grossiste.dto.CreerProduitRequest;
import com.mboalink.grossiste.dto.ProduitResponse;
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

    @PostMapping("/{ficheId}/produits")
    public ResponseEntity<ProduitResponse> ajouterProduit(
            @PathVariable UUID ficheId,
            @Valid @RequestBody CreerProduitRequest req) {
        ProduitResponse reponse = produitService.ajouterProduit(
                CurrentUser.getId(), ficheId, req);
        return ResponseEntity.ok(reponse);
    }
}