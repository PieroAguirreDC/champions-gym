# Variables de entorno y secretos extra que recibe el contenedor de la API (los usa ecs.tf).
# Cada integrante edita SOLO su bloque; asi dos pull requests en paralelo no chocan.
# Secretos: NOMBRE = ARN de un parametro SecureString de SSM (nunca el valor).

# ---------- Fabrizio ----------
locals {
  app_env_fabrizio     = {}
  app_secrets_fabrizio = {}
}

# ---------- Piero ----------
locals {
  app_env_piero     = {}
  app_secrets_piero = {}
}

# ---------- Joaquin ----------
locals {
  app_env_joaquin     = {}
  app_secrets_joaquin = {}
}
