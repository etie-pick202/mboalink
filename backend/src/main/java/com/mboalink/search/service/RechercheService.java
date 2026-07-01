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

import java.util.Comparator;
import java.util.List;

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

        String tri = request.getTri() == null ? "NOTE_DESC" : request.getTri();

        if ("PROXIMITE".equals(tri) || "CERTIFICATION".equals(tri)) {
            return rechercherAvecTriInMemory(spec, request, utilisateur, tri);
        }

        Pageable pageable = PageRequest.of(request.getPage(), request.getTaille(), resolveSort(tri));
        Page<FicheGrossiste> page = ficheGrossisteRepository.findAll(spec, pageable);

        sauvegarderHistorique(request, utilisateur, (int) page.getTotalElements());

        return RechercheResponseDto.builder()
                .resultats(page.getContent().stream().map(f -> toDto(f, null, null)).toList())
                .totalElements(page.getTotalElements())
                .totalPages(page.getTotalPages())
                .page(page.getNumber())
                .taille(page.getSize())
                .dernierePage(page.isLast())
                .build();
    }

    private RechercheResponseDto rechercherAvecTriInMemory(
            Specification<FicheGrossiste> spec,
            RechercheGrossisteRequest request,
            Utilisateur utilisateur,
            String tri) {

        List<FicheGrossiste> tous = ficheGrossisteRepository.findAll(spec);

        Double latUser = request.getLatitudeUtilisateur();
        Double lonUser = request.getLongitudeUtilisateur();

        if ("PROXIMITE".equals(tri)) {
            tous.sort(Comparator.comparingDouble(f -> calculerDistance(latUser, lonUser, f.getLatitude(), f.getLongitude())));
        } else {
            tous.sort(Comparator
                    .comparingInt((FicheGrossiste f) -> "VERIFIE".equals(f.getStatutVerification()) ? 0 : 1)
                    .thenComparingDouble(f -> -(f.getNoteMoyenne() != null ? f.getNoteMoyenne() : 0.0)));
        }

        int total = tous.size();
        int debut = request.getPage() * request.getTaille();
        int fin = Math.min(debut + request.getTaille(), total);
        List<FicheGrossiste> contenu = debut >= total ? List.of() : tous.subList(debut, fin);

        Double latDto = "PROXIMITE".equals(tri) ? latUser : null;
        Double lonDto = "PROXIMITE".equals(tri) ? lonUser : null;

        sauvegarderHistorique(request, utilisateur, total);

        return RechercheResponseDto.builder()
                .resultats(contenu.stream().map(f -> toDto(f, latDto, lonDto)).toList())
                .totalElements(total)
                .totalPages(total == 0 ? 0 : (int) Math.ceil((double) total / request.getTaille()))
                .page(request.getPage())
                .taille(request.getTaille())
                .dernierePage(fin >= total)
                .build();
    }

    private GrossisteSearchResultDto toDto(FicheGrossiste fiche, Double latUser, Double lonUser) {
        Double distance = null;
        if (latUser != null && lonUser != null) {
            distance = calculerDistance(latUser, lonUser, fiche.getLatitude(), fiche.getLongitude());
        }
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
                .distanceKm(distance)
                .build();
    }

    private Sort resolveSort(String tri) {
        return switch (tri) {
            case "NOTE_ASC" -> Sort.by(Sort.Direction.ASC, "noteMoyenne");
            case "NOM_ASC" -> Sort.by(Sort.Direction.ASC, "nomEntreprise");
            case "NOM_DESC" -> Sort.by(Sort.Direction.DESC, "nomEntreprise");
            default -> Sort.by(Sort.Direction.DESC, "noteMoyenne");
        };
    }

    private double calculerDistance(Double lat1, Double lon1, Double lat2, Double lon2) {
        if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
            return Double.MAX_VALUE;
        }
        final double R = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
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
