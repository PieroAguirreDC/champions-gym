package pe.championsgym.api.suscripciones;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

// Prueba sin base de datos: el servicio es un simulacro (mock).
@WebMvcTest(SocioController.class)
class SocioControllerTest {

    @Autowired
    private MockMvc mvc;

    @MockitoBean
    private SocioService servicio;

    @Test
    void registraUnSocio() throws Exception {
        when(servicio.registrar(any())).thenReturn(new SocioRespuesta(1L, "Ana Torres", "ana@correo.com"));

        mvc.perform(post("/socios").contentType(MediaType.APPLICATION_JSON).content("""
                {"nombre": "Ana Torres", "email": "ana@correo.com", "dni": "45678912", "password": "clave12345"}
                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1));
    }

    @Test
    void rechazaUnDniInvalido() throws Exception {
        mvc.perform(post("/socios").contentType(MediaType.APPLICATION_JSON).content("""
                {"nombre": "Ana Torres", "email": "ana@correo.com", "dni": "123", "password": "clave12345"}
                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensaje").value("dni: debe tener 8 digitos"));
    }

    @Test
    void sinSesionResponde401() throws Exception {
        mvc.perform(get("/socios/yo"))
                .andExpect(status().isUnauthorized());
    }
}