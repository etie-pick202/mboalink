package com.mboalink.auth.repository;

import com.mboalink.auth.entity.ComportementUtilisateur;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface ComportementUtilisateurRepository extends JpaRepository<ComportementUtilisateur, UUID> {

    @Query("SELECT c.valeur FROM ComportementUtilisateur c " +
           "WHERE c.utilisateur.id = :userId AND c.typeAction = :typeAction " +
           "AND c.creeLe >= :depuis AND c.valeur IS NOT NULL " +
           "GROUP BY c.valeur ORDER BY COUNT(c) DESC")
    List<String> findTopValeurs(@Param("userId") UUID userId,
                                @Param("typeAction") String typeAction,
                                @Param("depuis") LocalDateTime depuis,
                                Pageable pageable);

    @Query("SELECT c.localisation FROM ComportementUtilisateur c " +
           "WHERE c.utilisateur.id = :userId AND c.localisation IS NOT NULL " +
           "GROUP BY c.localisation ORDER BY COUNT(c) DESC")
    List<String> findTopLocalisation(@Param("userId") UUID userId, Pageable pageable);

    // Nombre de vues d'une fiche (typeAction = VUE_FICHE, valeur = id de
    // la fiche) sur une fenêtre glissante — signal de popularité pour
    // PopulariteService. Ne compte que les vues des utilisateurs ayant
    // accepté le tracking (ComportementService filtre déjà à l'écriture).
    @Query("SELECT COUNT(c) FROM ComportementUtilisateur c " +
           "WHERE c.typeAction = 'VUE_FICHE' AND c.valeur = :ficheId AND c.creeLe >= :depuis")
    long countVuesFiche(@Param("ficheId") String ficheId, @Param("depuis") LocalDateTime depuis);

    // Notification "nouveau grossiste près de vous" — utilisateurs ayant
    // récemment manifesté un intérêt pour ce secteur ou cette ville.
    @Query("SELECT DISTINCT c.utilisateur.id FROM ComportementUtilisateur c " +
           "WHERE (c.typeAction = 'CLIC_CATEGORIE' AND c.valeur = :secteur) " +
           "OR (c.typeAction = 'FILTRE_VILLE' AND c.localisation = :ville)")
    List<UUID> findUtilisateursInteressesParSecteurOuVille(@Param("secteur") String secteur, @Param("ville") String ville);

    // Statistiques du dashboard grossiste — nombre de vues par jour sur une
    // fenêtre glissante, pour le graphique "Vues · 7 derniers jours".
    @Query(value = "SELECT date_trunc('day', cree_le) AS jour, COUNT(*) AS total " +
            "FROM comportements_utilisateurs " +
            "WHERE type_action = 'VUE_FICHE' AND valeur = :ficheId AND cree_le >= :depuis " +
            "GROUP BY jour ORDER BY jour", nativeQuery = true)
    List<Object[]> countVuesParJour(@Param("ficheId") String ficheId, @Param("depuis") LocalDateTime depuis);
}
