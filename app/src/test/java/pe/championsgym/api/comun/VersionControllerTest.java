package pe.championsgym.api.comun;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

// Prueba sin base de datos: solo el controlador.
@WebMvcTest(VersionController.class)
class VersionControllerTest {

    @Autowired
    private MockMvc mvc;

    @Test
    void devuelveLaVersion() throws Exception {
        mvc.perform(get("/version"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.version").value("local"));
    }
}