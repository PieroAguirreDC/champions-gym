package pe.championsgym.api.suscripciones;

import java.time.OffsetDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(schema = "suscripciones", name = "socio")
public class Socio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombre;
    private String email;
    private String dni;
    private String passwordHash;
    private OffsetDateTime creadoEn;

    protected Socio() {
    }

    public Socio(String nombre, String email, String dni, String passwordHash) {
        this.nombre = nombre;
        this.email = email;
        this.dni = dni;
        this.passwordHash = passwordHash;
        this.creadoEn = OffsetDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    public String getEmail() {
        return email;
    }

    public String getDni() {
        return dni;
    }

    public String getPasswordHash() {
        return passwordHash;
    }
}