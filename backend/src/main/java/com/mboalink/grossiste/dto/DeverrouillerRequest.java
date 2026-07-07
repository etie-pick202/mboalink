package com.mboalink.grossiste.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class DeverrouillerRequest {

    // La référence de transaction fournie par le module paiement (Personne 4)
    private String referenceTransaction;

    @NotNull(message = "Le montant payé est obligatoire")
    private BigDecimal montantPaye;
}