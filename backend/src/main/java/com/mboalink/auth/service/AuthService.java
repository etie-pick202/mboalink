package com.mboalink.auth.service;

import com.mboalink.auth.config.JwtTokenProvider;
import com.mboalink.auth.dto.*;
import com.mboalink.auth.entity.RefreshToken;
import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.enums.Role;
import com.mboalink.auth.enums.TypeOtp;
import com.mboalink.auth.exception.AuthException;
import com.mboalink.auth.repository.RefreshTokenRepository;
import com.mboalink.auth.repository.UtilisateurRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UtilisateurRepository utilisateurRepo;
    private final RefreshTokenRepository refreshTokenRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final OtpService otpService;

    @Value("${jwt.refresh-expiration:2592000000}")
    private long refreshExpiration;

    @Transactional
    public AuthResponseDto inscrire(InscriptionRequest req) {
        if (req.getEmail() == null && req.getTelephone() == null) {
            throw new AuthException("Fournissez un email ou un numéro de téléphone.");
        }
        if (req.getEmail() != null && utilisateurRepo.existsByEmail(req.getEmail())) {
            throw new AuthException("Un compte existe déjà avec cet email.");
        }
        if (req.getTelephone() != null && utilisateurRepo.existsByTelephone(req.getTelephone())) {
            throw new AuthException("Un compte existe déjà avec ce numéro de téléphone.");
        }

        Role role = resoudreRole(req.getRole());

        Utilisateur utilisateur = Utilisateur.builder()
                .nom(req.getNom())
                .prenom(req.getPrenom())
                .email(req.getEmail())
                .telephone(req.getTelephone())
                .motDePasseHash(passwordEncoder.encode(req.getMotDePasse()))
                .role(role)
                .build();
        utilisateurRepo.save(utilisateur);
        log.info("[AUTH] Nouveau compte créé : {} ({})", utilisateur.getId(), role);

        if (req.getEmail() != null) {
            otpService.genererEtEnvoyer(req.getEmail(), TypeOtp.INSCRIPTION_EMAIL);
        } else {
            otpService.genererEtEnvoyer(req.getTelephone(), TypeOtp.INSCRIPTION_SMS);
        }

        return AuthResponseDto.builder()
                .utilisateurId(utilisateur.getId().toString())
                .role(role.name())
                .nom(utilisateur.getNom())
                .prenom(utilisateur.getPrenom())
                .email(utilisateur.getEmail())
                .telephone(utilisateur.getTelephone())
                .emailVerifie(false)
                .telephoneVerifie(false)
                .message("Compte créé. Vérifiez votre " +
                        (req.getEmail() != null ? "email" : "téléphone") +
                        " pour activer votre compte.")
                .build();
    }

    @Transactional
    public AuthResponseDto verifierOtp(OtpVerificationRequest req) {
        TypeOtp type = parseTypeOtp(req.getType());
        otpService.verifier(req.getCible(), req.getCode(), type);

        Utilisateur utilisateur = trouverParCible(req.getCible());

        if (type == TypeOtp.INSCRIPTION_EMAIL) {
            utilisateur.setEmailVerifie(true);
        } else if (type == TypeOtp.INSCRIPTION_SMS) {
            utilisateur.setTelephoneVerifie(true);
        }
        utilisateurRepo.save(utilisateur);

        log.info("[AUTH] Compte vérifié : {}", utilisateur.getId());
        return creerReponseAvecTokens(utilisateur, "Compte activé avec succès. Bienvenue !");
    }

    @Transactional
    public AuthResponseDto connecter(ConnexionRequest req) {
        Utilisateur utilisateur = trouverParIdentifiant(req.getIdentifiant());

        if (!utilisateur.getEstActif()) {
            throw new AuthException("Ce compte a été supprimé ou suspendu. Contactez le support.");
        }
        if (utilisateur.getMotDePasseHash() == null ||
                !passwordEncoder.matches(req.getMotDePasse(), utilisateur.getMotDePasseHash())) {
            throw new AuthException("Identifiants incorrects.");
        }

        String message = null;
        if (Boolean.FALSE.equals(utilisateur.getEmailVerifie()) &&
                Boolean.FALSE.equals(utilisateur.getTelephoneVerifie())) {
            message = "Votre compte n'est pas encore vérifié.";
        }

        log.info("[AUTH] Connexion : {}", utilisateur.getId());
        return creerReponseAvecTokens(utilisateur, message);
    }

    @Transactional
    public AuthResponseDto rafraichirToken(RefreshTokenRequest req) {
        RefreshToken rt = refreshTokenRepo.findByToken(req.getRefreshToken())
                .orElseThrow(() -> new AuthException("Refresh token invalide."));

        if (rt.getRevoque() || rt.getExpirationLe().isBefore(LocalDateTime.now())) {
            throw new AuthException("Refresh token expiré. Reconnectez-vous.");
        }

        rt.setRevoque(true);
        refreshTokenRepo.save(rt);

        Utilisateur utilisateur = rt.getUtilisateur();
        log.info("[AUTH] Refresh token pour : {}", utilisateur.getId());
        return creerReponseAvecTokens(utilisateur, null);
    }

    @Transactional
    public void deconnecter(LogoutRequest req) {
        RefreshToken rt = refreshTokenRepo.findByToken(req.getRefreshToken())
                .orElseThrow(() -> new AuthException("Refresh token invalide."));

        rt.setRevoque(true);
        refreshTokenRepo.save(rt);
        log.info("[AUTH] Déconnexion : {}", rt.getUtilisateur().getId());
    }

    @Transactional
    public void supprimerCompte(UUID utilisateurId, SupprimerCompteRequest req) {
        Utilisateur u = utilisateurRepo.findById(utilisateurId)
                .orElseThrow(() -> new AuthException("Utilisateur introuvable."));

        if (u.getMotDePasseHash() == null ||
                !passwordEncoder.matches(req.getMotDePasse(), u.getMotDePasseHash())) {
            throw new AuthException("Mot de passe incorrect.");
        }

        u.setEstActif(false);
        u.setSupprimeLe(LocalDateTime.now());
        utilisateurRepo.save(u);

        // Révoquer tous les tokens actifs
        refreshTokenRepo.revoquerTous(u);

        log.info("[AUTH] Compte désactivé (soft delete) : {}", utilisateurId);
    }

    @Transactional
    public void demanderReinitialisationMotDePasse(MotDePasseOublieRequest req) {
        Utilisateur utilisateur = trouverParIdentifiant(req.getIdentifiant());
        String cible = req.getIdentifiant().contains("@")
                ? utilisateur.getEmail()
                : utilisateur.getTelephone();
        otpService.genererEtEnvoyer(cible, TypeOtp.RESET_MOT_DE_PASSE);
        log.info("[AUTH] Reset mot de passe pour : {}", utilisateur.getId());
    }

    @Transactional
    public void reinitialiserMotDePasse(ReinitialisationMotDePasseRequest req) {
        otpService.verifier(req.getCible(), req.getCodeOtp(), TypeOtp.RESET_MOT_DE_PASSE);
        Utilisateur utilisateur = trouverParCible(req.getCible());
        utilisateur.setMotDePasseHash(passwordEncoder.encode(req.getNouveauMotDePasse()));
        utilisateurRepo.save(utilisateur);
        refreshTokenRepo.revoquerTous(utilisateur);
        log.info("[AUTH] Mot de passe réinitialisé : {}", utilisateur.getId());
    }

    @Transactional
    public void renvoyerOtp(RenvoyerOtpRequest req) {
        TypeOtp type = parseTypeOtp(req.getType());
        otpService.genererEtEnvoyer(req.getCible(), type);
    }

    private AuthResponseDto creerReponseAvecTokens(Utilisateur u, String message) {
        String roleSpring = "ROLE_" + u.getRole().name();
        String accessToken = jwtTokenProvider.generateToken(
                u.getId().toString(), roleSpring, u.getEmail());

        RefreshToken rt = RefreshToken.builder()
                .utilisateur(u)
                .token(UUID.randomUUID().toString())
                .expirationLe(LocalDateTime.now().plusSeconds(refreshExpiration / 1000))
                .build();
        refreshTokenRepo.save(rt);

        return AuthResponseDto.builder()
                .accessToken(accessToken)
                .refreshToken(rt.getToken())
                .role(u.getRole().name())
                .utilisateurId(u.getId().toString())
                .nom(u.getNom())
                .prenom(u.getPrenom())
                .email(u.getEmail())
                .telephone(u.getTelephone())
                .emailVerifie(u.getEmailVerifie())
                .telephoneVerifie(u.getTelephoneVerifie())
                .message(message)
                .build();
    }

    private Utilisateur trouverParIdentifiant(String identifiant) {
        if (identifiant.contains("@")) {
            return utilisateurRepo.findByEmail(identifiant)
                    .orElseThrow(() -> new AuthException("Identifiants incorrects."));
        }
        return utilisateurRepo.findByTelephone(identifiant)
                .orElseThrow(() -> new AuthException("Identifiants incorrects."));
    }

    private Utilisateur trouverParCible(String cible) {
        if (cible.contains("@")) {
            return utilisateurRepo.findByEmail(cible)
                    .orElseThrow(() -> new AuthException("Utilisateur introuvable."));
        }
        return utilisateurRepo.findByTelephone(cible)
                .orElseThrow(() -> new AuthException("Utilisateur introuvable."));
    }

    private Role resoudreRole(String roleStr) {
        if (roleStr == null) return Role.UTILISATEUR;
        return switch (roleStr.toUpperCase()) {
            case "GROSSISTE" -> Role.GROSSISTE;
            default -> Role.UTILISATEUR;
        };
    }

    private TypeOtp parseTypeOtp(String type) {
        try {
            return TypeOtp.valueOf(type.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new AuthException("Type OTP invalide : " + type);
        }
    }
}