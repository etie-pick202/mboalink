package com.mboalink.payment.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MobileMoneyRequestDTO {

    @NotNull(message = "Montant requis")
    @DecimalMin(value = "0.1", message = "Montant doit être > 0")
    private BigDecimal montant;

    @NotBlank(message = "Opérateur requis")
    @Pattern(regexp = "^(MTN_MOMO|ORANGE_MONEY)$", message = "Opérateur: MTN_MOMO ou ORANGE_MONEY")
    private String operateur; // MTN_MOMO | ORANGE_MONEY

    @NotBlank(message = "Numéro de téléphone requis")
    @Pattern(regexp = "^[0-9]{9,15}$", message = "Numéro invalide")
    private String numeroTelephonePaiement;

    @NotBlank(message = "Type de transaction requis")
    @Pattern(regexp = "^(DEVERROUILLAGE_COORDONNEES|ABONNEMENT|REINITIALISATION_NOTE)$")
    private String typeTransaction;

    private String referenceExterne; // Optional: set by payment gateway

    @Builder.Default
    private String devise = "XAF";

    @NotBlank(message = "Description requise")
    @Size(min = 5, max = 255)
    private String description;
    
    // For validation
    private String userPhoneNumber; // Used to verify against numeroTelephonePaiement
}
