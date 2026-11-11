package pe.championsgym.api.comun.eventos;

// Contrato entre modulos: lo publica suscripciones (fase 1)
// y lo escucha correos para mandar la bienvenida (fase 3).
public record SocioRegistrado(Long socioId, String nombre, String email) {
}