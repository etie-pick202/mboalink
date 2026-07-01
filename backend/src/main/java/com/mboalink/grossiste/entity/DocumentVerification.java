package com.mboalink.grossiste.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "documents_verification")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DocumentVerification {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fiche_grossiste_id", nullable = false)
    private FicheGrossiste ficheGrossiste;

    /** REGISTRE_COMMERCE | CARTE_CONTRIBUABLE | CNI | AUTRE */
    @Column(name = "type_document", nullable = false, length = 50)
    private String typeDocument;

    @Column(name = "url_document", nullable = false, length = 500)
    private String urlDocument;

    /** EN_ATTENTE | APPROUVE | REJETE */
    @Column(name = "statut", nullable = false, length = 20)
    @Builder.Default
    private String statut = "EN_ATTENTE";

    @Column(name = "commentaire_admin", columnDefinition = "TEXT")
    private String commentaireAdmin;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;

    @Column(name = "traite_le")
    private LocalDateTime traiteLe;
}