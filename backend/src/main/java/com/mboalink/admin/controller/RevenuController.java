package com.mboalink.admin.controller;

import com.mboalink.admin.dto.RevenuMensuelDTO;
import com.mboalink.admin.service.RevenuService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/dashboard/revenus")
@RequiredArgsConstructor
public class RevenuController {

    private final RevenuService revenuService;

    @GetMapping
    public ResponseEntity<List<RevenuMensuelDTO>> getRevenusDerniers4Mois() {
        return ResponseEntity.ok(revenuService.getRevenusDerniers4Mois());
    }
}