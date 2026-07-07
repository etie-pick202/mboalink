package com.mboalink.auth.entity;

import com.mboalink.auth.enums.Role;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "utilisateurs")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Utilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(length = 100)
    private String nom;

    @Column(length = 100)
    private String prenom;

    @Column(unique = true, length = 150)
    private String email;

    @Column(unique = true, length = 20)
    private String telephone;

    @Column(name = "mot_de_passe_hash")
    private String motDePasseHash;

    @Column(name = "google_id", length = 100)
    private String googleId;

    @Column(name = "facebook_id", length = 100)
    private String facebookId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private Role role = Role.UTILISATEUR;

    @Column(name = "email_verifie", nullable = false)
    @Builder.Default
    private Boolean emailVerifie = false;

    @Column(name = "telephone_verifie", nullable = false)
    @Builder.Default
    private Boolean telephoneVerifie = false;

    @Column(name = "est_actif", nullable = false)
    @Builder.Default
    private Boolean estActif = true;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;

    @UpdateTimestamp
    @Column(name = "mis_a_jour_le")
    private LocalDateTime misAJourLe;
}