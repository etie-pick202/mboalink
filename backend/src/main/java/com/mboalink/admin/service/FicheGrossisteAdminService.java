package com.mboalink.admin.service;

import com.mboalink.admin.dto.ValidationFicheDTO;
import com.mboalink.grossiste.entity.DocumentVerification;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.DocumentVerificationRepository;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FicheGrossisteAdminService {

    private final FicheGrossisteRepository ficheGrossisteRepository;
    private final DocumentVerificationRepository documentVerificationRepository;
    private static final String STATUT_EN_ATTENTE = "EN_ATTENTE";

    @Transactional(readOnly = true)
    public List<ValidationFicheDTO> getValidationsEnAttente() {
        List<FicheGrossiste> fiches = ficheGrossisteRepository
                .findByStatutVerificationOrderByCreeLeDesc(STATUT_EN_ATTENTE);

        return fiches.stream()
                .map(f -> ValidationFicheDTO.fromEntity(
                        f,
                        documentVerificationRepository.findByFicheGrossiste(f)
                ))
                .toList();
    }

    public long countValidationsEnAttente() {
        return ficheGrossisteRepository.countByStatutVerification(STATUT_EN_ATTENTE);
    }

    /** Approuve un document individuel */
    @Transactional
    public void approuverDocument(UUID documentId, String commentaireAdmin) {
        DocumentVerification doc = documentVerificationRepository.findById(documentId)
                .orElseThrow(() -> new RuntimeException("Document introuvable"));
        doc.setStatut("APPROUVE");
        doc.setCommentaireAdmin(commentaireAdmin);
        doc.setTraiteLe(LocalDateTime.now());
        documentVerificationRepository.save(doc);
    }

    /** Rejette un document individuel */
    @Transactional
    public void rejeterDocument(UUID documentId, String commentaireAdmin) {
        DocumentVerification doc = documentVerificationRepository.findById(documentId)
                .orElseThrow(() -> new RuntimeException("Document introuvable"));
        doc.setStatut("REJETE");
        doc.setCommentaireAdmin(commentaireAdmin);
        doc.setTraiteLe(LocalDateTime.now());
        documentVerificationRepository.save(doc);
    }

    /** Valide la fiche entière : seule statutVerification est modifiée */
    @Transactional
    public void validerFiche(UUID ficheId) {
        FicheGrossiste fiche = ficheGrossisteRepository.findById(ficheId)
                .orElseThrow(() -> new RuntimeException("Fiche introuvable"));
        fiche.setStatutVerification("VERIFIE");
        ficheGrossisteRepository.save(fiche);
    }

    /** Rejette la fiche entière : seule statutVerification est modifiée */
    @Transactional
    public void rejeterFiche(UUID ficheId) {
        FicheGrossiste fiche = ficheGrossisteRepository.findById(ficheId)
                .orElseThrow(() -> new RuntimeException("Fiche introuvable"));
        fiche.setStatutVerification("REJETE");
        ficheGrossisteRepository.save(fiche);
    }
}