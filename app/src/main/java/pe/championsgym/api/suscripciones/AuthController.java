package pe.championsgym.api.suscripciones;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import pe.championsgym.api.comun.RespuestaError;
import pe.championsgym.api.comun.SesionSocio;

@RestController
@RequestMapping("/auth")
public class AuthController {

    // Cada intento queda en el log del contenedor -> CloudWatch Logs (RNF 6).
    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    private final SocioService servicio;

    public AuthController(SocioService servicio) {
        this.servicio = servicio;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody Credenciales credenciales, HttpServletRequest request) {
        return servicio.autenticar(credenciales.email(), credenciales.password())
                .<ResponseEntity<?>>map(socio -> {
                    SesionSocio.iniciar(request, socio.getId());
                    log.info("LOGIN_OK socioId={}", socio.getId());
                    return ResponseEntity.ok(SocioRespuesta.de(socio));
                })
                .orElseGet(() -> {
                    log.warn("LOGIN_FALLIDO email={}", ocultar(credenciales.email()));
                    return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                            .body(new RespuestaError("Email o contrasena incorrectos"));
                });
    }

    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void logout(HttpServletRequest request) {
        SesionSocio.cerrar(request);
    }

    // a***@gmail.com: el log sirve para ver ataques sin guardar el email completo.
    private static String ocultar(String email) {
        int arroba = email.indexOf('@');
        return arroba < 1 ? "***" : email.charAt(0) + "***" + email.substring(arroba);
    }
}