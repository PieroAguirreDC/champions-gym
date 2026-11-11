-- Modulo suscripciones: planes y socios (cada modulo tiene su propio esquema).
CREATE SCHEMA IF NOT EXISTS suscripciones;

CREATE TABLE suscripciones.plan (
    id          BIGSERIAL     PRIMARY KEY,
    nombre      VARCHAR(60)   NOT NULL UNIQUE,
    precio      NUMERIC(8, 2) NOT NULL CHECK (precio > 0),
    meses       INTEGER       NOT NULL CHECK (meses > 0),
    descripcion VARCHAR(255)  NOT NULL
);

CREATE TABLE suscripciones.socio (
    id            BIGSERIAL    PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    email         VARCHAR(160) NOT NULL UNIQUE,
    dni           VARCHAR(8)   NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    creado_en     TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- Precios de ejemplo en soles; el gimnasio los ajusta despues.
INSERT INTO suscripciones.plan (nombre, precio, meses, descripcion) VALUES
    ('Mensual',    120.00,  1, 'Sala de maquinas y clases grupales por 1 mes'),
    ('Trimestral', 330.00,  3, 'Sala de maquinas y clases grupales por 3 meses'),
    ('Anual',     1200.00, 12, 'Sala de maquinas, clases grupales y evaluacion fisica por 12 meses');