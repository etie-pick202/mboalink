package com.mboalink.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LogoutRequest {

    @NotBlank(message = "Le refresh token est obligatoire")
    private String refreshToken;
}