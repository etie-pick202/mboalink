package com.mboalink.admin.controller;

import com.mboalink.admin.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/utilisateurs/total")
    public ResponseEntity<Map<String, Long>> getTotalUtilisateurs() {
        return ResponseEntity.ok(Map.of("total", dashboardService.countTotalUtilisateurs()));
    }

    @GetMapping("/grossistes/total")
    public ResponseEntity<Map<String, Long>> getTotalGrossistes() {
        return ResponseEntity.ok(Map.of("total", dashboardService.countGrossistes()));
    }

    @GetMapping("/utilisateurs-clients/total")
    public ResponseEntity<Map<String, Long>> getTotalUtilisateursClients() {
        return ResponseEntity.ok(Map.of("total", dashboardService.countUtilisateursClients()));
    }

    @GetMapping("/deverrouillages/total")
    public ResponseEntity<Map<String, Long>> getTotalDeverrouillages() {
        return ResponseEntity.ok(Map.of("total", dashboardService.countUtilisateursAyantDeverrouilleCoordonnees()));
    }

    @GetMapping("/reinitialisations-note/total")
    public ResponseEntity<Map<String, Long>> getTotalReinitialisationsNote() {
        return ResponseEntity.ok(Map.of("total", dashboardService.countDemandesReinitialisationNote()));
    }
}