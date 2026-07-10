package com.mboalink.payment.controller;

import com.mboalink.payment.dto.CertificationPremiumRequestDTO;
import com.mboalink.payment.dto.CertificationPremiumResponseDTO;
import com.mboalink.payment.service.CertificationPremiumService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/certifications-premium")
@RequiredArgsConstructor
@Slf4j
public class CertificationPremiumController {

    private final CertificationPremiumService certificationService;

    // POST /api/v1/certifications-premium — activer après paiement réussi
    @PostMapping
    public ResponseEntity<?> demanderCertification(@Valid @RequestBody CertificationPremiumRequestDTO request) {
        log.info("[CERTIFICATION] Demande - FicheGrossiste: {}", request.getFicheGrossisteId());
        CertificationPremiumResponseDTO response = certificationService.demanderCertification(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "success", true,
                "message", "Certification activée avec succès",
                "data", response
        ));
    }

    // GET /api/v1/certifications-premium/{ficheGrossisteId} — statut de certification
    @GetMapping("/{ficheGrossisteId}")
    public ResponseEntity<?> consulterCertification(@PathVariable UUID ficheGrossisteId) {
        return certificationService.consulterCertification(ficheGrossisteId)
                .<ResponseEntity<?>>map(dto -> ResponseEntity.ok(Map.of("success", true, "data", dto)))
                .orElseGet(() -> ResponseEntity.ok(Map.of("success", true, "data", (Object) null)));
    }
}
