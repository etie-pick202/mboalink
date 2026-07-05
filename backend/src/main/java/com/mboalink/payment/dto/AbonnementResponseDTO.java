package com.mboalink.payment.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AbonnementResponseDTO {

    private UUID id;
    private String typeAbonnement;
    private BigDecimal montant;
    private LocalDateTime dateDebut;
    private LocalDateTime dateFin;
    private String statut; // ACTIF | EXPIRE | SUSPENDU | ANNULE
    private Boolean renouvellementAuto;
    private Boolean rappelEnvoye;
    private LocalDateTime creeLe;
    private LocalDateTime misAJourLe;
    private String utilisateurId;
    
    // For UI display
    private Long joursRestants;
    private String messageStatut;
    private Boolean rappelDisponible;
}
