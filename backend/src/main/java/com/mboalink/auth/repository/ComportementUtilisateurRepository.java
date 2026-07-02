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
}
