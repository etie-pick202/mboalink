package com.mboalink.grossiste.entity;

import com.mboalink.auth.entity.Utilisateur;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
        name = "deverrouillages_coordonnees",
        uniqueConstraints = @UniqueConstraint(
                columnNames = {"utilisateur_id", "fiche_grossiste_id"}
        )
)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeverrouillageCoordonnees {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fiche_grossiste_id", nullable = false)
    private FicheGrossiste ficheGrossiste;

    @Column(name = "montant_paye", nullable = false, precision = 10, scale = 2)
    private BigDecimal montantPaye;

    @Column(name = "reference_transaction", length = 100)
    private String referenceTransaction;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;
}