package com.mboalink.commun.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

/**
 * Service partagé pour le stockage de fichiers sur Supabase Storage.
 * Utilisable par tous les modules : grossiste, auth (photo profil), etc.
 */
@Service
public class SupabaseStorageService {

    @Value("${supabase.url}")
    private String supabaseUrl;

    @Value("${supabase.key}")
    private String supabaseKey;

    @Value("${supabase.bucket}")
    private String bucket;

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Génère une URL signée pour uploader un fichier vers Supabase.
     * Flutter utilisera cette URL pour uploader directement sans passer par le backend.
     */
    public String genererUrlUpload(String filePath, int expiresIn) {
        String url = supabaseUrl + "/storage/v1/object/upload/sign/" + bucket + "/" + filePath;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + supabaseKey);
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(
                Map.of("expiresIn", expiresIn), headers
        );

        ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);

        if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
            String signedUrl = (String) response.getBody().get("url");
            return supabaseUrl + "/storage/v1" + signedUrl;
        }

        throw new IllegalStateException("Impossible de générer l'URL d'upload Supabase.");
    }

    /**
     * Génère une URL signée pour lire/télécharger un fichier depuis Supabase.
     * Pour les documents sensibles (CNI, RCCM) — accès temporaire et sécurisé.
     */
    public String genererUrlLecture(String filePath, int expiresIn) {
        String url = supabaseUrl + "/storage/v1/object/sign/" + bucket + "/" + filePath;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + supabaseKey);
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(
                Map.of("expiresIn", expiresIn), headers
        );

        ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);

        if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
            String signedUrl = (String) response.getBody().get("signedURL");
            return supabaseUrl + "/storage/v1" + signedUrl;
        }

        throw new IllegalStateException("Impossible de générer l'URL de lecture Supabase.");
    }

    /**
     * Construit l'URL publique d'un fichier après upload.
     */
    public String construireUrl(String filePath) {
        return supabaseUrl + "/storage/v1/object/" + bucket + "/" + filePath;
    }
}