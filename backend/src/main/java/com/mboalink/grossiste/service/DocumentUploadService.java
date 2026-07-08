package com.mboalink.grossiste.service;

import com.mboalink.commun.dto.UploadUrlRequest;
import com.mboalink.commun.dto.UploadUrlResponse;
import com.mboalink.grossiste.dto.ConfirmerUploadRequest;
import com.mboalink.grossiste.dto.DocumentResponse;
import com.mboalink.grossiste.entity.DocumentVerification;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.DocumentVerificationRepository;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import com.mboalink.commun.service.SupabaseStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DocumentUploadService {

    private final SupabaseStorageService supabaseService;
    private final FicheGrossisteRepository ficheRepository;
    private final DocumentVerificationRepository documentRepository;

    @Value("${supabase.bucket}")
    private String bucket;

    // Étape 1 : Générer une URL signée pour que Flutter uploade directement
    public UploadUrlResponse genererUrlUpload(UUID utilisateurId, UUID ficheId, UploadUrlRequest req) {

        // Vérifier que la fiche existe et appartient à cet utilisateur
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new IllegalStateException("Fiche introuvable."));

        if (!fiche.getUtilisateur().getId().equals(utilisateurId)) {
            throw new IllegalStateException("Vous ne pouvez uploader que pour votre propre fiche.");
        }

        // Construire le chemin du fichier dans le bucket
        // Ex: "grossistes/uuid-fiche/CNI/uuid.jpg"
        String filePath = "grossistes/" + ficheId + "/" 
                + req.getTypeDocument() + "/" 
                + UUID.randomUUID() + "." + req.getExtension();

        // Générer l'URL signée (valable 5 minutes)
        String uploadUrl = supabaseService.genererUrlUpload(filePath, 300);

        return UploadUrlResponse.builder()
                .uploadUrl(uploadUrl)
                .filePath(filePath)
                .expiresIn(300)
                .build();
    }

    // Étape 2 : Confirmer que l'upload a réussi et enregistrer en base
    public DocumentResponse confirmerUpload(UUID utilisateurId, UUID ficheId, ConfirmerUploadRequest req) {

        // Vérifier que la fiche existe et appartient à cet utilisateur
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new IllegalStateException("Fiche introuvable."));

        if (!fiche.getUtilisateur().getId().equals(utilisateurId)) {
            throw new IllegalStateException("Vous ne pouvez confirmer que pour votre propre fiche.");
        }

        // Construire l'URL du fichier dans Supabase
        String urlDocument = supabaseService.construireUrl(req.getFilePath());

        // Enregistrer le document en base
        DocumentVerification document = DocumentVerification.builder()
                .ficheGrossiste(fiche)
                .typeDocument(req.getTypeDocument())
                .urlDocument(urlDocument)
                .statut("EN_ATTENTE")
                .build();

        DocumentVerification sauvegarde = documentRepository.save(document);
        return DocumentResponse.depuis(sauvegarde);
    }
}