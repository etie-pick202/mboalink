package com.mboalink.payment.controller;

import com.mboalink.payment.dto.PlanResponseDTO;
import com.mboalink.payment.repository.PlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Catalogue des plans d'abonnement — endpoint additif, ne remplace aucune
 * route existante. AbonnementController continue de fonctionner tel quel ;
 * le catalogue sert seulement à alimenter dynamiquement l'app au lieu de
 * prix codés en dur côté client.
 */
@RestController
@RequestMapping("/api/v1/plans")
@RequiredArgsConstructor
public class PlanController {

    private final PlanRepository planRepository;

    // GET /api/v1/plans?role=GROSSISTE
    @GetMapping
    public ResponseEntity<List<PlanResponseDTO>> lister(@RequestParam String role) {
        List<PlanResponseDTO> plans = planRepository
                .findByRoleCibleAndEstActifTrueOrderByOrdreAffichageAsc(role.toUpperCase())
                .stream()
                .map(PlanResponseDTO::depuis)
                .toList();
        return ResponseEntity.ok(plans);
    }
}
