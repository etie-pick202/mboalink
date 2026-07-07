package com.mboalink.admin.dto;

import com.mboalink.grossiste.entity.DocumentVerification;
import com.mboalink.grossiste.entity.FicheGrossiste;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class ValidationFicheDTO {
    private UUID id;
    private String nomEntreprise;
    private String secteurActivite;
    private String ville;
    private String quartier;
    private String statutVerification;
    private LocalDateTime creeLe;
    private List<DocumentDTO> documents;

    @Data
    @Builder
    public static class DocumentDTO {
        private UUID id;
        private String typeDocument;
        private String urlDocument;
        private String statut;
        private String commentaireAdmin;

        public static DocumentDTO fromEntity(DocumentVerification d) {
            return DocumentDTO.builder()
                    .id(d.getId())
                    .typeDocument(d.getTypeDocument())
                    .urlDocument(d.getUrlDocument())
                    .statut(d.getStatut())
                    .commentaireAdmin(d.getCommentaireAdmin())
                    .build();
        }
    }

    public static ValidationFicheDTO fromEntity(FicheGrossiste f, List<DocumentVerification> docs) {
        return ValidationFicheDTO.builder()
                .id(f.getId())
                .nomEntreprise(f.getNomEntreprise())
                .secteurActivite(f.getSecteurActivite())
                .ville(f.getVille())
                .quartier(f.getQuartier())
                .statutVerification(f.getStatutVerification())
                .creeLe(f.getCreeLe())
                .documents(docs.stream().map(DocumentDTO::fromEntity).toList())
                .build();
    }
}