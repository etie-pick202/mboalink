package com.mboalink.payment.entity;

import com.mboalink.auth.entity.Utilisateur;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "abonnements")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Abonnement {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false, unique = true)
    private Utilisateur utilisateur;

    /** MENSUEL | TRIMESTRIEL | ANNUEL */
    @Column(name = "type_abonnement", nullable = false, length = 20)
    private String typeAbonnement;

    @Column(name = "montant", nullable = false, precision = 10, scale = 2)
    private BigDecimal montant;

    @Column(name = "date_debut", nullable = false)
    private LocalDateTime dateDebut;

    @Column(name = "date_fin", nullable = false)
    private LocalDateTime dateFin;

    /** ACTIF | EXPIRE | SUSPENDU | ANNULE */
    @Column(name = "statut", nullable = false, length = 20)
    @Builder.Default
    private String statut = "ACTIF";

    @Column(name = "renouvellement_auto", nullable = false)
    @Builder.Default
    private Boolean renouvellementAuto = false;

    @Column(name = "rappel_envoye", nullable = false)
    @Builder.Default
    private Boolean rappelEnvoye = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "transaction_id")
    private Transaction transaction;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;

    @Column(name = "mis_a_jour_le")
    private LocalDateTime misAJourLe;
}