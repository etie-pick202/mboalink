package com.mboalink.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class OtpVerificationRequest {

    @NotBlank(message = "La cible est obligatoire")
    private String cible;

    @NotBlank(message = "Le code OTP est obligatoire")
    @Size(min = 6, max = 6, message = "Le code OTP doit contenir exactement 6 chiffres")
    private String code;

    @NotBlank(message = "Le type OTP est obligatoire")
    private String type;
}