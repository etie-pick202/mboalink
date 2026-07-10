package com.mboalink.grossiste.repository;

import com.mboalink.grossiste.entity.DeverrouillageCoordonnees;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DeverrouillageCoordonneesRepository extends JpaRepository<DeverrouillageCoordonnees, UUID> {

    @Query("SELECT COUNT(DISTINCT d.utilisateur.id) FROM DeverrouillageCoordonnees d")
    long countUtilisateursDistincts();

    // Un déverrouillage n'est valable que 24h — au-delà, la fiche
    // redevient verrouillée pour cet utilisateur (aucune tâche planifiée
    // requise : la fenêtre de temps est simplement réévaluée à chaque appel).
    boolean existsByUtilisateurIdAndFicheGrossisteIdAndDeverrouilleLeAfter(
            UUID utilisateurId, UUID ficheGrossisteId, LocalDateTime depuis);

    // Un seul enregistrement par (utilisateur, fiche) — contrainte unique
    // en base. Sert à renouveler un déverrouillage existant plutôt que
    // d'en insérer un second, ce qui violerait la contrainte.
    Optional<DeverrouillageCoordonnees> findByUtilisateurIdAndFicheGrossisteId(
            UUID utilisateurId, UUID ficheGrossisteId);

    // Nombre d'utilisateurs distincts ayant déjà déverrouillé cette fiche
    // (une ligne par utilisateur, contrainte unique) — signal de
    // popularité pour PopulariteService. Cumul à vie : la fenêtre 24h ne
    // s'applique qu'à l'accès, pas à l'historique d'intérêt.
    long countByFicheGrossisteId(UUID ficheGrossisteId);

    // Écran "Contacts débloqués" — historique complet des fiches
    // déverrouillées par cet utilisateur (y compris hors fenêtre 24h,
    // pour qu'il retrouve la trace de ses déverrouillages passés).
    java.util.List<DeverrouillageCoordonnees> findByUtilisateurIdOrderByDeverrouilleLeDesc(UUID utilisateurId);
}