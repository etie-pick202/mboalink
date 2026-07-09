package com.mboalink.admin.dto;

import com.mboalink.admin.entity.Signalement;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class SignalementResponseDTO {
    private UUID id;
    private String signaleurNom;
    private String typeCible;
    private UUID cibleId;
    private String motif;
    private String description;
    private String statut;
    private LocalDateTime creeLe;

    public static SignalementResponseDTO fromEntity(Signalement s) {
        return SignalementResponseDTO.builder()
                .id(s.getId())
                .signaleurNom(s.getSignaleur() != null ? s.getSignaleur().getNom() : "Inconnu")
                .typeCible(s.getTypeCible())
                .cibleId(s.getCibleId())
                .motif(s.getMotif())
                .description(s.getDescription())
                .statut(s.getStatut())
                .creeLe(s.getCreeLe())
                .build();
    }
}