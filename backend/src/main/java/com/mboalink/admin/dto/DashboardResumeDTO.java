package com.mboalink.admin.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DashboardResumeDTO {
    private long totalUtilisateurs;
    private long totalGrossistes;
    private long totalUtilisateursClients;
    private long validationsEnAttente;
    private long avisSignales;
    private long deverrouillagesCoordonnees;
    private long demandesReinitialisationNote;
}