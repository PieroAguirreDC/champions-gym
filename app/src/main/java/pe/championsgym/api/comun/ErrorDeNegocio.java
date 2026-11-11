package pe.championsgym.api.comun;

import org.springframework.http.HttpStatus;

// Error esperado del negocio (aforo lleno, email repetido, etc.).
// ManejadorErrores lo convierte en {"mensaje": "..."} con su codigo HTTP.
public class ErrorDeNegocio extends RuntimeException {

    private final HttpStatus estado;

    public ErrorDeNegocio(HttpStatus estado, String mensaje) {
        super(mensaje);
        this.estado = estado;
    }

    public HttpStatus getEstado() {
        return estado;
    }

    public static ErrorDeNegocio noEncontrado(String mensaje) {
        return new ErrorDeNegocio(HttpStatus.NOT_FOUND, mensaje);
    }

    public static ErrorDeNegocio conflicto(String mensaje) {
        return new ErrorDeNegocio(HttpStatus.CONFLICT, mensaje);
    }

    public static ErrorDeNegocio invalido(String mensaje) {
        return new ErrorDeNegocio(HttpStatus.BAD_REQUEST, mensaje);
    }

    public static ErrorDeNegocio noAutenticado() {
        return new ErrorDeNegocio(HttpStatus.UNAUTHORIZED, "Inicia sesion para continuar");
    }
}