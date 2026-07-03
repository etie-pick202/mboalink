package com.mboalink.admin.controller;

import com.mboalink.admin.dto.AvisSignaleResponseDTO;
import com.mboalink.admin.service.AvisSignaleService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/avis-signales")
@RequiredArgsConstructor
public class AvisSignaleController {

    private final AvisSignaleService avisSignaleService;

    @GetMapping
    public ResponseEntity<AvisSignaleResponseDTO> getAvisSignales() {
        return ResponseEntity.ok(avisSignaleService.getAvisSignales());
    }
}