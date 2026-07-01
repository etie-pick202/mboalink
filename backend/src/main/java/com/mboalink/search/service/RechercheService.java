package com.mboalink.search.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.search.dto.GrossisteSearchResultDto;
import com.mboalink.search.dto.RechercheGrossisteRequest;
import com.mboalink.search.dto.RechercheResponseDto;
import com.mboalink.search.entity.HistoriqueRecherche;
import com.mboalink.search.repository.HistoriqueRechercheRepository;
import com.mboalink.search.specification.FicheGrossisteSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RechercheService {

    private final FicheGrossisteRepository ficheGrossisteRepository;
    private final HistoriqueRechercheRepository historiqueRechercheRepository;

    @Transactional(readOnly = true)
    public RechercheResponseDto rechercherGrossistes(RechercheGrossisteRequest request, Utilisateur utilisateur) {
        Specification<FicheGrossiste> spec = FicheGrossisteSpecification.avecFiltres(
                request.getMotCle(),
                request.getVille(),
                request.getCategorie(),
                request.getPrixMin(),
                request.getPrixMax(),
                request.getCertifie()
        );

        Pageable pageable = PageRequest.of(request.getPage(), request.getTaille(), resolveSort(request.getTri()));
        Page<FicheGrossiste> page = ficheGrossisteRepository.findAll(spec, pageable);

        sauvegarderHistorique(request, utilisateur, (int) page.getTotalElements());

        return RechercheResponseDto.builder()
                .resultats(page.getContent().stream().map(this::toDto).toList())
                .totalElements(page.getTotalElements())
                .totalPages(page.getTotalPages())
                .page(page.getNumber())
                .taille(page.getSize())
                .dernierePage(page.isLast())
                .build();
    }

    private GrossisteSearchResultDto toDto(FicheGrossiste fiche) {
        return GrossisteSearchResultDto.builder()
                .id(fiche.getId())
                .nomEntreprise(fiche.getNomEntreprise())
                .secteurActivite(fiche.getSecteurActivite())
                .ville(fiche.getVille())
                .quartier(fiche.getQuartier())
                .logoUrl(fiche.getLogoUrl())
                .noteMoyenne(fiche.getNoteMoyenne())
                .nombreAvis(fiche.getNombreAvis())
                .certifie("VERIFIE".equals(fiche.getStatutVerification()))
                .build();
    }

    private Sort resolveSort(String tri) {
        return switch (tri == null ? "NOTE_DESC" : tri) {
            case "NOTE_ASC" -> Sort.by(Sort.Direction.ASC, "noteMoyenne");
            case "NOM_ASC" -> Sort.by(Sort.Direction.ASC, "nomEntreprise");
            case "NOM_DESC" -> Sort.by(Sort.Direction.DESC, "nomEntreprise");
            default -> Sort.by(Sort.Direction.DESC, "noteMoyenne");
        };
    }

    private void sauvegarderHistorique(RechercheGrossisteRequest request, Utilisateur utilisateur, int nombreResultats) {
        if (request.getMotCle() == null && request.getVille() == null && request.getCategorie() == null) {
            return;
        }
        HistoriqueRecherche historique = HistoriqueRecherche.builder()
                .utilisateur(utilisateur)
                .termeRecherche(request.getMotCle() != null ? request.getMotCle() : "")
                .categorie(request.getCategorie())
                .localisation(request.getVille())
                .nombreResultats(nombreResultats)
                .build();
        historiqueRechercheRepository.save(historique);
    }
}
