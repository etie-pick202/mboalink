package com.mboalink.admin.controller;

import com.mboalink.admin.dto.SignalementResponseDTO;
import com.mboalink.admin.service.SignalementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin/signalements")
@RequiredArgsConstructor
public class SignalementController {

    private final SignalementService signalementService;

    @GetMapping
    public ResponseEntity<List<SignalementResponseDTO>> getEnAttente() {
        return ResponseEntity.ok(signalementService.getSignalementsEnAttente());
    }

    @PatchMapping("/{id}/conserver")
    public ResponseEntity<SignalementResponseDTO> conserver(
            @PathVariable UUID id,
            @RequestBody(required = false) String commentaireAdmin) {
        return ResponseEntity.ok(signalementService.conserver(id, commentaireAdmin));
    }

    @PatchMapping("/{id}/supprimer")
    public ResponseEntity<SignalementResponseDTO> supprimer(
            @PathVariable UUID id,
            @RequestBody(required = false) String commentaireAdmin) {
        return ResponseEntity.ok(signalementService.supprimer(id, commentaireAdmin));
    }
}