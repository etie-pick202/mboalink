package com.mboalink.grossiste.dto;

import com.mboalink.grossiste.entity.FicheGrossiste;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CoordonneesResponse {

    private String nomEntreprise;
    private String telephoneProfessionnel;
    private String emailProfessionnel;
    private String message;

    // Les coordonnées ENFIN visibles après déverrouillage
    public static CoordonneesResponse depuis(FicheGrossiste f) {
        return CoordonneesResponse.builder()
                .nomEntreprise(f.getNomEntreprise())
                .telephoneProfessionnel(f.getTelephoneProfessionnel())
                .emailProfessionnel(f.getEmailProfessionnel())
                .message("Coordonnées déverrouillées avec succès.")
                .build();
    }
}