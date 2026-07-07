package com.mboalink.admin.entity;

import com.mboalink.auth.entity.Utilisateur;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "moderations")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Moderation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "admin_id", nullable = false)
    private Utilisateur admin;

    /** SUSPENSION | BANNISSEMENT | AVERTISSEMENT | VALIDATION | REJET */
    @Column(name = "type_action", nullable = false, length = 30)
    private String typeAction;

    /** UTILISATEUR | FICHE_GROSSISTE | NOTATION | CAMPAGNE */
    @Column(name = "type_cible", nullable = false, length = 30)
    private String typeCible;

    @Column(name = "cible_id", nullable = false)
    private UUID cibleId;

    @Column(name = "motif", columnDefinition = "TEXT")
    private String motif;

    @ManyToOne(fetch = FetchType.LAZY)
  
    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;
}