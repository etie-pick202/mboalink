package com.mboalink.search.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GrossisteSearchResultDto {

    private UUID id;
    private String nomEntreprise;
    private String secteurActivite;
    private String ville;
    private String quartier;
    private String logoUrl;
    private Double noteMoyenne;
    private Integer nombreAvis;
    private Boolean certifie;
}
