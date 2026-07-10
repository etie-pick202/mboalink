package com.mboalink.search.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.ComportementUtilisateurRepository;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.search.dto.FilActualiteItemDto;
import com.mboalink.search.dto.FilActualiteResponseDto;
import com.mboalink.search.repository.FavoriRepository;
import com.mboalink.search.repository.HistoriqueRechercheRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FilActualiteService {

    private static final int CANDIDATS_MAX = 150;
    private static final int JOURS_HISTORIQUE = 30;

    private final FicheGrossisteRepository ficheGrossisteRepository;
    private final ComportementUtilisateurRepository comportementRepository;
    private final HistoriqueRechercheRepository historiqueRepository;
    private final FavoriRepository favoriRepository;

    @Transactional(readOnly = true)
    public FilActualiteResponseDto genererFil(Utilisateur utilisateur, Double latUser, Double lonUser,
                                              int page, int taille) {
        List<FicheGrossiste> candidats = ficheGrossisteRepository
                .findActifsOrderByNote(PageRequest.of(0, CANDIDATS_MAX));

        if (utilisateur == null || candidats.isEmpty()) {
            List<FilActualiteItemDto> items = candidats.stream()
                    .map(f -> toDto(f, latUser, lonUser, "Populaire sur MboaLink"))
                    .toList();
            return paginer(items, page, taille, false);
        }

        ProfilUtilisateur profil = extraireProfilUtilisateur(utilisateur);
        Set<UUID> favorisIds = new HashSet<>(favoriRepository.findFicheIdsParUtilisateur(utilisateur.getId()));

        List<FilActualiteItemDto> items = candidats.stream()
                .filter(f -> !favorisIds.contains(f.getId()))
                .map(f -> scorerEtConvertir(f, profil, latUser, lonUser))
                .sorted(Comparator.comparingDouble(ItemScore::score).reversed())
                .map(ItemScore::dto)
                .collect(Collectors.toList());

        boolean personnalise = !profil.topSecteurs().isEmpty() || profil.villePreferee() != null;
        return paginer(items, page, taille, personnalise);
    }

    private ProfilUtilisateur extraireProfilUtilisateur(Utilisateur utilisateur) {
        LocalDateTime depuis = LocalDateTime.now().minusDays(JOURS_HISTORIQUE);
        UUID userId = utilisateur.getId();

        List<String> secteursComportement = comportementRepository.findTopValeurs(
                userId, "CLIC_CATEGORIE", depuis, PageRequest.of(0, 5));
        List<String> secteursRecherche = comportementRepository.findTopValeurs(
                userId, "RECHERCHE", depuis, PageRequest.of(0, 5));

        Set<String> topSecteurs = new LinkedHashSet<>();
        secteursComportement.forEach(s -> topSecteurs.add(s.toLowerCase()));
        secteursRecherche.forEach(s -> topSecteurs.add(s.toLowerCase()));

        List<String> localisations = comportementRepository.findTopLocalisation(userId, PageRequest.of(0, 1));
        String villePreferee = localisations.isEmpty() ? null : localisations.get(0);

        return new ProfilUtilisateur(topSecteurs, villePreferee);
    }

    private ItemScore scorerEtConvertir(FicheGrossiste fiche, ProfilUtilisateur profil,
                                        Double latUser, Double lonUser) {
        double score = 0;
        String raison = "Populaire sur MboaLink";

        String secteur = fiche.getSecteurActivite() != null ? fiche.getSecteurActivite().toLowerCase() : "";
        boolean matchSecteur = profil.topSecteurs().stream()
                .anyMatch(s -> secteur.contains(s) || s.contains(secteur));
        if (matchSecteur) {
            score += 3;
            raison = "Correspond à vos intérêts";
        }

        String ville = fiche.getVille() != null ? fiche.getVille().toLowerCase() : "";
        boolean matchVille = profil.villePreferee() != null
                && ville.contains(profil.villePreferee().toLowerCase());
        if (matchVille) {
            score += 2;
            if (!matchSecteur) raison = "Dans votre zone : " + fiche.getVille();
        }

        if (fiche.getNoteMoyenne() != null) {
            score += fiche.getNoteMoyenne();
            if (!matchSecteur && !matchVille && fiche.getNoteMoyenne() >= 4.0) {
                raison = "Très bien noté (" + fiche.getNoteMoyenne() + "/5)";
            }
        }

        if ("VERIFIE".equals(fiche.getStatutVerification())) {
            score += 1;
            if (!matchSecteur && !matchVille) raison = "Grossiste certifié";
        }

        return new ItemScore(toDto(fiche, latUser, lonUser, raison), score);
    }

    private FilActualiteItemDto toDto(FicheGrossiste fiche, Double latUser, Double lonUser, String raison) {
        Double distance = null;
        if (latUser != null && lonUser != null) {
            distance = calculerDistance(latUser, lonUser, fiche.getLatitude(), fiche.getLongitude());
        }
        return FilActualiteItemDto.builder()
                .id(fiche.getId())
                .nomEntreprise(fiche.getNomEntreprise())
                .secteurActivite(fiche.getSecteurActivite())
                .ville(fiche.getVille())
                .quartier(fiche.getQuartier())
                .logoUrl(fiche.getLogoUrl())
                .noteMoyenne(fiche.getNoteMoyenne())
                .nombreAvis(fiche.getNombreAvis())
                .certifie("VERIFIE".equals(fiche.getStatutVerification()))
                .certifiePremium(Boolean.TRUE.equals(fiche.getCertifiePremium()))
                .distanceKm(distance)
                .raisonRecommandation(raison)
                .build();
    }

    private FilActualiteResponseDto paginer(List<FilActualiteItemDto> items, int page, int taille,
                                             boolean personnalise) {
        int total = items.size();
        int debut = page * taille;
        int fin = Math.min(debut + taille, total);
        List<FilActualiteItemDto> contenu = debut >= total ? List.of() : items.subList(debut, fin);

        return FilActualiteResponseDto.builder()
                .resultats(contenu)
                .totalElements(total)
                .totalPages(total == 0 ? 0 : (int) Math.ceil((double) total / taille))
                .page(page)
                .taille(taille)
                .dernierePage(fin >= total)
                .personnalise(personnalise)
                .build();
    }

    private double calculerDistance(Double lat1, Double lon1, Double lat2, Double lon2) {
        if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) return Double.MAX_VALUE;
        final double R = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    private record ProfilUtilisateur(Set<String> topSecteurs, String villePreferee) {}

    private record ItemScore(FilActualiteItemDto dto, double score) {}
}
