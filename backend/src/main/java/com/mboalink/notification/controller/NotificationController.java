package com.mboalink.notification.controller;

import com.mboalink.auth.security.CurrentUser;
import com.mboalink.notification.dto.NotificationResponseDTO;
import com.mboalink.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<List<NotificationResponseDTO>> mesNotifications() {
        return ResponseEntity.ok(notificationService.listerMesNotifications(CurrentUser.getId()));
    }

    @GetMapping("/non-lues/compte")
    public ResponseEntity<Map<String, Long>> compterNonLues() {
        return ResponseEntity.ok(Map.of("compte", notificationService.compterNonLues(CurrentUser.getId())));
    }

    @PatchMapping("/{notificationId}/lue")
    public ResponseEntity<Void> marquerCommeLue(@PathVariable UUID notificationId) {
        notificationService.marquerCommeLue(CurrentUser.getId(), notificationId);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/lues")
    public ResponseEntity<Void> marquerToutesCommeLues() {
        notificationService.marquerToutesCommeLues(CurrentUser.getId());
        return ResponseEntity.noContent().build();
    }
}
