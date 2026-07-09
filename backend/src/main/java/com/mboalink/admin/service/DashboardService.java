package com.mboalink.admin.service;

import com.mboalink.auth.enums.Role;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.grossiste.repository.DeverrouillageCoordonneesRepository;
import com.mboalink.payment.repository.ReinitialisationNoteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final UtilisateurRepository utilisateurRepository;
    private final DeverrouillageCoordonneesRepository deverrouillageCoordonneesRepository;
    private final ReinitialisationNoteRepository reinitialisationNoteRepository;

    public long countGrossistes() {
        return utilisateurRepository.countByRole(Role.GROSSISTE);
    }

    public long countUtilisateursClients() {
        return utilisateurRepository.countByRole(Role.UTILISATEUR);
    }

    public long countTotalUtilisateurs() {
        return countGrossistes() + countUtilisateursClients();
    }

    public long countUtilisateursAyantDeverrouilleCoordonnees() {
        return deverrouillageCoordonneesRepository.countUtilisateursDistincts();
    }

    public long countDemandesReinitialisationNote() {
        return reinitialisationNoteRepository.count();
    }
}