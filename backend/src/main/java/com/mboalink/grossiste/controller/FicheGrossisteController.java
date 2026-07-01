package com.mboalink.grossiste.controller;

import com.mboalink.auth.security.CurrentUser;
import com.mboalink.grossiste.dto.CreerFicheRequest;
import com.mboalink.grossiste.dto.FicheResponse;
import com.mboalink.grossiste.service.FicheGrossisteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/grossistes")
@RequiredArgsConstructor
public class FicheGrossisteController {

    private final FicheGrossisteService ficheService;

    @PostMapping
    public ResponseEntity<FicheResponse> creerFiche(
            @Valid @RequestBody CreerFicheRequest req) {
        FicheResponse reponse = ficheService.creerFiche(CurrentUser.getId(), req);
        return ResponseEntity.ok(reponse);
    }
}