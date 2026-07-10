package com.mboalink.commun.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UploadUrlResponse {

    private String uploadUrl;   // URL signée pour uploader (Flutter l'utilise directement)
    private String filePath;    // chemin du fichier dans le bucket (à renvoyer après upload)
    private int expiresIn;      // durée de validité en secondes

    // URL publique finale du fichier une fois uploadé — déterministe
    // (aucun appel réseau), calculable dès la génération de l'URL signée.
    // Évite un aller-retour de confirmation supplémentaire pour les flux
    // qui n'ont pas besoin de validation admin (ex: photos produits).
    private String finalUrl;
}