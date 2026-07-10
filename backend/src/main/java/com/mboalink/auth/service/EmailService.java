package com.mboalink.auth.service;

import com.mboalink.auth.enums.TypeOtp;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

/**
 * Envoi des e-mails OTP.
 *
 * Deux canaux, choisis à l'exécution :
 *  - API HTTP transactionnelle (Brevo par défaut) dès qu'une clé
 *    {@code mail.api.key} est définie. C'est le canal à utiliser en
 *    production sur Render : les ports SMTP sortants (25/465/587) y sont
 *    bloqués, mais le HTTPS (443) passe.
 *  - Repli SMTP (JavaMailSender / spring.mail.*) sinon — pratique en
 *    développement local où le SMTP n'est pas bloqué.
 *
 * L'envoi reste {@code @Async} et n'échoue jamais bruyamment : un échec de
 * livraison est journalisé mais ne casse pas le parcours d'inscription
 * (le code reste vérifiable côté serveur).
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;
    private final RestTemplate restTemplate;

    @Value("${mboalink.mail.from:noreply@mboalink.cm}")
    private String mailFrom;

    @Value("${mboalink.mail.from-name:MboaLink}")
    private String mailFromName;

    /** Clé API du fournisseur HTTP (Brevo). Vide → repli SMTP. */
    @Value("${mail.api.key:}")
    private String apiKey;

    @Value("${mail.api.url:https://api.brevo.com/v3/smtp/email}")
    private String apiUrl;

    @Async
    public void envoyerOtp(String destinataire, String code, TypeOtp type) {
        final String sujet = sujetOtp(type);
        final String corps = corpsOtp(code, type);

        if (apiKey != null && !apiKey.isBlank()) {
            envoyerViaApi(destinataire, sujet, corps);
        } else {
            envoyerViaSmtp(destinataire, sujet, corps);
        }
    }

    private void envoyerViaApi(String destinataire, String sujet, String corps) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("api-key", apiKey);
            headers.set("accept", "application/json");

            Map<String, Object> body = Map.of(
                    "sender", Map.of("email", mailFrom, "name", mailFromName),
                    "to", List.of(Map.of("email", destinataire)),
                    "subject", sujet,
                    "textContent", corps
            );

            restTemplate.postForObject(apiUrl, new HttpEntity<>(body, headers), Map.class);
            log.info("[EMAIL] OTP envoyé à {} via API", destinataire);
        } catch (Exception e) {
            log.error("[EMAIL] Échec envoi OTP (API) à {} : {}", destinataire, e.getMessage());
        }
    }

    private void envoyerViaSmtp(String destinataire, String sujet, String corps) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(mailFrom);
            message.setTo(destinataire);
            message.setSubject(sujet);
            message.setText(corps);
            mailSender.send(message);
            log.info("[EMAIL] OTP envoyé à {} via SMTP", destinataire);
        } catch (Exception e) {
            log.error("[EMAIL] Échec envoi OTP (SMTP) à {} : {}", destinataire, e.getMessage());
        }
    }

    private String sujetOtp(TypeOtp type) {
        return switch (type) {
            case INSCRIPTION_EMAIL  -> "[MboaLink] Confirmez votre adresse email";
            case INSCRIPTION_SMS    -> "[MboaLink] Vérification de compte";
            case RESET_MOT_DE_PASSE -> "[MboaLink] Réinitialisation de mot de passe";
            case CONNEXION_2FA      -> "[MboaLink] Code de connexion";
        };
    }

    private String corpsOtp(String code, TypeOtp type) {
        String contexte = switch (type) {
            case INSCRIPTION_EMAIL  -> "confirmer votre adresse email";
            case INSCRIPTION_SMS    -> "vérifier votre compte";
            case RESET_MOT_DE_PASSE -> "réinitialiser votre mot de passe";
            case CONNEXION_2FA      -> "vous connecter";
        };

        return """
            Bonjour,

            Votre code MboaLink pour %s :

                   %s

            Ce code expire dans 10 minutes.
            Si vous n'avez pas fait cette demande, ignorez cet email.

            — L'équipe MboaLink 🇨🇲
            """.formatted(contexte, code);
    }
}
