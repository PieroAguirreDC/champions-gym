package pe.championsgym.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

// Monolito modular: cada paquete es un modulo (comun, suscripciones, aforo, pagos, correos)
// y cada modulo tiene su propio esquema en PostgreSQL.
@SpringBootApplication
public class ApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(ApiApplication.class, args);
    }
}