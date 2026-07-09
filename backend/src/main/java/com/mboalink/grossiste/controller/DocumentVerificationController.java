package com.mboalink.grossiste.controller;

import com.mboalink.auth.security.CurrentUser;
import com.mboalink.commun.dto.UploadUrlRequest;
import com.mboalink.commun.dto.UploadUrlResponse;
import com.mboalink.grossiste.dto.ConfirmerUploadRequest;
import com.mboalink.grossiste.dto.CreerDocumentRequest;
import com.mboalink.grossiste.dto.DocumentResponse;
import com.mboalink.grossiste.service.DocumentUploadService;
import com.mboalink.grossiste.service.DocumentVerificationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/grossistes")
@RequiredArgsConstructor
public class DocumentVerificationController {

    private final DocumentVerificationService documentService;
    private final DocumentUploadService documentUploadService;

    // POST /api/v1/grossistes/{ficheId}/documents → soumettre un document (ancienne route)
    @PostMapping("/{ficheId}/documents")
    public ResponseEntity<DocumentResponse> ajouterDocument(
            @PathVariable UUID ficheId,
            @Valid @RequestBody CreerDocumentRequest req) {
        DocumentResponse reponse = documentService.ajouterDocument(
                CurrentUser.getId(), ficheId, req);
        return ResponseEntity.ok(reponse);
    }

    // GET /api/v1/grossistes/{ficheId}/documents → voir ses documents soumis
    @GetMapping("/{ficheId}/documents")
    public ResponseEntity<List<DocumentResponse>> listerDocuments(
            @PathVariable UUID ficheId) {
        return ResponseEntity.ok(
                documentService.listerDocuments(CurrentUser.getId(), ficheId));
    }

    // POST /api/v1/grossistes/{ficheId}/documents/upload-url → générer URL d'upload
    @PostMapping("/{ficheId}/documents/upload-url")
    public ResponseEntity<UploadUrlResponse> genererUrlUpload(
            @PathVariable UUID ficheId,
            @Valid @RequestBody UploadUrlRequest req) {
        return ResponseEntity.ok(
                documentUploadService.genererUrlUpload(CurrentUser.getId(), ficheId, req));
    }

    // POST /api/v1/grossistes/{ficheId}/documents/confirmer → confirmer l'upload
    @PostMapping("/{ficheId}/documents/confirmer")
    public ResponseEntity<DocumentResponse> confirmerUpload(
            @PathVariable UUID ficheId,
            @Valid @RequestBody ConfirmerUploadRequest req) {
        return ResponseEntity.ok(
                documentUploadService.confirmerUpload(CurrentUser.getId(), ficheId, req));
    }
}