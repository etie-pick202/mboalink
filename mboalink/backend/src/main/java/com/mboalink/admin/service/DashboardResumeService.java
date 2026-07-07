package com.mboalink.admin.service;

import com.mboalink.admin.dto.DashboardResumeDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DashboardResumeService {

    private final DashboardService dashboardService;
    private final NotationAdminService notationAdminService;
    private final FicheGrossisteAdminService ficheGrossisteAdminService;

    public DashboardResumeDTO getResume() {
        return DashboardResumeDTO.builder()
                .totalUtilisateurs(dashboardService.countTotalUtilisateurs())
                .totalGrossistes(dashboardService.countGrossistes())
                .totalUtilisateursClients(dashboardService.countUtilisateursClients())
                .validationsEnAttente(ficheGrossisteAdminService.countValidationsEnAttente())
                .avisSignales(notationAdminService.countAvisSignales())
                .deverrouillagesCoordonnees(dashboardService.countUtilisateursAyantDeverrouilleCoordonnees())
                .demandesReinitialisationNote(dashboardService.countDemandesReinitialisationNote())
                .build();
    }
}