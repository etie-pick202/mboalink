package com.mboalink.payment.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Catalogue des plans d'abonnement disponibles — remplace les prix codés
 * en dur côté app. Un Abonnement souscrit garde son propre montant/type
 * (au cas où un Plan change de prix après coup, les abonnés existants ne
 * sont pas affectés rétroactivement).
 */
@Entity
@Table(name = "plans")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Plan {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 100)
    private String nom;

    /** GROSSISTE | UTILISATEUR — rôle pouvant souscrire à ce plan. */
    @Column(name = "role_cible", nullable = false, length = 20)
    private String roleCible;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal prix;

    @Column(nullable = false, length = 10)
    @Builder.Default
    private String devise = "XAF";

    /** MENSUEL | TRIMESTRIEL | ANNUEL */
    @Column(name = "periodicite", nullable = false, length = 20)
    private String periodicite;

    /** Avantages, un par ligne (affichage uniquement, pas de logique dessus). */
    @Column(columnDefinition = "TEXT")
    private String avantages;

    @Column(name = "est_actif", nullable = false)
    @Builder.Default
    private Boolean estActif = true;

    @Column(name = "ordre_affichage")
    @Builder.Default
    private Integer ordreAffichage = 0;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;
}
