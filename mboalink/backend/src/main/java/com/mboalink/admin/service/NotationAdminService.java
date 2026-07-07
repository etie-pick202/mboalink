package com.mboalink.admin.service;

import com.mboalink.admin.entity.Signalement;
import com.mboalink.admin.repository.SignalementRepository;
import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.payment.dto.NotationResponseDTO;
import com.mboalink.payment.entity.Notation;
import com.mboalink.payment.repository.NotationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotationAdminService {

    private final NotationRepository notationRepository;
    private final SignalementRepository signalementRepository;
    private static final int SEUIL_NOTE = 3;

    @Transactional(readOnly = true)
    public List<NotationResponseDTO> getAvisSignales() {
        return notationRepository.findByNoteLessThanOrderByCreeLeDesc(SEUIL_NOTE)
                .stream()
                .map(this::mapToResponseDTO)
                .toList();
    }

    public long countAvisSignales() {
        return notationRepository.countByNoteLessThan(SEUIL_NOTE);
    }

    /** L'admin décide de CONSERVER l'avis : il reste dans notations, on trace juste la décision */
    @Transactional
    public void conserverAvis(UUID notationId, Utilisateur admin) {
        Notation notation = notationRepository.findById(notationId)
                .orElseThrow(() -> new RuntimeException("Notation introuvable"));

        Signalement signalement = Signalement.builder()
                .signaleur(notation.getUtilisateur())
                .typeCible("NOTATION")
                .cibleId(notation.getId())
                .motif("NOTE_BASSE")
                .description(notation.getCommentaire())
                .statut("TRAITE")
                .admin(admin)
                .commentaireAdmin("Avis conservé après vérification")
                .traiteLe(LocalDateTime.now())
                .build();

        signalementRepository.save(signalement);
        // La notation reste inchangée dans la table notations
    }

    /** L'admin décide de SUPPRIMER l'avis : suppression physique dans notations, trace gardée dans signalements */
    @Transactional
    public void supprimerAvis(UUID notationId, Utilisateur admin) {
        Notation notation = notationRepository.findById(notationId)
                .orElseThrow(() -> new RuntimeException("Notation introuvable"));

        Signalement signalement = Signalement.builder()
                .signaleur(notation.getUtilisateur())
                .typeCible("NOTATION")
                .cibleId(notation.getId())
                .motif("NOTE_BASSE")
                .description(notation.getCommentaire())
                .statut("TRAITE")
                .admin(admin)
                .commentaireAdmin("Avis supprimé après vérification")
                .traiteLe(LocalDateTime.now())
                .build();

        signalementRepository.save(signalement);
        notationRepository.delete(notation);
    }

    private NotationResponseDTO mapToResponseDTO(Notation notation) {
        return NotationResponseDTO.builder()
                .id(notation.getId())
                .ficheGrossisteId(notation.getFicheGrossiste().getId())
                .ficheGrossisteName(notation.getFicheGrossiste().getNomEntreprise())
                .utilisateurId(notation.getUtilisateur().getId())
                .utilisateurNom(notation.getUtilisateur().getNom() + " " + notation.getUtilisateur().getPrenom())
                .note(notation.getNote())
                .commentaire(notation.getCommentaire())
                .transactionVerifiee(notation.getTransactionVerifiee())
                .statut(notation.getStatut())
                .creeLe(notation.getCreeLe())
                .misAJourLe(notation.getMisAJourLe())
                .build();
    }
}