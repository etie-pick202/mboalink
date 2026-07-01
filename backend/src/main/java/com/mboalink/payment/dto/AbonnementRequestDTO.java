package com.mboalink.payment.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AbonnementRequestDTO {

    @NotBlank(message = "Type d'abonnement requis")
    private String typeAbonnement; // MENSUEL | TRIMESTRIEL | ANNUEL

    @NotNull(message = "Montant requis")
    @DecimalMin(value = "0.1", message = "Montant doit être > 0")
    private BigDecimal montant;

    @NotNull(message = "Auto-renouvellement requis")
    private Boolean renouvellementAuto;

    // Used when renewing or updating
    private String statut; // ACTIF | EXPIRE | SUSPENDU | ANNULE
}
