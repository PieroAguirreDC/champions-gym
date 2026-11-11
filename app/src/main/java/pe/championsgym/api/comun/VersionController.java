package pe.championsgym.api.comun;

import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

// GET /api/version: la usa el pipeline para saber que version quedo en linea.
@RestController
public class VersionController {

    private final String version;

    public VersionController(@Value("${app.version}") String version) {
        this.version = version;
    }

    @GetMapping("/version")
    public Map<String, String> version() {
        return Map.of("version", version);
    }
}