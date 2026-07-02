package com.mboalink.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReinitialisationNoteResponseDTO {

    private UUID id;
    private UUID ficheGrossisteId;
    private String nomGrossiste;
    private UUID transactionId;
    private Double noteAvant;
    private BigDecimal montantPaye;
    private LocalDateTime creeLe;
    private String message;
}