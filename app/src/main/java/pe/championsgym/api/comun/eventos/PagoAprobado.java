package pe.championsgym.api.comun.eventos;

import java.math.BigDecimal;

// Contrato entre modulos: lo publica pagos (fase 3)
// y lo escucha correos para mandar la confirmacion (fase 3).
public record PagoAprobado(Long pagoId, Long socioId, String nombre, String email, String plan, BigDecimal monto) {
}
