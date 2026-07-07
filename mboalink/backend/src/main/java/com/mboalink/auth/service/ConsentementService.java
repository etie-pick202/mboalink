package com.mboalink.auth.service;

import com.mboalink.auth.dto.ConsentementResponseDto;
import com.mboalink.auth.dto.MettreAJourConsentementRequest;
import com.mboalink.auth.entity.Consentement;
import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.exception.AuthException;
import com.mboalink.auth.repository.ConsentementRepository;
import com.mboalink.auth.repository.UtilisateurRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ConsentementService {

    private final ConsentementRepository consentementRepo;
    private final UtilisateurRepository utilisateurRepo;

    @Transactional(readOnly = true)
    public ConsentementResponseDto consulter(UUID utilisateurId) {
        Consentement c = consentementRepo.findByUtilisateurId(utilisateurId)
                .orElseGet(() -> creerParDefaut(utilisateurId));
        return versDto(c);
    }

    @Transactional
    public ConsentementResponseDto mettreAJour(UUID utilisateurId, MettreAJourConsentementRequest req) {
        Consentement c = consentementRepo.findByUtilisateurId(utilisateurId)
                .orElseGet(() -> creerParDefaut(utilisateurId));

        if (req.getTrackingAccepte() != null) {
            c.setTrackingAccepte(req.getTrackingAccepte());
        }
        if (req.getNotificationsAcceptees() != null) {
            c.setNotificationsAcceptees(req.getNotificationsAcceptees());
        }
        if (req.getMarketingAccepte() != null) {
            c.setMarketingAccepte(req.getMarketingAccepte());
        }
        if (req.getConditionsAcceptees() != null) {
            c.setConditionsAcceptees(req.getConditionsAcceptees());
        }
        if (req.getVersionConditions() != null) {
            c.setVersionConditions(req.getVersionConditions());
        }

        c.setMisAJourLe(LocalDateTime.now());
        consentementRepo.save(c);
        log.info("[CONSENTEMENT] Mis à jour : {}", utilisateurId);
        return versDto(c);
    }

    private Consentement creerParDefaut(UUID utilisateurId) {
        Utilisateur u = utilisateurRepo.findById(utilisateurId)
                .orElseThrow(() -> new AuthException("Utilisateur introuvable."));

        Consentement c = Consentement.builder()
                .utilisateur(u)
                .build();
        return consentementRepo.save(c);
    }

    private ConsentementResponseDto versDto(Consentement c) {
        return ConsentementResponseDto.builder()
                .trackingAccepte(c.getTrackingAccepte())
                .notificationsAcceptees(c.getNotificationsAcceptees())
                .marketingAccepte(c.getMarketingAccepte())
                .conditionsAcceptees(c.getConditionsAcceptees())
                .versionConditions(c.getVersionConditions())
                .misAJourLe(c.getMisAJourLe())
                .build();
    }
}