package com.mboalink.auth.service;

import com.mboalink.auth.enums.TypeOtp;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

/**
 * Envoi de SMS via Textbelt (https://textbelt.com) — API la plus simple
 * disponible sans inscription : la clé partagée "textbelt" donne 1 SMS
 * gratuit par jour et par IP, largement suffisant pour valider le
 * parcours OTP par SMS en développement/démo. Pour la production, il
 * suffit de définir SMS_PROVIDER_KEY avec une clé payante Textbelt (ou un
 * autre fournisseur compatible avec le même contrat POST) — aucun
 * changement de code requis.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class SmsService {

    private final RestTemplate restTemplate;

    @Value("${sms.provider.url:https://textbelt.com/text}")
    private String providerUrl;

    @Value("${sms.provider.key:textbelt}")
    private String providerKey;

    @Async
    public void envoyerOtp(String telephone, String code, TypeOtp type) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

            MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
            body.add("phone", formatNumero(telephone));
            body.add("message", messageOtp(code, type));
            body.add("key", providerKey);

            HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(body, headers);
            Map<?, ?> response = restTemplate.postForObject(providerUrl, entity, Map.class);

            if (response != null && Boolean.TRUE.equals(response.get("success"))) {
                log.info("[SMS] OTP envoyé à {} — quota restant : {}",
                        telephone, response.get("quotaRemaining"));
            } else {
                log.error("[SMS] Échec envoi OTP à {} — réponse : {}", telephone, response);
            }
        } catch (Exception e) {
            log.error("[SMS] Exception envoi OTP à {} : {}", telephone, e.getMessage());
        }
    }

    /** Textbelt attend un numéro avec indicatif pays (+237...). */
    private String formatNumero(String telephone) {
        String nettoye = telephone.replaceAll("[\\s\\-]", "");
        if (nettoye.startsWith("+")) return nettoye;
        if (nettoye.startsWith("237")) return "+" + nettoye;
        return "+237" + nettoye;
    }

    private String messageOtp(String code, TypeOtp type) {
        String contexte = switch (type) {
            case INSCRIPTION_SMS -> "vérifier votre compte";
            case RESET_MOT_DE_PASSE -> "réinitialiser votre mot de passe";
            case CONNEXION_2FA -> "vous connecter";
            case INSCRIPTION_EMAIL -> "confirmer votre compte";
        };
        return "MboaLink : votre code pour " + contexte + " est " + code
                + ". Expire dans 10 min.";
    }
}
