package pe.championsgym.api.suscripciones;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface SocioRepository extends JpaRepository<Socio, Long> {

    Optional<Socio> findByEmail(String email);

    boolean existsByEmail(String email);

    boolean existsByDni(String dni);
}