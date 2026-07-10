package com.mboalink.commun.exception;

/**
 * Violation d'une règle métier liée à l'état courant de la ressource
 * (ex : création en double) — mappée en HTTP 409 par GlobalExceptionHandler.
 */
public class ConflitMetierException extends RuntimeException {
    public ConflitMetierException(String message) {
        super(message);
    }
}
