package com.mboalink.admin.service;

import com.mboalink.admin.dto.SignalementResponseDTO;
import com.mboalink.admin.entity.Signalement;
import com.mboalink.admin.repository.SignalementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SignalementService {

    private final SignalementRepository signalementRepository;

    public List<SignalementResponseDTO> getSignalementsEnAttente() {
        return signalementRepository.findByStatutOrderByCreeLeDesc("EN_ATTENTE")
                .stream()
                .map(SignalementResponseDTO::fromEntity)
                .toList();
    }

    public long countEnAttente() {
        return signalementRepository.countByStatut("EN_ATTENTE");
    }

    /** L'avis est conservé : le signalement est rejeté (pas fondé) */
    public SignalementResponseDTO conserver(UUID id, String commentaireAdmin) {
        Signalement s = signalementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Signalement introuvable"));
        s.setStatut("REJETE");
        s.setCommentaireAdmin(commentaireAdmin);
        s.setTraiteLe(java.time.LocalDateTime.now());
        return SignalementResponseDTO.fromEntity(signalementRepository.save(s));
    }

    /** L'avis est supprimé : le signalement est marqué traité */
    public SignalementResponseDTO supprimer(UUID id, String commentaireAdmin) {
        Signalement s = signalementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Signalement introuvable"));
        s.setStatut("TRAITE");
        s.setCommentaireAdmin(commentaireAdmin);
        s.setTraiteLe(java.time.LocalDateTime.now());
        // TODO : ici il faudra aussi supprimer le vrai contenu signalé
        // (ex: la Notation correspondant à s.getCibleId()) une fois qu'on aura cette entité
        return SignalementResponseDTO.fromEntity(signalementRepository.save(s));
    }
}