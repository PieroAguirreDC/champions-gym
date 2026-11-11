package pe.championsgym.api.suscripciones;

import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import pe.championsgym.api.comun.ErrorDeNegocio;
import pe.championsgym.api.comun.eventos.SocioRegistrado;

@Service
public class SocioService {

    private static final Logger log = LoggerFactory.getLogger(SocioService.class);

    private final SocioRepository socios;
    private final ApplicationEventPublisher eventos;
    private final PasswordEncoder encoder = new BCryptPasswordEncoder();

    public SocioService(SocioRepository socios, ApplicationEventPublisher eventos) {
        this.socios = socios;
        this.eventos = eventos;
    }

    @Transactional
    public SocioRespuesta registrar(RegistroSocio datos) {
        String email = datos.email().trim().toLowerCase();
        if (socios.existsByEmail(email)) {
            throw ErrorDeNegocio.conflicto("Ya existe un socio con ese email");
        }
        if (socios.existsByDni(datos.dni())) {
            throw ErrorDeNegocio.conflicto("Ya existe un socio con ese DNI");
        }
        Socio socio = socios.save(new Socio(datos.nombre().trim(), email, datos.dni(), encoder.encode(datos.password())));

        // Otros modulos reaccionan a este evento (correos manda la bienvenida en la fase 3).
        eventos.publishEvent(new SocioRegistrado(socio.getId(), socio.getNombre(), socio.getEmail()));
        log.info("SOCIO_REGISTRADO socioId={}", socio.getId());
        return SocioRespuesta.de(socio);
    }

    @Transactional(readOnly = true)
    public Optional<Socio> autenticar(String email, String password) {
        return socios.findByEmail(email.trim().toLowerCase())
                .filter(socio -> encoder.matches(password, socio.getPasswordHash()));
    }

    @Transactional(readOnly = true)
    public SocioRespuesta buscar(Long id) {
        return socios.findById(id)
                .map(SocioRespuesta::de)
                .orElseThrow(() -> ErrorDeNegocio.noEncontrado("Socio no encontrado"));
    }
}