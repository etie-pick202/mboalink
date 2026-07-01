package com.mboalink.payment.entity;

import com.mboalink.auth.entity.Utilisateur;
import com.mboalink.grossiste.entity.FicheGrossiste;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
        name = "notations",
        uniqueConstraints = @UniqueConstraint(
                columnNames = {"utilisateur_id", "fiche_grossiste_id"}
        )
)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fiche_grossiste_id", nullable = false)
    private FicheGrossiste ficheGrossiste;

    @Column(nullable = false)
    private Integer note;

    @Column(columnDefinition = "TEXT")
    private String commentaire;

    @Column(name = "transaction_verifiee", nullable = false)
    @Builder.Default
    private Boolean transactionVerifiee = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "transaction_id")
    private Transaction transaction;

    /** VISIBLE | MASQUE | SIGNALE */
    @Column(name = "statut", nullable = false, length = 20)
    @Builder.Default
    private String statut = "VISIBLE";

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;

    @UpdateTimestamp
    @Column(name = "mis_a_jour_le")
    private LocalDateTime misAJourLe;
}