package com.mboalink.search.repository;

import com.mboalink.search.entity.Categorie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CategorieRepository extends JpaRepository<Categorie, UUID> {

    List<Categorie> findByEstActiveTrueOrderByNomAsc();
}
