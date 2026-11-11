package pe.championsgym.api.comun;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

// Sesion del socio. Spring Session la guarda en PostgreSQL (tabla SPRING_SESSION),
// asi el socio sigue logueado aunque API Gateway mande su peticion a otra tarea Fargate.
public final class SesionSocio {

    public static final String ATRIBUTO = "socioId";

    private SesionSocio() {
    }

    public static void iniciar(HttpServletRequest request, Long socioId) {
        request.getSession(true);
        request.changeSessionId(); // id nuevo en cada login
        request.getSession().setAttribute(ATRIBUTO, socioId);
    }

    // Id del socio logueado, o 401 si no hay sesion.
    public static Long socioActual(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object id = session == null ? null : session.getAttribute(ATRIBUTO);
        if (id == null) {
            throw ErrorDeNegocio.noAutenticado();
        }
        return (Long) id;
    }

    public static void cerrar(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }
}