package com.mboalink.grossiste.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;
import java.util.UUID;

@Data
public class DeverrouillerRequest {

    @NotNull(message = "L'ID de la transaction est obligatoire")
    private UUID transactionId;

    @NotNull(message = "Le montant payé est obligatoire")
    private BigDecimal montantPaye;
}
