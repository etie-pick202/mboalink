package com.mboalink.admin.controller;

import com.mboalink.admin.service.NotationAdminService;
import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.payment.dto.NotationResponseDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin/avis-signales")
@RequiredArgsConstructor
public class NotationAdminController {

    private final NotationAdminService notationAdminService;
    private final UtilisateurRepository utilisateurRepository;

    @GetMapping
    public ResponseEntity<List<NotationResponseDTO>> getAvisSignales() {
        return ResponseEntity.ok(notationAdminService.getAvisSignales());
    }

    @GetMapping("/total")
    public ResponseEntity<Map<String, Long>> getTotal() {
        return ResponseEntity.ok(Map.of("total", notationAdminService.countAvisSignales()));
    }

    @PatchMapping("/{id}/conserver")
    public ResponseEntity<Map<String, String>> conserver(
            @PathVariable UUID id,
            Authentication authentication) {
        Utilisateur admin = getAdminConnecte(authentication);
        notationAdminService.conserverAvis(id, admin);
        return ResponseEntity.ok(Map.of("message", "Avis conservé avec succès."));
    }

    @PatchMapping("/{id}/supprimer")
    public ResponseEntity<Map<String, String>> supprimer(
            @PathVariable UUID id,
            Authentication authentication) {
        Utilisateur admin = getAdminConnecte(authentication);
        notationAdminService.supprimerAvis(id, admin);
        return ResponseEntity.ok(Map.of("message", "Avis supprimé avec succès."));
    }

    private Utilisateur getAdminConnecte(Authentication authentication) {
        UUID adminId = UUID.fromString(authentication.getName());
        return utilisateurRepository.findById(adminId)
                .orElseThrow(() -> new RuntimeException("Admin introuvable"));
    }
}