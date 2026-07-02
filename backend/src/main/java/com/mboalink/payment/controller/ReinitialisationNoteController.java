package com.mboalink.payment.controller;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.payment.dto.ReinitialisationNoteRequestDTO;
import com.mboalink.payment.dto.ReinitialisationNoteResponseDTO;
import com.mboalink.payment.service.ReinitialisationNoteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/reinitialisations-note")
@RequiredArgsConstructor
@Slf4j
public class ReinitialisationNoteController {

    private final ReinitialisationNoteService reinitialisationNoteService;
    private final UtilisateurRepository utilisateurRepository;

    /**
     * POST /api/v1/reinitialisations-note
     * Réinitialiser la note d'un grossiste après paiement réussi
     */
    @PostMapping
    public ResponseEntity<?> reinitialiserNote(
            @Valid @RequestBody ReinitialisationNoteRequestDTO request,
            Authentication authentication) {
        log.info("[REINIT_NOTE] Demande réinitialisation note - FicheGrossiste: {}",
                request.getFicheGrossisteId());

        try {
            String userId = authentication.getName();
            utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            ReinitialisationNoteResponseDTO response = reinitialisationNoteService
                    .reinitialiserNote(request);

            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                    "success", true,
                    "message", "Note réinitialisée avec succès",
                    "data", response
            ));

        } catch (Exception e) {
            log.error("[REINIT_NOTE] Erreur réinitialisation note: ", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    /**
     * GET /api/v1/reinitialisations-note/{ficheGrossisteId}
     * Récupérer l'historique des réinitialisations d'un grossiste
     */
    @GetMapping("/{ficheGrossisteId}")
    public ResponseEntity<?> getHistoriqueReinitialisations(
            @PathVariable UUID ficheGrossisteId,
            Authentication authentication) {
        log.info("[REINIT_NOTE] Récupération historique - FicheGrossiste: {}", ficheGrossisteId);

        try {
            String userId = authentication.getName();
            utilisateurRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            var historique = reinitialisationNoteService
                    .getHistoriqueReinitialisations(ficheGrossisteId);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "count", historique.size(),
                    "data", historique
            ));

        } catch (Exception e) {
            log.error("[REINIT_NOTE] Erreur récupération historique: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "success", false,
                    "message", "Erreur récupération historique réinitialisations"
            ));
        }
    }
}