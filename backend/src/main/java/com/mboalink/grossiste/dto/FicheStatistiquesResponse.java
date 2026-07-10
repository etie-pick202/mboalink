package com.mboalink.grossiste.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class FicheStatistiquesResponse {

    private long vuesMoisEnCours;
    private long contactsDebloques;

    /** 7 valeurs, la plus ancienne en premier (J-6 → aujourd'hui). */
    private List<Long> vuesParJour;
}
