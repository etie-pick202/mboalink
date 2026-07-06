package com.mboalink.grossiste.dto;

import com.mboalink.grossiste.entity.DocumentVerification;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class DocumentResponse {

    private UUID id;
    private String typeDocument;
    private String urlDocument;
    private String statut;
    private String commentaireAdmin;
    private LocalDateTime creeLe;

    public static DocumentResponse depuis(DocumentVerification d) {
        return DocumentResponse.builder()
                .id(d.getId())
                .typeDocument(d.getTypeDocument())
                .urlDocument(d.getUrlDocument())
                .statut(d.getStatut())
                .commentaireAdmin(d.getCommentaireAdmin())
                .creeLe(d.getCreeLe())
                .build();
    }
}