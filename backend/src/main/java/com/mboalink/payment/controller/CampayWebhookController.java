package com.mboalink.payment.controller;

import com.mboalink.payment.service.CampayPaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@Slf4j
public class CampayWebhookController {

    private final CampayPaymentService campayPaymentService;

    /**
     * POST /api/v1/payments/webhook/campay
     * Campay webhook callback after payment is processed
     * This endpoint must be excluded from JWT authentication in SecurityConfig
     */
    @PostMapping("/webhook/campay")
    public ResponseEntity<?> handleCampayWebhook(@RequestBody Map<String, Object> webhookData) {
        log.info("[WEBHOOK] Campay webhook reçu: {}", webhookData);

        try {
            Map<String, Object> result = campayPaymentService.processWebhook(webhookData);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("[WEBHOOK] Erreur traitement webhook Campay: ", e);
            return ResponseEntity.ok(Map.of(
                    "success", false,
                    "message", "Erreur traitement webhook: " + e.getMessage()
            ));
        }
    }
}