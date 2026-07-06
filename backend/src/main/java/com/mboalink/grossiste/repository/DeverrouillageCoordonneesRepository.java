package com.mboalink.grossiste.repository;

import com.mboalink.grossiste.entity.DeverrouillageCoordonnees;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface DeverrouillageCoordonneesRepository extends JpaRepository<DeverrouillageCoordonnees, UUID> {

    @Query("SELECT COUNT(DISTINCT d.utilisateur.id) FROM DeverrouillageCoordonnees d")
    long countUtilisateursDistincts();
}