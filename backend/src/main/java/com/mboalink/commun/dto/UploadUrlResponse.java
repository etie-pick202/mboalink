package com.mboalink.commun.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UploadUrlResponse {

    private String uploadUrl;   // URL signée pour uploader (Flutter l'utilise directement)
    private String filePath;    // chemin du fichier dans le bucket (à renvoyer après upload)
    private int expiresIn;      // durée de validité en secondes
}