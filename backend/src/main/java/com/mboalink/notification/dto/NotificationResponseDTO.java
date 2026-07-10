package com.mboalink.notification.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class NotificationResponseDTO {

    private UUID id;
    private String type;
    private String titre;
    private String message;
    private String referenceId;
    private boolean lu;
    private LocalDateTime creeLe;
}
