package pe.championsgym.api.suscripciones;

// Lo que la API muestra de un socio (nunca el hash de la contrasena).
public record SocioRespuesta(Long id, String nombre, String email) {

    static SocioRespuesta de(Socio socio) {
        return new SocioRespuesta(socio.getId(), socio.getNombre(), socio.getEmail());
    }
}
