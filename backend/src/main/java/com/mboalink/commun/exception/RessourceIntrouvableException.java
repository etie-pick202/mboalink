package com.mboalink.commun.exception;

/** Ressource demandée absente en base — mappée en HTTP 404 par GlobalExceptionHandler. */
public class RessourceIntrouvableException extends RuntimeException {
    public RessourceIntrouvableException(String message) {
        super(message);
    }
}
