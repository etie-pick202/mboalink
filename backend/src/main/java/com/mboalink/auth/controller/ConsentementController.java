package com.mboalink.auth.controller;

import com.mboalink.auth.dto.ConsentementResponseDto;
import com.mboalink.auth.dto.MettreAJourConsentementRequest;
import com.mboalink.auth.security.CurrentUser;
import com.mboalink.auth.service.ConsentementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/consentements")
@RequiredArgsConstructor
public class ConsentementController {

    private final ConsentementService consentementService;

    @GetMapping
    public ResponseEntity<ConsentementResponseDto> consulter() {
        return ResponseEntity.ok(consentementService.consulter(CurrentUser.getId()));
    }

    @PutMapping
    public ResponseEntity<ConsentementResponseDto> mettreAJour(
            @Valid @RequestBody MettreAJourConsentementRequest req) {
        return ResponseEntity.ok(consentementService.mettreAJour(CurrentUser.getId(), req));
    }
}