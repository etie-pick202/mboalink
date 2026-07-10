package com.mboalink.payment.service;

import com.mboalink.commun.exception.ConflitMetierException;
import com.mboalink.commun.exception.RessourceIntrouvableException;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.notification.service.NotificationService;
import com.mboalink.payment.dto.CertificationPremiumRequestDTO;
import com.mboalink.payment.dto.CertificationPremiumResponseDTO;
import com.mboalink.payment.entity.CertificationPremium;
import com.mboalink.payment.entity.Transaction;
import com.mboalink.payment.repository.CertificationPremiumRepository;
import com.mboalink.payment.repository.TransactionRepository;
import com.mboalink.search.repository.FavoriRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class CertificationPremiumService {

    private final CertificationPremiumRepository certificationRepository;
    private final TransactionRepository transactionRepository;
    private final FicheGrossisteRepository ficheGrossisteRepository;
    private final FavoriRepository favoriRepository;
    private final NotificationService notificationService;

    public CertificationPremiumResponseDTO demanderCertification(CertificationPremiumRequestDTO request) {
        if (certificationRepository.findByFicheGrossisteId(request.getFicheGrossisteId()).isPresent()) {
            throw new ConflitMetierException("Ce grossiste est déjà certifié.");
        }

        Transaction transaction = transactionRepository.findById(request.getTransactionId())
                .orElseThrow(() -> new RessourceIntrouvableException("Transaction non trouvée"));

        if (!"SUCCES".equals(transaction.getStatut())) {
            throw new ConflitMetierException("La transaction doit être réussie pour activer la certification.");
        }
        if (!"CERTIFICATION_PREMIUM".equals(transaction.getTypeTransaction())) {
            throw new ConflitMetierException("Type de transaction invalide pour une certification premium.");
        }

        FicheGrossiste ficheGrossiste = ficheGrossisteRepository.findById(request.getFicheGrossisteId())
                .orElseThrow(() -> new RessourceIntrouvableException("Fiche grossiste non trouvée"));

        ficheGrossiste.setCertifiePremium(true);
        ficheGrossisteRepository.save(ficheGrossiste);

        CertificationPremium certification = CertificationPremium.builder()
                .ficheGrossiste(ficheGrossiste)
                .transaction(transaction)
                .montantPaye(transaction.getMontant())
                .build();

        CertificationPremium saved = certificationRepository.save(certification);
        log.info("[CERTIFICATION] Fiche {} certifiée premium", ficheGrossiste.getId());

        notifierFavoris(ficheGrossiste);

        return mapToResponseDTO(saved);
    }

    private void notifierFavoris(FicheGrossiste fiche) {
        favoriRepository.findUtilisateurIdsParFiche(fiche.getId()).forEach(utilisateurId ->
                notificationService.creerPourUtilisateurId(
                        utilisateurId,
                        "FAVORI_CERTIFIE",
                        "Un favori vient d'être certifié",
                        fiche.getNomEntreprise() + " a obtenu le badge de certification premium.",
                        fiche.getId().toString()
                ));
    }

    public Optional<CertificationPremiumResponseDTO> consulterCertification(java.util.UUID ficheGrossisteId) {
        return certificationRepository.findByFicheGrossisteId(ficheGrossisteId)
                .map(this::mapToResponseDTO);
    }

    private CertificationPremiumResponseDTO mapToResponseDTO(CertificationPremium c) {
        return CertificationPremiumResponseDTO.builder()
                .id(c.getId())
                .ficheGrossisteId(c.getFicheGrossiste().getId())
                .nomGrossiste(c.getFicheGrossiste().getNomEntreprise())
                .transactionId(c.getTransaction().getId())
                .montantPaye(c.getMontantPaye())
                .creeLe(c.getCreeLe())
                .message("Certification premium activée avec succès")
                .build();
    }
}
