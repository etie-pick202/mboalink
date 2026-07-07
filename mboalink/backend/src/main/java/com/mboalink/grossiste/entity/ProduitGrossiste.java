package com.mboalink.grossiste.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "produits_grossiste")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProduitGrossiste {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fiche_grossiste_id", nullable = false)
    private FicheGrossiste ficheGrossiste;

    @Column(nullable = false, length = 200)
    private String nom;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "categorie", length = 100)
    private String categorie;

    @Column(name = "prix_unitaire", precision = 10, scale = 2)
    private BigDecimal prixUnitaire;

    @Column(name = "quantite_minimale")
    private Integer quantiteMinimale;

    @Column(name = "unite_mesure", length = 50)
    private String uniteMesure;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "est_disponible", nullable = false)
    @Builder.Default
    private Boolean estDisponible = true;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;

    @UpdateTimestamp
    @Column(name = "mis_a_jour_le")
    private LocalDateTime misAJourLe;
}