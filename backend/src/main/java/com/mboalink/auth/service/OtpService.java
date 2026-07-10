package com.mboalink.auth.service;

import com.mboalink.auth.entity.OtpCode;
import com.mboalink.auth.enums.TypeOtp;
import com.mboalink.auth.exception.AuthException;
import com.mboalink.auth.repository.OtpCodeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class OtpService {

    private final OtpCodeRepository otpCodeRepository;
    private final EmailService emailService;
    private final SmsService smsService;

    @Value("${otp.mode:MOCK}")
    private String otpMode;

    @Value("${otp.expiration-minutes:10}")
    private int expirationMinutes;

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String MOCK_CODE = "123456";

    @Transactional
    public void genererEtEnvoyer(String cible, TypeOtp type) {
        otpCodeRepository.invaliderTousPourCible(cible, type);

        String code = genererCode();

        OtpCode otp = OtpCode.builder()
                .cible(cible)
                .code(code)
                .type(type)
                .expirationLe(LocalDateTime.now().plusMinutes(expirationMinutes))
                .build();
        otpCodeRepository.save(otp);

        envoyer(cible, code, type);
    }

    @Transactional
    public void verifier(String cible, String codeSoumis, TypeOtp type) {
        OtpCode otp = otpCodeRepository
                .findDernierValide(cible, type, LocalDateTime.now())
                .orElseThrow(() -> new AuthException(
                        "Code OTP invalide ou expiré. Demandez un nouveau code."));

        if (!otp.getCode().equals(codeSoumis)) {
            throw new AuthException("Code OTP incorrect.");
        }

        otp.setUtilise(true);
        otpCodeRepository.save(otp);
    }

    private String genererCode() {
        return switch (otpMode.toUpperCase()) {
            case "MOCK" -> {
                log.warn("[OTP MOCK] Code fixe utilisé — NE PAS utiliser en production !");
                yield MOCK_CODE;
            }
            default -> String.format("%06d", RANDOM.nextInt(1_000_000));
        };
    }

    /**
     * Le canal (email/SMS) est déterminé par la forme de la cible, pas
     * par otpMode : un email part par email, un numéro part par SMS —
     * même convention que trouverParCible/trouverParIdentifiant dans
     * AuthService. Ça permet à un même compte de recevoir son premier
     * code par email (par défaut) puis, sur demande, un renvoi par SMS
     * s'il a enregistré un numéro de téléphone — voir OtpScreen côté app.
     */
    private void envoyer(String cible, String code, TypeOtp type) {
        if ("MOCK".equalsIgnoreCase(otpMode)) {
            log.warn("[OTP MOCK] Code pour {} ({}) : {}", cible, type, code);
            return;
        }
        if (cible.contains("@")) {
            emailService.envoyerOtp(cible, code, type);
        } else {
            smsService.envoyerOtp(cible, code, type);
        }
    }
}