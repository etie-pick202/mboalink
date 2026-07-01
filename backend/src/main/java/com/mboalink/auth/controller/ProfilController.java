package com.mboalink.auth.controller;

import com.mboalink.auth.dto.ModifierProfilRequest;
import com.mboalink.auth.dto.ProfilResponseDto;
import com.mboalink.auth.security.CurrentUser;
import com.mboalink.auth.service.ProfilService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/profil")
@RequiredArgsConstructor
public class ProfilController {

    private final ProfilService profilService;

    @GetMapping
    public ResponseEntity<ProfilResponseDto> consulterProfil() {
        return ResponseEntity.ok(profilService.consulterProfil(CurrentUser.getId()));
    }

    @PutMapping
    public ResponseEntity<ProfilResponseDto> modifierProfil(
            @Valid @RequestBody ModifierProfilRequest req) {
        return ResponseEntity.ok(profilService.modifierProfil(CurrentUser.getId(), req));
    }
}