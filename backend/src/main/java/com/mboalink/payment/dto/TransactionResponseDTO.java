package com.mboalink.payment.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransactionResponseDTO {

    private UUID id;
    private String typeTransaction;
    private BigDecimal montant;
    private String devise;
    private String operateur; // MTN_MOMO | ORANGE_MONEY
    private String numeroTelephonePaiement;
    private String referenceExterne;
    private String statut; // EN_ATTENTE | SUCCES | ECHEC | REMBOURSE
    private String description;
    private LocalDateTime creeLe;
    private LocalDateTime traiteLe;
    private String utilisateurId;
    
    // For UI display
    private String messageStatut;
}
