package com.mboalink.payment.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransactionRequestDTO {

    @NotBlank(message = "Type de transaction requis")
    private String typeTransaction; // DEVERROUILLAGE_COORDONNEES | ABONNEMENT | REINITIALISATION_NOTE

    @NotNull(message = "Montant requis")
    @DecimalMin(value = "0.1", message = "Montant doit être > 0")
    private BigDecimal montant;

    @NotBlank(message = "Opérateur requis")
    private String operateur; // MTN_MOMO | ORANGE_MONEY

    @NotBlank(message = "Numéro de téléphone requis")
    @Pattern(regexp = "^[0-9]{9,15}$", message = "Numéro invalide")
    private String numeroTelephonePaiement;

    @NotBlank(message = "Description requise")
    @Size(min = 5, max = 255, message = "Description entre 5 et 255 caractères")
    private String description;

    private String referenceExterne; // Optional: externe transaction ID

    @Builder.Default
    private String devise = "XAF";
}
