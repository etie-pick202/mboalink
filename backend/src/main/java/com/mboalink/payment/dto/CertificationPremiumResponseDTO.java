package com.mboalink.payment.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class CertificationPremiumResponseDTO {

    private UUID id;
    private UUID ficheGrossisteId;
    private String nomGrossiste;
    private UUID transactionId;
    private BigDecimal montantPaye;
    private LocalDateTime creeLe;
    private String message;
}
