package com.mboalink.auth.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class ConsentementResponseDto {

    private Boolean trackingAccepte;
    private Boolean notificationsAcceptees;
    private Boolean marketingAccepte;
    private Boolean conditionsAcceptees;
    private String versionConditions;
    private LocalDateTime misAJourLe;
}