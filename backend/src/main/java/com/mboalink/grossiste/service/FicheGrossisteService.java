package com.mboalink.grossiste.service;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.auth.repository.ComportementUtilisateurRepository;
import com.mboalink.auth.repository.UtilisateurRepository;
import com.mboalink.auth.security.CurrentUser;
import com.mboalink.commun.exception.AccesRefuseException;
import com.mboalink.commun.exception.ConflitMetierException;
import com.mboalink.commun.exception.RessourceIntrouvableException;
import com.mboalink.grossiste.dto.CreerFicheRequest;
import com.mboalink.grossiste.dto.FicheResponse;
import com.mboalink.grossiste.dto.FicheStatistiquesResponse;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.entity.ProduitGrossiste;
import com.mboalink.grossiste.repository.DeverrouillageCoordonneesRepository;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.grossiste.repository.ProduitGrossisteRepository;
import com.mboalink.commun.service.SupabaseStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FicheGrossisteService {

    private final FicheGrossisteRepository ficheRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final ProduitGrossisteRepository produitRepository;
    private final SupabaseStorageService supabaseService;
    private final ComportementUtilisateurRepository comportementRepository;
    private final DeverrouillageCoordonneesRepository deverrouillageRepository;

    // Créer une fiche grossiste
    public FicheResponse creerFiche(UUID utilisateurId, CreerFicheRequest req) {

        // 0. Vérifier que l'utilisateur est bien un GROSSISTE
        if (!"ROLE_GROSSISTE".equals(CurrentUser.getRole())) {
            throw new AccesRefuseException("Seuls les grossistes peuvent créer une fiche.");
        }

        // 1. Vérifier que l'utilisateur n'a pas déjà une fiche
        if (ficheRepository.existsByUtilisateurId(utilisateurId)) {
            throw new ConflitMetierException("Vous avez déjà une fiche grossiste.");
        }

        // 2. Récupérer l'utilisateur connecté
        Utilisateur utilisateur = utilisateurRepository.findById(utilisateurId)
                .orElseThrow(() -> new RessourceIntrouvableException("Utilisateur introuvable."));

        // 3. Construire la nouvelle fiche
        FicheGrossiste fiche = FicheGrossiste.builder()
                .utilisateur(utilisateur)
                .nomEntreprise(req.getNomEntreprise())
                .description(req.getDescription())
                .secteurActivite(req.getSecteurActivite())
                .ville(req.getVille())
                .quartier(req.getQuartier())
                .adresseComplete(req.getAdresseComplete())
                .telephoneProfessionnel(req.getTelephoneProfessionnel())
                .emailProfessionnel(req.getEmailProfessionnel())
                .siteWeb(req.getSiteWeb())
                .logoUrl(req.getLogoUrl())
                .anneeCreation(req.getAnneeCreation())
                .statutVerification("EN_ATTENTE")
                .build();

        // 4. Sauvegarder en base
        FicheGrossiste sauvegardee = ficheRepository.save(fiche);

        // 5. Renvoyer une réponse propre
        return FicheResponse.depuis(sauvegardee);
    }

    // Liste de toutes les fiches (annuaire public)
    public List<FicheResponse> listerFiches() {
        return ficheRepository.findAll().stream()
                .map(FicheResponse::depuis)
                .collect(Collectors.toList());
    }

    // Détail d'une fiche avec ses produits
    public FicheResponse consulterFiche(UUID ficheId) {
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new RessourceIntrouvableException("Fiche introuvable."));

        List<ProduitGrossiste> produits = produitRepository.findByFicheGrossisteId(ficheId);

        return FicheResponse.avecProduits(fiche, produits);
    }

    // Fiche du grossiste connecté (dashboard, wizard "Créer ma fiche")
    public FicheResponse consulterMaFiche(UUID utilisateurId) {
        FicheGrossiste fiche = ficheRepository.findByUtilisateurId(utilisateurId)
                .orElseThrow(() -> new RessourceIntrouvableException("Vous n'avez pas encore de fiche."));

        List<ProduitGrossiste> produits = produitRepository.findByFicheGrossisteId(fiche.getId());

        return FicheResponse.avecProduits(fiche, produits);
    }

    // Modifier sa propre fiche
    public FicheResponse modifierFiche(UUID utilisateurId, UUID ficheId, CreerFicheRequest req) {

        // 1. Récupérer la fiche existante
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new RessourceIntrouvableException("Fiche introuvable."));

        // 2. Sécurité : vérifier que la fiche appartient à l'utilisateur connecté
        if (!fiche.getUtilisateur().getId().equals(utilisateurId)) {
            throw new AccesRefuseException("Vous ne pouvez modifier que votre propre fiche.");
        }

        // 2b. Une fiche rejetée que le grossiste corrige repasse en attente
        // de vérification — sinon l'admin n'a aucun signal qu'une correction
        // a été soumise et le grossiste reste bloqué sur "rejetée" à vie.
        if ("REJETE".equals(fiche.getStatutVerification())) {
            fiche.setStatutVerification("EN_ATTENTE");
        }

        // 3. Mettre à jour les champs
        fiche.setNomEntreprise(req.getNomEntreprise());
        fiche.setDescription(req.getDescription());
        fiche.setSecteurActivite(req.getSecteurActivite());
        fiche.setVille(req.getVille());
        fiche.setQuartier(req.getQuartier());
        fiche.setAdresseComplete(req.getAdresseComplete());
        fiche.setTelephoneProfessionnel(req.getTelephoneProfessionnel());
        fiche.setEmailProfessionnel(req.getEmailProfessionnel());
        fiche.setSiteWeb(req.getSiteWeb());
        fiche.setLogoUrl(req.getLogoUrl());
        fiche.setAnneeCreation(req.getAnneeCreation());

        // 4. Sauvegarder (Hibernate détecte que la fiche existe déjà et fait un UPDATE)
        FicheGrossiste miseAJour = ficheRepository.save(fiche);

        // 5. Renvoyer la réponse
        return FicheResponse.depuis(miseAJour);
    }

    // Confirme l'upload Supabase du logo — réutilise le même chemin
    // "upload-url" déjà exposé pour les documents (générique sur
    // typeDocument), mais écrit directement sur logoUrl plutôt que sur
    // la table de vérification de documents (sémantiquement inadaptée
    // pour un logo, qui n'a pas besoin de validation admin).
    public FicheResponse confirmerLogo(UUID utilisateurId, UUID ficheId, String filePath) {
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new RessourceIntrouvableException("Fiche introuvable."));

        if (!fiche.getUtilisateur().getId().equals(utilisateurId)) {
            throw new AccesRefuseException("Vous ne pouvez modifier que votre propre fiche.");
        }

        fiche.setLogoUrl(supabaseService.construireUrl(filePath));
        FicheGrossiste miseAJour = ficheRepository.save(fiche);

        return FicheResponse.depuis(miseAJour);
    }

    // Statistiques réelles du dashboard grossiste (écran "Tableau de bord").
    public FicheStatistiquesResponse consulterStatistiques(UUID utilisateurId, UUID ficheId) {
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new RessourceIntrouvableException("Fiche introuvable."));

        if (!fiche.getUtilisateur().getId().equals(utilisateurId)) {
            throw new AccesRefuseException("Vous ne pouvez consulter que les statistiques de votre propre fiche.");
        }

        String ficheIdStr = ficheId.toString();

        LocalDateTime debutMois = YearMonth.now().atDay(1).atStartOfDay();
        long vuesMoisEnCours = comportementRepository.countVuesFiche(ficheIdStr, debutMois);

        long contactsDebloques = deverrouillageRepository.countByFicheGrossisteId(ficheId);

        List<Long> vuesParJour = calculerVuesParJour(ficheIdStr);

        return FicheStatistiquesResponse.builder()
                .vuesMoisEnCours(vuesMoisEnCours)
                .contactsDebloques(contactsDebloques)
                .vuesParJour(vuesParJour)
                .build();
    }

    private List<Long> calculerVuesParJour(String ficheId) {
        LocalDate aujourdhui = LocalDate.now();
        LocalDateTime depuis = aujourdhui.minusDays(6).atStartOfDay();

        List<Object[]> lignes = comportementRepository.countVuesParJour(ficheId, depuis);

        java.util.Map<LocalDate, Long> parJour = new java.util.HashMap<>();
        for (Object[] ligne : lignes) {
            LocalDate jour = ((java.sql.Timestamp) ligne[0]).toLocalDateTime().toLocalDate();
            parJour.put(jour, ((Number) ligne[1]).longValue());
        }

        List<Long> resultat = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            resultat.add(parJour.getOrDefault(aujourdhui.minusDays(i), 0L));
        }
        return resultat;
    }
}