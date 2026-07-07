package com.mboalink;

import com.mboalink.auth.security.CurrentUser;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Controller TEMPORAIRE pour valider la protection des routes par rôle.
 * À supprimer une fois que chaque domaine aura ses vrais controllers.
 */
@RestController
@RequestMapping("/api/v1")
public class TestProtectionController {

    @GetMapping("/search/test")
    public Map<String, String> testSearch() {
        return Map.of(
                "message", "Accès autorisé — route publique",
                "domaine", "search"
        );
    }

    @GetMapping("/grossiste/test")
    public Map<String, String> testGrossiste() {
        return Map.of(
                "message", "Accès autorisé — GROSSISTE ou ADMIN",
                "domaine", "grossiste",
                "utilisateurId", CurrentUser.getId().toString(),
                "role", CurrentUser.getRole()
        );
    }

    @GetMapping("/payment/test")
    public Map<String, String> testPayment() {
        return Map.of(
                "message", "Accès autorisé — UTILISATEUR, GROSSISTE ou ADMIN",
                "domaine", "payment",
                "utilisateurId", CurrentUser.getId().toString(),
                "role", CurrentUser.getRole()
        );
    }

    @GetMapping("/favoris/test")
    public Map<String, String> testFavoris() {
        return Map.of(
                "message", "Accès autorisé — UTILISATEUR, GROSSISTE ou ADMIN",
                "domaine", "favoris",
                "utilisateurId", CurrentUser.getId().toString(),
                "role", CurrentUser.getRole()
        );
    }

    @GetMapping("/admin/test")
    public Map<String, String> testAdmin() {
        return Map.of(
                "message", "Accès autorisé — ADMIN uniquement",
                "domaine", "admin",
                "utilisateurId", CurrentUser.getId().toString(),
                "role", CurrentUser.getRole()
        );
    }
}