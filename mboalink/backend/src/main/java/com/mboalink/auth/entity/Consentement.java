package com.mboalink.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "consentements")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Consentement {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    @Column(name = "tracking_accepte", nullable = false)
    @Builder.Default
    private Boolean trackingAccepte = false;

    @Column(name = "notifications_acceptees", nullable = false)
    @Builder.Default
    private Boolean notificationsAcceptees = false;

    @Column(name = "marketing_accepte", nullable = false)
    @Builder.Default
    private Boolean marketingAccepte = false;

    @Column(name = "conditions_acceptees", nullable = false)
    @Builder.Default
    private Boolean conditionsAcceptees = false;

    @Column(name = "version_conditions", length = 20)
    private String versionConditions;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;

    @Column(name = "mis_a_jour_le")
    private LocalDateTime misAJourLe;
}