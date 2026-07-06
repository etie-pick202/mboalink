package com.mboalink.payment.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotationResponseDTO {

    private UUID id;
    private UUID ficheGrossisteId;
    private String ficheGrossisteName;
    private UUID utilisateurId;
    private String utilisateurNom;
    private String utilisateurAvatar;
    private Integer note;
    private String commentaire;
    private Boolean transactionVerifiee;
    private String statut; // VISIBLE | MASQUE | SIGNALE
    private LocalDateTime creeLe;
    private LocalDateTime misAJourLe;
    
    // For UI display
    private Boolean peutEditer; // Can user edit?
    private Integer nombreSignalements;
}
