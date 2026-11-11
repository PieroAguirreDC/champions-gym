package pe.championsgym.api.suscripciones;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegistroSocio(
        @NotBlank(message = "es obligatorio") @Size(max = 120, message = "maximo 120 caracteres") String nombre,
        @NotBlank(message = "es obligatorio") @Email(message = "no es un email valido") @Size(max = 160) String email,
        @NotBlank(message = "es obligatorio") @Pattern(regexp = "\\d{8}", message = "debe tener 8 digitos") String dni,
        @NotBlank(message = "es obligatoria") @Size(min = 8, max = 72, message = "debe tener entre 8 y 72 caracteres") String password) {
}