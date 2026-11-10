## Qué cambia
<!-- Una o dos líneas. Ejemplo: Integración del RDS Standby Multi-AZ -->

## Paso de la guía
<!-- Ejemplo: J1.1 (fase 1) -->

## RNF que cubre
<!-- Ejemplo: RNF 13 y 15. Escribe "ninguno" si es solo base. -->

## Cómo lo probé
- [ ] `./mvnw verify` dentro de `app/` (si toca la API)
- [ ] `terraform fmt -check -recursive` y `terraform validate` (si toca `infra/`)
- [ ] `docker compose up --build` y probé en http://localhost:8081 (si toca la API o la web)

## Checklist
- [ ] Solo cambié mis archivos (o mi bloque en los archivos compartidos)
- [ ] Sin claves, contraseñas ni tokens en el código
- [ ] Avisé en el grupo que abrí este PR
