package com.mboalink.payment.dto;

import com.mboalink.payment.entity.Plan;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class PlanResponseDTO {

    private UUID id;
    private String nom;
    private String roleCible;
    private BigDecimal prix;
    private String devise;
    private String periodicite;
    private List<String> avantages;

    public static PlanResponseDTO depuis(Plan p) {
        return PlanResponseDTO.builder()
                .id(p.getId())
                .nom(p.getNom())
                .roleCible(p.getRoleCible())
                .prix(p.getPrix())
                .devise(p.getDevise())
                .periodicite(p.getPeriodicite())
                .avantages(p.getAvantages() == null || p.getAvantages().isBlank()
                        ? List.of()
                        : Arrays.asList(p.getAvantages().split("\n")))
                .build();
    }
}
