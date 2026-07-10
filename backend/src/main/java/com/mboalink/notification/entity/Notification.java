package com.mboalink.notification.entity;

import com.mboalink.auth.entity.Utilisateur;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "notifications")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    /** NOUVEAU_GROSSISTE | BAISSE_PRIX | RECU_PAIEMENT | FAVORI_CERTIFIE */
    @Column(nullable = false, length = 30)
    private String type;

    @Column(nullable = false, length = 150)
    private String titre;

    @Column(columnDefinition = "TEXT")
    private String message;

    /** Id de la ressource liée (fiche, reçu...) pour la navigation au tap. */
    @Column(name = "reference_id", length = 100)
    private String referenceId;

    @Column(name = "lu_le")
    private LocalDateTime luLe;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;
}
