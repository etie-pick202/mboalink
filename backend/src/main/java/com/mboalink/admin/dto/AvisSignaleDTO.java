package com.mboalink.admin.dto;

import com.mboalink.payment.entity.Notation;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class AvisSignaleDTO {
    private UUID id;
    private UUID utilisateurId;
    private UUID ficheGrossisteId;
    private UUID transactionId;
    private Integer note;
    private String commentaire;
    private String statut;
    private Boolean transactionVerifiee;
    private LocalDateTime creeLe;
    private LocalDateTime misAJourLe;

    public static AvisSignaleDTO fromEntity(Notation n) {
        return AvisSignaleDTO.builder()
                .id(n.getId())
                .utilisateurId(n.getUtilisateur() != null ? n.getUtilisateur().getId() : null)
                .ficheGrossisteId(n.getFicheGrossiste() != null ? n.getFicheGrossiste().getId() : null)
                .transactionId(n.getTransaction() != null ? n.getTransaction().getId() : null)
                .note(n.getNote())
                .commentaire(n.getCommentaire())
                .statut(n.getStatut())
                .transactionVerifiee(n.getTransactionVerifiee())
                .creeLe(n.getCreeLe())
                .misAJourLe(n.getMisAJourLe())
                .build();
    }
}