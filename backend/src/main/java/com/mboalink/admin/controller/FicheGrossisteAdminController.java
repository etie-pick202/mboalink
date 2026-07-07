package com.mboalink.admin.controller;

import com.mboalink.admin.dto.ValidationFicheDTO;
import com.mboalink.admin.service.FicheGrossisteAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin/validations")
@RequiredArgsConstructor
public class FicheGrossisteAdminController {

    private final FicheGrossisteAdminService ficheGrossisteAdminService;

    @GetMapping
    public ResponseEntity<List<ValidationFicheDTO>> getValidationsEnAttente() {
        return ResponseEntity.ok(ficheGrossisteAdminService.getValidationsEnAttente());
    }

    @GetMapping("/total")
    public ResponseEntity<Map<String, Long>> getTotal() {
        return ResponseEntity.ok(Map.of("total", ficheGrossisteAdminService.countValidationsEnAttente()));
    }

    @PatchMapping("/documents/{id}/approuver")
    public ResponseEntity<Map<String, String>> approuverDocument(
            @PathVariable UUID id,
            @RequestBody(required = false) Map<String, String> body) {
        String commentaire = body != null ? body.get("commentaireAdmin") : null;
        ficheGrossisteAdminService.approuverDocument(id, commentaire);
        return ResponseEntity.ok(Map.of("message", "Document approuvé."));
    }

    @PatchMapping("/documents/{id}/rejeter")
    public ResponseEntity<Map<String, String>> rejeterDocument(
            @PathVariable UUID id,
            @RequestBody(required = false) Map<String, String> body) {
        String commentaire = body != null ? body.get("commentaireAdmin") : null;
        ficheGrossisteAdminService.rejeterDocument(id, commentaire);
        return ResponseEntity.ok(Map.of("message", "Document rejeté."));
    }

    @PatchMapping("/{id}/valider")
    public ResponseEntity<Map<String, String>> validerFiche(@PathVariable UUID id) {
        ficheGrossisteAdminService.validerFiche(id);
        return ResponseEntity.ok(Map.of("message", "Fiche validée avec succès."));
    }

    @PatchMapping("/{id}/rejeter")
    public ResponseEntity<Map<String, String>> rejeterFiche(@PathVariable UUID id) {
        ficheGrossisteAdminService.rejeterFiche(id);
        return ResponseEntity.ok(Map.of("message", "Fiche rejetée."));
    }
}