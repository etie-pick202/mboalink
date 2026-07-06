package com.mboalink.admin.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class RevenuMensuelDTO {
    private String mois;       // ex: "Avril", "Mai"
    private int numeroMois;    // 1-12
    private BigDecimal total;
}