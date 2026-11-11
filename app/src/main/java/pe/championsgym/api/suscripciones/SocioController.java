package pe.championsgym.api.suscripciones;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import pe.championsgym.api.comun.SesionSocio;

@RestController
@RequestMapping("/socios")
public class SocioController {

    private final SocioService servicio;

    public SocioController(SocioService servicio) {
        this.servicio = servicio;
    }

    // POST /api/socios: inscripcion de un socio nuevo.
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public SocioRespuesta registrar(@Valid @RequestBody RegistroSocio datos) {
        return servicio.registrar(datos);
    }

    // GET /api/socios/yo: datos del socio logueado.
    @GetMapping("/yo")
    public SocioRespuesta yo(HttpServletRequest request) {
        return servicio.buscar(SesionSocio.socioActual(request));
    }
}