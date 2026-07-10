package com.mboalink.commun.exception;

/**
 * Action refusée : mauvais rôle ou ressource n'appartenant pas à
 * l'utilisateur connecté — mappée en HTTP 403 par GlobalExceptionHandler.
 */
public class AccesRefuseException extends RuntimeException {
    public AccesRefuseException(String message) {
        super(message);
    }
}
