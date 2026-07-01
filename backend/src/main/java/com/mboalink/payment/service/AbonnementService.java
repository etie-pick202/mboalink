package com.mboalink.payment.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.payment.dto.AbonnementRequestDTO;
import com.mboalink.payment.dto.AbonnementResponseDTO;
import com.mboalink.payment.entity.Abonnement;
import com.mboalink.payment.entity.Transaction;
import com.mboalink.payment.repository.AbonnementRepository;
import com.mboalink.payment.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AbonnementService {

    private final AbonnementRepository abonnementRepository;
    private final TransactionRepository transactionRepository;

    /**
     * Create new subscription for a user
     */
    public AbonnementResponseDTO createSubscription(Utilisateur utilisateur, AbonnementRequestDTO request, Transaction transaction) {
        log.info("Création abonnement pour utilisateur: {} | Type: {}", utilisateur.getId(), request.getTypeAbonnement());

        // Check if user already has active subscription
        Optional<Abonnement> existing = abonnementRepository.findByUtilisateurAndStatut(utilisateur, "ACTIF");
        if (existing.isPresent()) {
            throw new RuntimeException("Utilisateur a déjà un abonnement actif");
        }

        // Calculate subscription dates based on type
        LocalDateTime dateDebut = LocalDateTime.now();
        LocalDateTime dateFin = calculateExpiryDate(dateDebut, request.getTypeAbonnement());

        Abonnement abonnement = Abonnement.builder()
                .utilisateur(utilisateur)
                .typeAbonnement(request.getTypeAbonnement()) // MENSUEL, TRIMESTRIEL, ANNUEL
                .montant(request.getMontant())
                .dateDebut(dateDebut)
                .dateFin(dateFin)
                .statut("ACTIF")
                .renouvellementAuto(request.getRenouvellementAuto())
                .rappelEnvoye(false)
                .transaction(transaction)
                .creeLe(LocalDateTime.now())
                .build();

        Abonnement saved = abonnementRepository.save(abonnement);
        log.info("Abonnement créé: {} | Expiry: {}", saved.getId(), dateFin);

        return mapToResponseDTO(saved);
    }

    /**
     * Renew subscription
     */
    public AbonnementResponseDTO renewSubscription(Utilisateur utilisateur, Transaction transaction) {
        log.info("Renouvellement abonnement pour utilisateur: {}", utilisateur.getId());

        Abonnement abonnement = abonnementRepository.findByUtilisateur(utilisateur)
                .orElseThrow(() -> new RuntimeException("Abonnement not found"));

        // Reset subscription dates
        LocalDateTime newDateDebut = LocalDateTime.now();
        LocalDateTime newDateFin = calculateExpiryDate(newDateDebut, abonnement.getTypeAbonnement());

        abonnement.setStatut("ACTIF");
        abonnement.setDateDebut(newDateDebut);
        abonnement.setDateFin(newDateFin);
        abonnement.setRappelEnvoye(false);
        abonnement.setTransaction(transaction);
        abonnement.setMisAJourLe(LocalDateTime.now());

        Abonnement saved = abonnementRepository.save(abonnement);
        return mapToResponseDTO(saved);
    }

    /**
     * Get subscription for user
     */
    public AbonnementResponseDTO getSubscription(Utilisateur utilisateur) {
        Abonnement abonnement = abonnementRepository.findByUtilisateur(utilisateur)
                .orElseThrow(() -> new RuntimeException("Abonnement not found"));
        return mapToResponseDTO(abonnement);
    }

    /**
     * Suspend subscription (when payment fails)
     */
    public void suspendSubscription(Utilisateur utilisateur) {
        log.warn("Suspension abonnement pour utilisateur: {}", utilisateur.getId());

        Abonnement abonnement = abonnementRepository.findByUtilisateur(utilisateur)
                .orElseThrow(() -> new RuntimeException("Abonnement not found"));

        abonnement.setStatut("SUSPENDU");
        abonnement.setMisAJourLe(LocalDateTime.now());
        abonnementRepository.save(abonnement);
    }

    /**
     * Auto-suspend expired subscriptions (scheduled job)
     */
    public void suspendExpiredSubscriptions() {
        log.info("Vérification abonnements expirés...");
        LocalDateTime now = LocalDateTime.now();
        List<Abonnement> expiredSubs = abonnementRepository.findByStatutAndDateFinBefore("ACTIF", now);

        for (Abonnement sub : expiredSubs) {
            if (sub.getRenouvellementAuto()) {
                log.info("Auto-renewal activé pour: {}", sub.getId());
                // Trigger auto-renewal payment
            } else {
                sub.setStatut("EXPIRE");
                abonnementRepository.save(sub);
                log.info("Abonnement expiré: {}", sub.getId());
            }
        }
    }

    /**
     * Send reminders for expiring subscriptions
     */
    public List<Abonnement> getExpiringSubscriptions() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime future = now.plus(7, ChronoUnit.DAYS); // Next 7 days
        return abonnementRepository.findExpiringSubscriptions(now, future);
    }

    /**
     * Get subscriptions eligible for auto-renewal
     */
    public List<Abonnement> getAutoRenewableSubscriptions() {
        LocalDateTime now = LocalDateTime.now();
        return abonnementRepository.findExpiredWithAutoRenewal(now);
    }

    /**
     * Calculate expiry date based on subscription type
     */
    private LocalDateTime calculateExpiryDate(LocalDateTime startDate, String type) {
        return switch (type) {
            case "MENSUEL" -> startDate.plus(1, ChronoUnit.MONTHS);
            case "TRIMESTRIEL" -> startDate.plus(3, ChronoUnit.MONTHS);
            case "ANNUEL" -> startDate.plus(1, ChronoUnit.YEARS);
            default -> throw new IllegalArgumentException("Type abonnement invalide: " + type);
        };
    }

    /**
     * Map Entity to DTO
     */
    private AbonnementResponseDTO mapToResponseDTO(Abonnement abonnement) {
        long joursRestants = ChronoUnit.DAYS.between(LocalDateTime.now(), abonnement.getDateFin());
        
        String messageStatut = switch (abonnement.getStatut()) {
            case "ACTIF" -> "Abonnement actif";
            case "EXPIRE" -> "Abonnement expiré";
            case "SUSPENDU" -> "Abonnement suspendu";
            case "ANNULE" -> "Abonnement annulé";
            default -> "Statut inconnu";
        };

        Boolean rappelDisponible = !abonnement.getRappelEnvoye() && joursRestants <= 7 && joursRestants > 0;

        return AbonnementResponseDTO.builder()
                .id(abonnement.getId())
                .typeAbonnement(abonnement.getTypeAbonnement())
                .montant(abonnement.getMontant())
                .dateDebut(abonnement.getDateDebut())
                .dateFin(abonnement.getDateFin())
                .statut(abonnement.getStatut())
                .renouvellementAuto(abonnement.getRenouvellementAuto())
                .rappelEnvoye(abonnement.getRappelEnvoye())
                .creeLe(abonnement.getCreeLe())
                .misAJourLe(abonnement.getMisAJourLe())
                .utilisateurId(abonnement.getUtilisateur().getId().toString())
                .joursRestants(joursRestants)
                .messageStatut(messageStatut)
                .rappelDisponible(rappelDisponible)
                .build();
    }
}
