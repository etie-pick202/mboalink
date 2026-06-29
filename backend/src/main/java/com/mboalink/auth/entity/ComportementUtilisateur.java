package com.mboalink.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "comportements_utilisateurs")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ComportementUtilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    /** Type d'action : RECHERCHE, VUE_FICHE, CLIC_CATEGORIE, etc. */
    @Column(name = "type_action", nullable = false, length = 50)
    private String typeAction;

    /** Valeur associée à l'action (ex: nom de la catégorie, terme recherché) */
    @Column(name = "valeur", length = 255)
    private String valeur;

    /** Localisation approximative (ville ou région) */
    @Column(name = "localisation", length = 100)
    private String localisation;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;
}