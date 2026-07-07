package com.mboalink.admin.controller;

import com.mboalink.admin.dto.DashboardResumeDTO;
import com.mboalink.admin.service.DashboardResumeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/dashboard")
@RequiredArgsConstructor
public class DashboardResumeController {

    private final DashboardResumeService dashboardResumeService;

    @GetMapping
    public ResponseEntity<DashboardResumeDTO> getResume() {
        return ResponseEntity.ok(dashboardResumeService.getResume());
    }
}