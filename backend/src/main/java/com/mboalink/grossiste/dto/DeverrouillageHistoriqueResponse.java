package com.mboalink.grossiste.dto;

import com.mboalink.grossiste.entity.DeverrouillageCoordonnees;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class DeverrouillageHistoriqueResponse {

    private UUID ficheGrossisteId;
    private String nomEntreprise;
    private String secteurActivite;
    private String ville;
    private String logoUrl;
    private String telephoneProfessionnel;
    private String emailProfessionnel;
    private BigDecimal montantPaye;
    private LocalDateTime deverrouilleLe;
    private boolean encoreValide;
    private String referenceTransaction;

    public static DeverrouillageHistoriqueResponse depuis(DeverrouillageCoordonnees d, boolean encoreValide) {
        var fiche = d.getFicheGrossiste();
        return DeverrouillageHistoriqueResponse.builder()
                .ficheGrossisteId(fiche.getId())
                .nomEntreprise(fiche.getNomEntreprise())
                .secteurActivite(fiche.getSecteurActivite())
                .ville(fiche.getVille())
                .logoUrl(fiche.getLogoUrl())
                .telephoneProfessionnel(fiche.getTelephoneProfessionnel())
                .emailProfessionnel(fiche.getEmailProfessionnel())
                .montantPaye(d.getMontantPaye())
                .deverrouilleLe(d.getDeverrouilleLe())
                .encoreValide(encoreValide)
                .referenceTransaction(d.getReferenceTransaction())
                .build();
    }
}
