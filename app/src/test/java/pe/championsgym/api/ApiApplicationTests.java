package pe.championsgym.api;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

// Levanta toda la app contra PostgreSQL (docker compose up -d bd) y corre las migraciones.
@SpringBootTest
class ApiApplicationTests {

    @Test
    void arrancaYMigraLaBaseDeDatos() {
    }
}