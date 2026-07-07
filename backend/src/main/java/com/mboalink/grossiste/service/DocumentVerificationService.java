package com.mboalink.grossiste.service;

import com.mboalink.grossiste.dto.CreerDocumentRequest;
import com.mboalink.grossiste.dto.DocumentResponse;
import com.mboalink.grossiste.entity.DocumentVerification;
import com.mboalink.grossiste.entity.FicheGrossiste;
import com.mboalink.grossiste.repository.DocumentVerificationRepository;
import com.mboalink.grossiste.repository.FicheGrossisteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DocumentVerificationService {

    private final DocumentVerificationRepository documentRepository;
    private final FicheGrossisteRepository ficheRepository;

    // Ajouter un document de vérification à sa fiche
    public DocumentResponse ajouterDocument(UUID utilisateurId, UUID ficheId, CreerDocumentRequest req) {

        // 1. Récupérer la fiche
        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new IllegalStateException("Fiche introuvable."));

        // 2. Sécurité : la fiche doit appartenir à l'utilisateur connecté
        if (!fiche.getUtilisateur().getId().equals(utilisateurId)) {
            throw new IllegalStateException("Vous ne pouvez ajouter des documents qu'à votre propre fiche.");
        }

        // 3. Construire le document (statut EN_ATTENTE par défaut)
        DocumentVerification document = DocumentVerification.builder()
                .ficheGrossiste(fiche)
                .typeDocument(req.getTypeDocument())
                .urlDocument(req.getUrlDocument())
                .statut("EN_ATTENTE")
                .build();

        // 4. Sauvegarder
        DocumentVerification sauvegarde = documentRepository.save(document);

        // 5. Renvoyer la réponse
        return DocumentResponse.depuis(sauvegarde);
    }

    // Lister les documents d'une fiche (pour que le grossiste voie ses documents soumis)
    public List<DocumentResponse> listerDocuments(UUID utilisateurId, UUID ficheId) {

        FicheGrossiste fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new IllegalStateException("Fiche introuvable."));

        if (!fiche.getUtilisateur().getId().equals(utilisateurId)) {
            throw new IllegalStateException("Vous ne pouvez voir que les documents de votre propre fiche.");
        }

        return documentRepository.findByFicheGrossisteId(ficheId).stream()
                .map(DocumentResponse::depuis)
                .collect(Collectors.toList());
    }
}