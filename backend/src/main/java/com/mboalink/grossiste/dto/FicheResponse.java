package com.mboalink.grossiste.dto;

import com.mboalink.grossiste.entity.FicheGrossiste;
import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class FicheResponse {

    private UUID id;
    private String nomEntreprise;
    private String description;
    private String secteurActivite;
    private String ville;
    private String quartier;
    private String statutVerification;
    private Double noteMoyenne;
    private Integer nombreAvis;

    // Convertit une entité FicheGrossiste en réponse propre pour Flutter
    public static FicheResponse depuis(FicheGrossiste f) {
        return FicheResponse.builder()
                .id(f.getId())
                .nomEntreprise(f.getNomEntreprise())
                .description(f.getDescription())
                .secteurActivite(f.getSecteurActivite())
                .ville(f.getVille())
                .quartier(f.getQuartier())
                .statutVerification(f.getStatutVerification())
                .noteMoyenne(f.getNoteMoyenne())
                .nombreAvis(f.getNombreAvis())
                .build();
    }
}