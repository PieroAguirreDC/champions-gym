package pe.championsgym.api.suscripciones;

import java.math.BigDecimal;

public record PlanRespuesta(Long id, String nombre, BigDecimal precio, Integer meses, String descripcion) {

    static PlanRespuesta de(Plan plan) {
        return new PlanRespuesta(plan.getId(), plan.getNombre(), plan.getPrecio(), plan.getMeses(), plan.getDescripcion());
    }
}