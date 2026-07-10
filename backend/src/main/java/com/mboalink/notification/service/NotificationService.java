package com.mboalink.notification.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.ConsentementRepository;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.commun.exception.AccesRefuseException;
import com.mboalink.commun.exception.RessourceIntrouvableException;
import com.mboalink.notification.dto.NotificationResponseDTO;
import com.mboalink.notification.entity.Notification;
import com.mboalink.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final ConsentementRepository consentementRepository;

    /** Créer une notification pour un utilisateur donné — best-effort, ne
     *  doit jamais faire échouer l'action métier qui la déclenche. Respecte
     *  le consentement "notifications" (même règle que ComportementService
     *  pour le tracking) : pas de ligne de consentement ou refus → silence. */
    @Transactional
    public void creer(Utilisateur utilisateur, String type, String titre, String message, String referenceId) {
        if (!aConsentementNotifications(utilisateur)) return;
        try {
            Notification notification = Notification.builder()
                    .utilisateur(utilisateur)
                    .type(type)
                    .titre(titre)
                    .message(message)
                    .referenceId(referenceId)
                    .build();
            notificationRepository.save(notification);
        } catch (Exception e) {
            log.error("[NOTIFICATION] Échec création notification type={} pour utilisateur={}",
                    type, utilisateur.getId(), e);
        }
    }

    @Transactional
    public void creerPourUtilisateurId(UUID utilisateurId, String type, String titre, String message, String referenceId) {
        utilisateurRepository.findById(utilisateurId).ifPresent(u -> creer(u, type, titre, message, referenceId));
    }

    private boolean aConsentementNotifications(Utilisateur utilisateur) {
        return consentementRepository.findByUtilisateurId(utilisateur.getId())
                .map(c -> Boolean.TRUE.equals(c.getNotificationsAcceptees()))
                .orElse(false);
    }

    @Transactional(readOnly = true)
    public List<NotificationResponseDTO> listerMesNotifications(UUID utilisateurId) {
        return notificationRepository.findByUtilisateurIdOrderByCreeLeDesc(utilisateurId).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public long compterNonLues(UUID utilisateurId) {
        return notificationRepository.countByUtilisateurIdAndLuLeIsNull(utilisateurId);
    }

    @Transactional
    public void marquerCommeLue(UUID utilisateurId, UUID notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RessourceIntrouvableException("Notification introuvable."));
        if (!notification.getUtilisateur().getId().equals(utilisateurId)) {
            throw new AccesRefuseException("Cette notification ne vous appartient pas.");
        }
        if (notification.getLuLe() == null) {
            notification.setLuLe(LocalDateTime.now());
            notificationRepository.save(notification);
        }
    }

    @Transactional
    public void marquerToutesCommeLues(UUID utilisateurId) {
        List<Notification> nonLues = notificationRepository.findByUtilisateurIdAndLuLeIsNull(utilisateurId);
        LocalDateTime maintenant = LocalDateTime.now();
        nonLues.forEach(n -> n.setLuLe(maintenant));
        notificationRepository.saveAll(nonLues);
    }

    private NotificationResponseDTO mapToDto(Notification n) {
        return NotificationResponseDTO.builder()
                .id(n.getId())
                .type(n.getType())
                .titre(n.getTitre())
                .message(n.getMessage())
                .referenceId(n.getReferenceId())
                .lu(n.getLuLe() != null)
                .creeLe(n.getCreeLe())
                .build();
    }
}
