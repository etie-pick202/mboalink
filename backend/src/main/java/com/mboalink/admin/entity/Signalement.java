package com.mboalink.admin.entity;

import com.mboalink.auth.entity.Utilisateur;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "signalements")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Signalement {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "signaleur_id", nullable = false)
    private Utilisateur signaleur;

    /** FICHE_GROSSISTE | NOTATION | UTILISATEUR */
    @Column(name = "type_cible", nullable = false, length = 30)
    private String typeCible;

    @Column(name = "cible_id", nullable = false)
    private UUID cibleId;

    /** CONTENU_INAPPROPRIE | FAUSSE_INFO | SPAM | ARNAQUE | AUTRE */
    @Column(name = "motif", nullable = false, length = 50)
    private String motif;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    /** EN_ATTENTE | TRAITE | REJETE */
    @Column(name = "statut", nullable = false, length = 20)
    @Builder.Default
    private String statut = "EN_ATTENTE";

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "admin_id")
    private Utilisateur admin;

    @Column(name = "commentaire_admin", columnDefinition = "TEXT")
    private String commentaireAdmin;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;

    @Column(name = "traite_le")
    private LocalDateTime traiteLe;
}