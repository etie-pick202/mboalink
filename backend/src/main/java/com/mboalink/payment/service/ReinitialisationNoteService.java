package com.mboalink.payment.service;

import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.payment.dto.ReinitialisationNoteRequestDTO;
import com.mboalink.payment.dto.ReinitialisationNoteResponseDTO;
import com.mboalink.payment.entity.ReinitialisationNote;
import com.mboalink.payment.entity.Transaction;
import com.mboalink.payment.repository.ReinitialisationNoteRepository;
import com.mboalink.payment.repository.TransactionRepository;
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
@Transactional
public class ReinitialisationNoteService {

    private final ReinitialisationNoteRepository reinitialisationNoteRepository;
    private final TransactionRepository transactionRepository;
    private final FicheGrossisteRepository ficheGrossisteRepository;

    /**
     * Réinitialiser la note d'un grossiste après paiement réussi
     */
    public ReinitialisationNoteResponseDTO reinitialiserNote(ReinitialisationNoteRequestDTO request) {
        log.info("[REINIT_NOTE] Réinitialisation note - FicheGrossiste: {}", request.getFicheGrossisteId());

        // Vérifier que la transaction existe et est réussie
        Transaction transaction = transactionRepository.findById(request.getTransactionId())
                .orElseThrow(() -> new RuntimeException("Transaction non trouvée"));

        if (!"SUCCES".equals(transaction.getStatut())) {
            throw new RuntimeException("La transaction doit être réussie pour réinitialiser la note");
        }

        if (!"REINITIALISATION_NOTE".equals(transaction.getTypeTransaction())) {
            throw new RuntimeException("Type de transaction invalide pour une réinitialisation de note");
        }

        // Récupérer la fiche grossiste
        FicheGrossiste ficheGrossiste = ficheGrossisteRepository.findById(request.getFicheGrossisteId())
                .orElseThrow(() -> new RuntimeException("Fiche grossiste non trouvée"));

        // Sauvegarder la note avant réinitialisation (Double)
        Double noteAvant = ficheGrossiste.getNoteMoyenne() != null
                ? ficheGrossiste.getNoteMoyenne()
                : 0.0;

        // Réinitialiser la note à 0
        ficheGrossiste.setNoteMoyenne(0.0);
        ficheGrossiste.setNombreAvis(0);
        ficheGrossisteRepository.save(ficheGrossiste);

        log.info("[REINIT_NOTE] Note réinitialisée: {} → 0 pour FicheGrossiste: {}",
                noteAvant, ficheGrossiste.getId());

        // Enregistrer la réinitialisation
        ReinitialisationNote reinitialisation = ReinitialisationNote.builder()
                .ficheGrossiste(ficheGrossiste)
                .transaction(transaction)
                .noteAvant(noteAvant)
                .montantPaye(transaction.getMontant())
                .creeLe(LocalDateTime.now())
                .build();

        ReinitialisationNote saved = reinitialisationNoteRepository.save(reinitialisation);
        log.info("[REINIT_NOTE] Réinitialisation enregistrée: {}", saved.getId());

        return mapToResponseDTO(saved);
    }

    /**
     * Récupérer l'historique des réinitialisations pour un grossiste
     */
    public List<ReinitialisationNoteResponseDTO> getHistoriqueReinitialisations(UUID ficheGrossisteId) {
        log.info("[REINIT_NOTE] Récupération historique - FicheGrossiste: {}", ficheGrossisteId);

        FicheGrossiste ficheGrossiste = ficheGrossisteRepository.findById(ficheGrossisteId)
                .orElseThrow(() -> new RuntimeException("Fiche grossiste non trouvée"));

        return reinitialisationNoteRepository.findByFicheGrossiste(ficheGrossiste).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    /**
     * Map Entity → DTO
     */
    private ReinitialisationNoteResponseDTO mapToResponseDTO(ReinitialisationNote reinitialisation) {
        return ReinitialisationNoteResponseDTO.builder()
                .id(reinitialisation.getId())
                .ficheGrossisteId(reinitialisation.getFicheGrossiste().getId())
                .nomGrossiste(reinitialisation.getFicheGrossiste().getNomEntreprise())
                .transactionId(reinitialisation.getTransaction().getId())
                .noteAvant(reinitialisation.getNoteAvant())
                .montantPaye(reinitialisation.getMontantPaye())
                .creeLe(reinitialisation.getCreeLe())
                .message("Note réinitialisée avec succès")
                .build();
    }
}