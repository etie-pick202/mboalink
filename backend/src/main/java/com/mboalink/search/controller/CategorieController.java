package com.mboalink.search.controller;

import com.mboalink.search.entity.Categorie;
import com.mboalink.search.repository.CategorieRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/search/categories")
@RequiredArgsConstructor
public class CategorieController {

    private final CategorieRepository categorieRepository;

    @GetMapping
    public ResponseEntity<List<Categorie>> listerCategories() {
        return ResponseEntity.ok(categorieRepository.findByEstActiveTrueOrderByNomAsc());
    }
}
