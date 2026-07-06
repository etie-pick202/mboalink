package com.mboalink.search.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FilActualiteResponseDto {

    private List<FilActualiteItemDto> resultats;
    private long totalElements;
    private int totalPages;
    private int page;
    private int taille;
    private boolean dernierePage;
    private boolean personnalise;
}
