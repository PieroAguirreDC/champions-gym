package pe.championsgym.api.suscripciones;

import java.util.List;

import org.springframework.data.domain.Sort;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PlanController {

    private final PlanRepository planes;

    public PlanController(PlanRepository planes) {
        this.planes = planes;
    }

    // GET /api/planes: lo muestra la pagina de servicios.
    @GetMapping("/planes")
    public List<PlanRespuesta> listar() {
        return planes.findAll(Sort.by("meses")).stream().map(PlanRespuesta::de).toList();
    }
}