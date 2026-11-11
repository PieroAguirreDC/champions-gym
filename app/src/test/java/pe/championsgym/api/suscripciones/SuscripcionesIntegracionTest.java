package pe.championsgym.api.suscripciones;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import jakarta.servlet.http.Cookie;

// Prueba completa contra PostgreSQL: registro -> login -> perfil (con la cookie de sesion).
@SpringBootTest
@AutoConfigureMockMvc
class SuscripcionesIntegracionTest {

    @Autowired
    private MockMvc mvc;

    @Test
    void listaLosTresPlanes() throws Exception {
        mvc.perform(get("/planes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(3))
                .andExpect(jsonPath("$[0].nombre").value("Mensual"));
    }

    @Test
    void registroLoginYPerfil() throws Exception {
        String email = "socio" + System.nanoTime() + "@correo.com";
        String dni = String.format("%08d", Math.floorMod(System.nanoTime(), 100_000_000L));

        mvc.perform(post("/socios").contentType(MediaType.APPLICATION_JSON).content("""
                {"nombre": "Ana Torres", "email": "%s", "dni": "%s", "password": "clave12345"}
                """.formatted(email, dni)))
                .andExpect(status().isCreated());

        mvc.perform(post("/auth/login").contentType(MediaType.APPLICATION_JSON).content("""
                {"email": "%s", "password": "otra-clave"}
                """.formatted(email)))
                .andExpect(status().isUnauthorized());

        Cookie sesion = mvc.perform(post("/auth/login").contentType(MediaType.APPLICATION_JSON).content("""
                {"email": "%s", "password": "clave12345"}
                """.formatted(email)))
                .andExpect(status().isOk())
                .andReturn().getResponse().getCookie("SESSION");

        mvc.perform(get("/socios/yo").cookie(sesion))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value(email));
    }
}