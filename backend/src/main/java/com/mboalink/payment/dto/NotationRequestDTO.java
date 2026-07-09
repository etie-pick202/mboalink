package com.mboalink.payment.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotationRequestDTO {

    @NotNull(message = "ID du grossiste requis")
    private UUID ficheGrossisteId;

    @NotNull(message = "Note requise")
    @Min(value = 1, message = "Note minimum: 1")
    @Max(value = 5, message = "Note maximum: 5")
    private Integer note;

    @Size(max = 500, message = "Commentaire max 500 caractères")
    private String commentaire;

    @NotNull(message = "Vérification transaction requise")
    private Boolean transactionVerifiee; // Only true if user paid to unlock

    private String referenceTransaction; // Transaction ID for verification
}