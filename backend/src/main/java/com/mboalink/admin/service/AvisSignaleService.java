package com.mboalink.admin.service;

import com.mboalink.admin.dto.AvisSignaleDTO;
import com.mboalink.admin.dto.AvisSignaleResponseDTO;
import com.mboalink.admin.repository.NotationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AvisSignaleService {

    private static final int SEUIL_NOTE = 3;

    private final NotationRepository notationRepository;

    public AvisSignaleResponseDTO getAvisSignales() {
        var avis = notationRepository.findByNoteLessThanOrderByCreeLeDesc(SEUIL_NOTE)
                .stream()
                .map(AvisSignaleDTO::fromEntity)
                .toList();

        long total = notationRepository.countByNoteLessThan(SEUIL_NOTE);

        return AvisSignaleResponseDTO.builder()
                .total(total)
                .avis(avis)
                .build();
    }
}