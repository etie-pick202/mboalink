package com.mboalink.auth.security;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.UUID;

/**
 * Utilitaire pour récupérer facilement l'utilisateur connecté
 * depuis n'importe quel Controller ou Service.
 * <p>
 * Usage : UUID id = CurrentUser.getId();
 *         String role = CurrentUser.getRole();
 */
public class CurrentUser {

    private CurrentUser() {}

    /** Retourne l'UUID de l'utilisateur connecté (extrait du JWT) */
    public static UUID getId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new IllegalStateException("Aucun utilisateur authentifié.");
        }
        return UUID.fromString((String) auth.getPrincipal());
    }

    /** Retourne le rôle Spring Security (ex: ROLE_GROSSISTE) */
    public static String getRole() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getAuthorities().isEmpty()) {
            throw new IllegalStateException("Aucun utilisateur authentifié.");
        }
        return auth.getAuthorities().iterator().next().getAuthority();
    }

    /** Vrai si une session authentifiée existe */
    public static boolean estConnecte() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null && auth.isAuthenticated()
                && !"anonymousUser".equals(auth.getPrincipal());
    }
}