package com.mboalink.admin.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class AvisSignaleResponseDTO {
    private long total;
    private List<AvisSignaleDTO> avis;
}