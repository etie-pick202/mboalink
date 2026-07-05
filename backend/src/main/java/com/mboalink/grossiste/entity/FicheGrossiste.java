package com.mboalink.grossiste.entity;

import com.mboalink.auth.entity.Utilisateur;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "fiches_grossistes")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FicheGrossiste {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false, unique = true)
    private Utilisateur utilisateur;

    @Column(name = "nom_entreprise", nullable = false, length = 200)
    private String nomEntreprise;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "secteur_activite", length = 100)
    private String secteurActivite;

    @Column(name = "annee_creation")
    private Integer anneeCreation;

    @Column(name = "ville", length = 100)
    private String ville;

    @Column(name = "quartier", length = 100)
    private String quartier;

    @Column(name = "adresse_complete", columnDefinition = "TEXT")
    private String adresseComplete;

    @Column(name = "telephone_professionnel", length = 20)
    private String telephoneProfessionnel;

    @Column(name = "email_professionnel", length = 150)
    private String emailProfessionnel;

    @Column(name = "site_web", length = 255)
    private String siteWeb;

    @Column(name = "logo_url", length = 500)
    private String logoUrl;

    /** EN_ATTENTE | VERIFIE | REJETE | SUSPENDU */
    @Column(name = "statut_verification", nullable = false, length = 20)
    @Builder.Default
    private String statutVerification = "EN_ATTENTE";

    @Column(name = "note_moyenne")
    @Builder.Default
    private Double noteMoyenne = 0.0;

    @Column(name = "nombre_avis")
    @Builder.Default
    private Integer nombreAvis = 0;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    @Column(name = "coordonnees_visibles", nullable = false)
    @Builder.Default
    private Boolean coordonneesVisibles = false;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;

    @UpdateTimestamp
    @Column(name = "mis_a_jour_le")
    private LocalDateTime misAJourLe;
}