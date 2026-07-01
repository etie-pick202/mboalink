package com.mboalink.auth.dto;

import lombok.Data;

@Data
public class MettreAJourConsentementRequest {

    private Boolean trackingAccepte;
    private Boolean notificationsAcceptees;
    private Boolean marketingAccepte;
    private Boolean conditionsAcceptees;
    private String versionConditions;
}