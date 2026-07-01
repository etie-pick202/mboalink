package com.mboalink.admin.entity;

import com.mboalink.auth.entity.Utilisateur;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "campagnes_publicitaires")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CampagnePublicitaire {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "annonceur_id", nullable = false)
    private Utilisateur annonceur;

    @Column(nullable = false, length = 200)
    private String titre;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "lien_cible", length = 500)
    private String lienCible;

    /** BANNIERE | SPONSORISE | MISE_EN_AVANT */
    @Column(name = "type_campagne", nullable = false, length = 30)
    private String typeCampagne;

    @Column(name = "budget", precision = 10, scale = 2)
    private BigDecimal budget;

    @Column(name = "date_debut", nullable = false)
    private LocalDateTime dateDebut;

    @Column(name = "date_fin", nullable = false)
    private LocalDateTime dateFin;

    /** EN_ATTENTE | ACTIVE | PAUSEE | TERMINEE | REJETEE */
    @Column(name = "statut", nullable = false, length = 20)
    @Builder.Default
    private String statut = "EN_ATTENTE";

    @Column(name = "nombre_impressions")
    @Builder.Default
    private Integer nombreImpressions = 0;

    @Column(name = "nombre_clics")
    @Builder.Default
    private Integer nombreClics = 0;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;
}