package com.mboalink.auth.service;

import com.mboalink.auth.enums.TypeOtp;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${mboalink.mail.from:noreply@mboalink.cm}")
    private String mailFrom;

    @Async
    public void envoyerOtp(String destinataire, String code, TypeOtp type) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(mailFrom);
            message.setTo(destinataire);
            message.setSubject(sujetOtp(type));
            message.setText(corpsOtp(code, type));
            mailSender.send(message);
            log.info("[EMAIL] OTP envoyé à {}", destinataire);
        } catch (Exception e) {
            log.error("[EMAIL] Échec envoi OTP à {} : {}", destinataire, e.getMessage());
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