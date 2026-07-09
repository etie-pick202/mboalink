package com.mboalink.payment.entity;

import com.mboalink.auth.entity.Utilisateur;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "transactions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    /** DEVERROUILLAGE_COORDONNEES | ABONNEMENT | REINITIALISATION_NOTE */
    @Column(name = "type_transaction", nullable = false, length = 50)
    private String typeTransaction;

    @Column(name = "montant", nullable = false, precision = 10, scale = 2)
    private BigDecimal montant;

    @Column(name = "devise", nullable = false, length = 10)
    @Builder.Default
    private String devise = "XAF";

    /** MTN_MOMO | ORANGE_MONEY */
    @Column(name = "operateur", length = 20)
    private String operateur;

    @Column(name = "numero_telephone_paiement", length = 20)
    private String numeroTelephonePaiement;

    @Column(name = "reference_externe", length = 100)
    private String referenceExterne;

    /**
     * ID de la fiche grossiste concernée.
     * Requis uniquement pour DEVERROUILLAGE_COORDONNEES.
     */
    @Column(name = "fiche_grossiste_id")
    private UUID ficheGrossisteId;

    /** EN_ATTENTE | SUCCES | ECHEC | REMBOURSE */
    @Column(name = "statut", nullable = false, length = 20)
    @Builder.Default
    private String statut = "EN_ATTENTE";

    @Column(name = "description", length = 255)
    private String description;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;

    @Column(name = "traite_le")
    private LocalDateTime traiteLe;
}