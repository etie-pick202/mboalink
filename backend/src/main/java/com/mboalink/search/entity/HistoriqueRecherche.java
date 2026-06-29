package com.mboalink.search.entity;

import com.mboalink.auth.entity.Utilisateur;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "historique_recherches")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HistoriqueRecherche {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id")
    private Utilisateur utilisateur;

    @Column(name = "terme_recherche", nullable = false, length = 255)
    private String termeRecherche;

    @Column(name = "categorie", length = 100)
    private String categorie;

    @Column(name = "localisation", length = 100)
    private String localisation;

    @Column(name = "nombre_resultats")
    private Integer nombreResultats;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;
}