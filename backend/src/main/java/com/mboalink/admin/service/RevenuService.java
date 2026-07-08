package com.mboalink.admin.service;

import com.mboalink.admin.dto.RevenuMensuelDTO;
import com.mboalink.payment.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.TextStyle;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RevenuService {

    private final TransactionRepository transactionRepository;

    public List<RevenuMensuelDTO> getRevenusDerniers4Mois() {
        LocalDate aujourdHui = LocalDate.now();
        int anneeEnCours = aujourdHui.getYear();
        int moisEnCours = aujourdHui.getMonthValue();

        // Les 4 derniers mois calendaires de l'année en cours (borné à janvier minimum)
        int moisDebut = Math.max(1, moisEnCours - 3);
        int moisFin = moisEnCours;

        // On initialise chaque mois à 0, pour ne pas avoir de trou dans le résultat
        Map<Integer, BigDecimal> revenusParMois = new LinkedHashMap<>();
        for (int m = moisDebut; m <= moisFin; m++) {
            revenusParMois.put(m, BigDecimal.ZERO);
        }

        // On remplit avec les vraies données trouvées en base
        List<Object[]> resultats = transactionRepository.getRevenusParMois(anneeEnCours, moisDebut, moisFin);
        for (Object[] ligne : resultats) {
            int mois = ((Number) ligne[0]).intValue();
            BigDecimal total = (BigDecimal) ligne[1];
            revenusParMois.put(mois, total);
        }

        return revenusParMois.entrySet().stream()
                .map(entry -> RevenuMensuelDTO.builder()
                        .numeroMois(entry.getKey())
                        .mois(nomDuMois(entry.getKey()))
                        .total(entry.getValue())
                        .build())
                .toList();
    }

    private String nomDuMois(int numeroMois) {
        return LocalDate.of(2000, numeroMois, 1)
                .getMonth()
                .getDisplayName(TextStyle.FULL, Locale.FRENCH);
    }
}