package com.mboalink.payment.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReinitialisationNoteRequestDTO {

    @NotNull(message = "Identifiant de la fiche grossiste requis")
    private UUID ficheGrossisteId;

    @NotNull(message = "Identifiant de la transaction requis")
    private UUID transactionId;
}