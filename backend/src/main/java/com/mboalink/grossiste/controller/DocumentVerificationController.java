package com.mboalink.grossiste.controller;

import com.mboalink.auth.security.CurrentUser;
import com.mboalink.grossiste.dto.CreerDocumentRequest;
import com.mboalink.grossiste.dto.DocumentResponse;
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

    // POST /api/v1/grossistes/{ficheId}/documents  → soumettre un document
    @PostMapping("/{ficheId}/documents")
    public ResponseEntity<DocumentResponse> ajouterDocument(
            @PathVariable UUID ficheId,
            @Valid @RequestBody CreerDocumentRequest req) {
        DocumentResponse reponse = documentService.ajouterDocument(
                CurrentUser.getId(), ficheId, req);
        return ResponseEntity.ok(reponse);
    }

    // GET /api/v1/grossistes/{ficheId}/documents  → voir ses documents soumis
    @GetMapping("/{ficheId}/documents")
    public ResponseEntity<List<DocumentResponse>> listerDocuments(
            @PathVariable UUID ficheId) {
        return ResponseEntity.ok(
                documentService.listerDocuments(CurrentUser.getId(), ficheId));
    }
}