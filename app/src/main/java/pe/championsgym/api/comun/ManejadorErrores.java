package pe.championsgym.api.comun;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

// Convierte las excepciones en respuestas JSON: {"mensaje": "..."}.
@RestControllerAdvice
public class ManejadorErrores {

    private static final Logger log = LoggerFactory.getLogger(ManejadorErrores.class);

    @ExceptionHandler(ErrorDeNegocio.class)
    public ResponseEntity<RespuestaError> negocio(ErrorDeNegocio e) {
        return ResponseEntity.status(e.getEstado()).body(new RespuestaError(e.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<RespuestaError> validacion(MethodArgumentNotValidException e) {
        String mensaje = e.getBindingResult().getFieldErrors().stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .findFirst()
                .orElse("Datos invalidos");
        return ResponseEntity.badRequest().body(new RespuestaError(mensaje));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<RespuestaError> jsonInvalido(HttpMessageNotReadableException e) {
        return ResponseEntity.badRequest().body(new RespuestaError("El cuerpo de la peticion no es un JSON valido"));
    }

    // Dato repetido que la BD rechazo (por ejemplo, dos registros al mismo tiempo con el mismo email).
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<RespuestaError> duplicado(DataIntegrityViolationException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(new RespuestaError("El registro ya existe"));
    }

    // Cualquier otro error: se registra en el log (CloudWatch) y el usuario ve un mensaje generico.
    @ExceptionHandler(Exception.class)
    public ResponseEntity<RespuestaError> inesperado(Exception e) {
        log.error("ERROR_INESPERADO", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new RespuestaError("Ocurrio un error, intenta nuevamente"));
    }
}