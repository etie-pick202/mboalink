package com.mboalink.payment.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RecuResponseDTO {

    private UUID id;
    private String numeroRecu;
    private BigDecimal montantTotal;
    private String urlPdf;
    private LocalDateTime creeLe;
    
    // Transaction details embedded
    private UUID transactionId;
    private String typeTransaction;
    private String operateur; // MTN_MOMO | ORANGE_MONEY
    private String utilisateurId;
    
    // For UI display
    private String lienTelechargement;
    private Boolean pdfDisponible;
}
