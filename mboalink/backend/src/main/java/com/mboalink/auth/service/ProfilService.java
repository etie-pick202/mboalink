package com.mboalink.auth.service;

import com.mboalink.auth.dto.ModifierProfilRequest;
import com.mboalink.auth.dto.ProfilResponseDto;
import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.exception.AuthException;
import com.mboalink.auth.repository.UtilisateurRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProfilService {

    private final UtilisateurRepository utilisateurRepo;

    @Transactional(readOnly = true)
    public ProfilResponseDto consulterProfil(UUID utilisateurId) {
        Utilisateur u = trouverParId(utilisateurId);
        return versDto(u);
    }

    @Transactional
    public ProfilResponseDto modifierProfil(UUID utilisateurId, ModifierProfilRequest req) {
        Utilisateur u = trouverParId(utilisateurId);

        if (req.getNom() != null) {
            u.setNom(req.getNom());
        }
        if (req.getPrenom() != null) {
            u.setPrenom(req.getPrenom());
        }

        utilisateurRepo.save(u);
        log.info("[PROFIL] Profil modifié : {}", utilisateurId);
        return versDto(u);
    }

    private Utilisateur trouverParId(UUID id) {
        return utilisateurRepo.findById(id)
                .orElseThrow(() -> new AuthException("Utilisateur introuvable."));
    }

    private ProfilResponseDto versDto(Utilisateur u) {
        return ProfilResponseDto.builder()
                .utilisateurId(u.getId().toString())
                .nom(u.getNom())
                .prenom(u.getPrenom())
                .email(u.getEmail())
                .telephone(u.getTelephone())
                .role(u.getRole().name())
                .emailVerifie(u.getEmailVerifie())
                .telephoneVerifie(u.getTelephoneVerifie())
                .creeLe(u.getCreeLe())
                .build();
    }
}