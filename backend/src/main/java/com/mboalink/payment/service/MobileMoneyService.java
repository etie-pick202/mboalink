package com.mboalink.payment.service;

import com.mboalink.payment.entity.Transaction;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class MobileMoneyService {

    private final RestTemplate restTemplate;

    // MTN MoMo Configuration
    @Value("${mboalink.payment.mtn.api-key:#{null}}")
    private String mtnApiKey;

    @Value("${mboalink.payment.mtn.api-url:#{null}}")
    private String mtnApiUrl;

    @Value("${mboalink.payment.mtn.business-short-code:#{null}}")
    private String mtnBusinessShortCode;

    // Orange Money Configuration
    @Value("${mboalink.payment.orange.api-key:#{null}}")
    private String orangeApiKey;

    @Value("${mboalink.payment.orange.api-url:#{null}}")
    private String orangeApiUrl;

    @Value("${mboalink.payment.orange.merchant-id:#{null}}")
    private String orangeMerchantId;

    // ==================== MTN MoMo Methods ====================

    /**
     * Initiate MTN MoMo payment
     */
    public void initiatePaymentMTN(Transaction transaction) {
        log.info("Initiation paiement MTN MoMo pour transaction: {}", transaction.getId());

        try {
            String referenceId = transaction.getId().toString();

            // Build MTN API request
            Map<String, Object> request = new HashMap<>();
            request.put("amount", transaction.getMontant().toPlainString());
            request.put("currency", "XAF");
            request.put("externalId", referenceId);
            request.put("payer", Map.of(
                    "partyIdType", "MSISDN",
                    "partyId", normalizePhoneNumber(transaction.getNumeroTelephonePaiement())
            ));
            request.put("payerMessage", transaction.getDescription());
            request.put("payeeNote", "MboaLink Payment");

            // Call MTN API
            String mtnEndpoint = mtnApiUrl + "/v1_0/requesttopay";
            HttpHeaders headers = createMTNHeaders(referenceId);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

            try {
                var response = restTemplate.postForObject(mtnEndpoint, entity, Map.class);
                log.info("MTN MoMo response: {}", response);

                // Update transaction with external reference
                transaction.setReferenceExterne((String) response.get("financialTransactionId"));
                transaction.setStatut("EN_ATTENTE");
            } catch (Exception e) {
                log.error("Erreur appel API MTN MoMo: ", e);
                transaction.setStatut("ECHEC");
            }

        } catch (Exception e) {
            log.error("Erreur initiation MTN MoMo: ", e);
            throw new RuntimeException("Échec de l'initiation du paiement MTN MoMo", e);
        }
    }

    /**
     * Check MTN MoMo payment status
     */
    public void checkPaymentStatusMTN(Transaction transaction) {
        log.info("Vérification statut MTN MoMo pour transaction: {}", transaction.getId());

        try {
            String referenceId = transaction.getId().toString();
            String mtnEndpoint = mtnApiUrl + "/v1_0/requesttopay/" + transaction.getReferenceExterne();

            HttpHeaders headers = createMTNHeaders(referenceId);
            HttpEntity<String> entity = new HttpEntity<>(headers);

            var response = restTemplate.getForObject(mtnEndpoint, Map.class, entity);
            log.info("MTN status response: {}", response);

            String status = (String) response.get("status");
            if ("SUCCESSFUL".equals(status)) {
                transaction.setStatut("SUCCES");
                log.info("Paiement MTN réussi: {}", transaction.getId());
            } else if ("FAILED".equals(status)) {
                transaction.setStatut("ECHEC");
                log.warn("Paiement MTN échoué: {}", transaction.getId());
            }
            // EN_ATTENTE if PENDING

        } catch (Exception e) {
            log.error("Erreur vérification statut MTN: ", e);
        }
    }

    // ==================== Orange Money Methods ====================

    /**
     * Initiate Orange Money payment
     */
    public void initiatePaymentOrange(Transaction transaction) {
        log.info("Initiation paiement Orange Money pour transaction: {}", transaction.getId());

        try {
            String referenceId = transaction.getId().toString();

            // Build Orange API request
            Map<String, Object> request = new HashMap<>();
            request.put("amount", transaction.getMontant().toPlainString());
            request.put("currency", "XAF");
            request.put("orderId", referenceId);
            request.put("customerPhone", normalizePhoneNumber(transaction.getNumeroTelephonePaiement()));
            request.put("merchantId", orangeMerchantId);
            request.put("description", transaction.getDescription());

            // Call Orange API
            String orangeEndpoint = orangeApiUrl + "/payment/request";
            HttpHeaders headers = createOrangeHeaders();
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

            try {
                var response = restTemplate.postForObject(orangeEndpoint, entity, Map.class);
                log.info("Orange Money response: {}", response);

                // Update transaction with external reference
                transaction.setReferenceExterne((String) response.get("transactionId"));
                transaction.setStatut("EN_ATTENTE");
            } catch (Exception e) {
                log.error("Erreur appel API Orange Money: ", e);
                transaction.setStatut("ECHEC");
            }

        } catch (Exception e) {
            log.error("Erreur initiation Orange Money: ", e);
            throw new RuntimeException("Échec de l'initiation du paiement Orange Money", e);
        }
    }

    /**
     * Check Orange Money payment status
     */
    public void checkPaymentStatusOrange(Transaction transaction) {
        log.info("Vérification statut Orange Money pour transaction: {}", transaction.getId());

        try {
            String orangeEndpoint = orangeApiUrl + "/payment/status/" + transaction.getReferenceExterne();

            HttpHeaders headers = createOrangeHeaders();
            HttpEntity<String> entity = new HttpEntity<>(headers);

            var response = restTemplate.getForObject(orangeEndpoint, Map.class, entity);
            log.info("Orange status response: {}", response);

            String status = (String) response.get("status");
            if ("SUCCESS".equals(status)) {
                transaction.setStatut("SUCCES");
                log.info("Paiement Orange réussi: {}", transaction.getId());
            } else if ("FAILED".equals(status)) {
                transaction.setStatut("ECHEC");
                log.warn("Paiement Orange échoué: {}", transaction.getId());
            }
            // PENDING if still waiting

        } catch (Exception e) {
            log.error("Erreur vérification statut Orange: ", e);
        }
    }

    // ==================== Helper Methods ====================

    /**
     * Create MTN MoMo API headers
     */
    private HttpHeaders createMTNHeaders(String referenceId) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Bearer " + mtnApiKey);
        headers.set("X-Reference-Id", referenceId);
        headers.set("X-Target-Environment", "production");
        return headers;
    }

    /**
     * Create Orange Money API headers
     */
    private HttpHeaders createOrangeHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Bearer " + orangeApiKey);
        return headers;
    }

    /**
     * Normalize phone number (remove spaces, add country code if needed)
     * Cameroon: +237 or 237
     */
    private String normalizePhoneNumber(String phone) {
        // Remove spaces and special characters
        String cleaned = phone.replaceAll("[\\s\\-\\(\\)]", "");

        // Add country code if not present
        if (!cleaned.startsWith("237") && !cleaned.startsWith("+237")) {
            if (cleaned.startsWith("0")) {
                cleaned = "237" + cleaned.substring(1);
            } else {
                cleaned = "237" + cleaned;
            }
        }

        // Ensure format: 237XXXXXXXXX
        if (cleaned.startsWith("+")) {
            cleaned = cleaned.substring(1);
        }

        return cleaned;
    }

    /**
     * Validate phone number format
     */
    public boolean isValidPhoneNumber(String phone) {
        String normalized = normalizePhoneNumber(phone);
        // Cameroon numbers: 237 + 9 digits
        return normalized.matches("^237[0-9]{9}$");
    }
}
