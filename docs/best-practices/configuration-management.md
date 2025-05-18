# Gestión de Configuración

La gestión adecuada de la configuración es un aspecto crítico del desarrollo de software moderno, especialmente en entornos distribuidos como microservicios. Esta sección presenta las mejores prácticas para administrar la configuración de aplicaciones de manera efectiva y segura.

## Principios Fundamentales

### 1. Separación de Configuración y Código

El código y la configuración deben mantenerse separados por varias razones:

- La configuración cambia entre entornos, pero el código no
- Los secretos no deben almacenarse en el código fuente
- La configuración puede necesitar cambios sin necesidad de recompilar/redesplegar

### 2. Configuración por Entorno

Diferentes entornos (desarrollo, pruebas, producción) requieren diferentes configuraciones:

- Parámetros de conexión a bases de datos
- URLs de servicios externos
- Niveles de logging
- Características habilitadas/deshabilitadas

### 3. Seguridad de Secretos

Los secretos (contraseñas, tokens, claves API) requieren tratamiento especial:

- Nunca deben estar en el control de versiones
- Deben estar cifrados cuando sea posible
- El acceso debe estar limitado según el principio de privilegio mínimo

## Enfoques para la Gestión de Configuración

### 1. Variables de Entorno

Las variables de entorno son versátiles y compatibles con la mayoría de plataformas:

**Ventajas:**
- Soporte nativo en todos los sistemas operativos
- Fácil integración con contenedores y orquestadores
- Independencia del lenguaje de programación

**Implementación en Python:**

```python
import os

# Obtener variables de entorno con valores predeterminados
DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///default.db")
DEBUG = os.environ.get("DEBUG", "False").lower() == "true"
API_KEY = os.environ["API_KEY"]  # Falla si no está definida
```

**Implementación en TypeScript:**

```typescript
// Obtener variables de entorno con valores predeterminados
const databaseUrl = process.env.DATABASE_URL || 'sqlite:///default.db';
const debug = process.env.DEBUG?.toLowerCase() === 'true';
const apiKey = process.env.API_KEY;

if (!apiKey) {
  throw new Error('API_KEY environment variable is required');
}
```

### 2. Archivos de Configuración

Los archivos de configuración son útiles para configuraciones más complejas:

**Ventajas:**
- Soporte para estructuras jerárquicas
- Más legible para configuraciones extensas
- Facilidad para versionado (excluyendo secretos)

**Formatos comunes:**
- JSON: Amplio soporte, pero sin comentarios
- YAML: Más legible y con soporte para comentarios
- TOML: Balanceo entre legibilidad y expresividad

**Ejemplo en YAML:**

```yaml
# config.yaml
database:
  host: localhost
  port: 5432
  username: app_user
  # La contraseña debe estar en variables de entorno

logging:
  level: info
  format: json
  output: stdout
```

**Carga en Python:**

```python
import os
import yaml

def load_config(config_path="config.yaml"):
    with open(config_path, "r") as f:
        config = yaml.safe_load(f)
    
    # Sobrescribir con variables de entorno si existen
    if "DATABASE_PASSWORD" in os.environ:
        config["database"]["password"] = os.environ["DATABASE_PASSWORD"]
    
    return config

config = load_config()
```

### 3. Servicios de Configuración Centralizada

Para sistemas distribuidos, los servicios de configuración centralizada ofrecen ventajas adicionales:

**Opciones populares:**
- Consul
- etcd
- Spring Cloud Config
- AWS Parameter Store/Secrets Manager
- HashiCorp Vault (especialmente para secretos)

**Ventajas:**
- Configuración dinámica sin reinicios
- Control centralizado
- Versionado de configuración
- Seguridad mejorada para secretos

**Ejemplo con Consul en Python:**

```python
import consul
import os

# Conectar a Consul
c = consul.Consul(host=os.environ.get("CONSUL_HOST", "localhost"))

# Obtener configuración
index, data = c.kv.get("myapp/database/url")
database_url = data["Value"].decode("utf-8") if data else "default_url"

# Observar cambios
def watch_config():
    index, data = c.kv.get("myapp/features", index=index)
    # Actualizar configuración en tiempo real
```

## Patrones de Implementación

### 1. Patrón de Objeto de Configuración

Centraliza el acceso a la configuración a través de un objeto dedicado:

```python
from pydantic import BaseSettings, Field

class Settings(BaseSettings):
    """Configuración de la aplicación usando Pydantic."""
    
    # Configuración de base de datos
    db_host: str = "localhost"
    db_port: int = 5432
    db_user: str = "app_user"
    db_password: str = Field(..., env="DB_PASSWORD")
    
    # Configuración de API
    api_key: str = Field(..., env="API_KEY")
    api_timeout: int = 30
    
    # Características
    enable_feature_x: bool = False
    
    class Config:
        env_file = ".env"
        env_file_encoding = 'utf-8'

# Crear una instancia global
settings = Settings()
```

### 2. Configuración por Perfil

Carga diferentes configuraciones según el entorno:

```python
import os
import yaml

def load_config():
    env = os.environ.get("APP_ENV", "development")
    config_path = f"config.{env}.yaml"
    
    with open(config_path, "r") as f:
        return yaml.safe_load(f)
```

### 3. Configuración con Validación

Valida la configuración al inicio para detectar problemas temprano:

```python
from pydantic import BaseSettings, validator, PostgresDsn

class Settings(BaseSettings):
    DATABASE_URL: PostgresDsn
    API_KEY: str
    MAX_CONNECTIONS: int = 100
    
    @validator("MAX_CONNECTIONS")
    def check_max_connections(cls, v):
        if v < 1 or v > 1000:
            raise ValueError("MAX_CONNECTIONS debe estar entre 1 y 1000")
        return v
```

## Gestión de Secretos

### 1. Almacenamiento Seguro

Opciones para almacenar secretos de forma segura:

- **HashiCorp Vault**: Sistema completo para la gestión de secretos
- **AWS Secrets Manager/Parameter Store**: Servicios gestionados en la nube
- **Kubernetes Secrets**: Para aplicaciones que se ejecutan en Kubernetes
- **Docker Secrets**: Para aplicaciones que se ejecutan en Swarm

### 2. Rotación de Secretos

Implementa la rotación periódica de secretos:

- Automatiza la generación y distribución de nuevos secretos
- Asegura que las aplicaciones puedan actualizarse sin tiempo de inactividad
- Mantén períodos de gracia donde tanto los secretos antiguos como los nuevos son válidos

### 3. Acceso a los Secretos

Implementa el acceso a secretos de manera segura:

```python
# Usando Vault en Python
import hvac

client = hvac.Client(url='https://vault.example.com:8200', token=os.environ.get('VAULT_TOKEN'))

# Leer un secreto
secret = client.secrets.kv.v2.read_secret_version(
    mount_point='secret', 
    path='myapp/database'
)

db_password = secret['data']['data']['password']
```

## Docker y Contenedores

### Variables de Entorno en Docker

```dockerfile
# Dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# Variables de entorno predeterminadas
ENV LOG_LEVEL=info \
    PORT=8000

# Comando que puede usar las variables
CMD ["python", "app.py"]
```

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/app
      - REDIS_URL=redis://redis:6379/0
    env_file:
      - .env.local
```

### Kubernetes Secrets y ConfigMaps

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_HOST: "postgres.default.svc.cluster.local"
  LOG_LEVEL: "info"

# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  DATABASE_PASSWORD: cGFzc3dvcmQ=  # base64 encoded
  API_KEY: c2VjcmV0X2tleQ==        # base64 encoded
```

## Mejores Prácticas para Entornos de Desarrollo

### 1. Archivos .env

Usa archivos `.env` para desarrollo local:

```
# .env
DATABASE_URL=postgresql://user:password@localhost:5432/app_dev
API_KEY=dev_key_only
DEBUG=true
```

**Importante**: Nunca incluyas el archivo `.env` real en el control de versiones. En su lugar, proporciona un `.env.example`:

```
# .env.example
DATABASE_URL=postgresql://user:password@localhost:5432/app
API_KEY=your_api_key_here
DEBUG=false
```

### 2. Configuración para Pruebas

Configura entornos de prueba de manera consistente:

```python
# conftest.py para pytest
import os
import pytest

@pytest.fixture(autouse=True)
def setup_test_env():
    # Configurar variables de entorno para pruebas
    os.environ["DATABASE_URL"] = "sqlite:///:memory:"
    os.environ["API_KEY"] = "test_key"
    os.environ["ENVIRONMENT"] = "test"
    
    yield
    
    # Limpiar después de las pruebas
    os.environ.pop("DATABASE_URL", None)
    os.environ.pop("API_KEY", None)
    os.environ.pop("ENVIRONMENT", None)
```

## Conclusión

Una estrategia de gestión de configuración efectiva debe equilibrar las necesidades de:

- **Seguridad**: Proteger información sensible
- **Flexibilidad**: Adaptarse a diferentes entornos
- **Usabilidad**: Facilitar el trabajo de los desarrolladores
- **Escalabilidad**: Funcionar bien en sistemas distribuidos

Siguiendo estas mejores prácticas, puedes crear un sistema de configuración que sea seguro, flexible y fácil de mantener, incluso a medida que tu aplicación crece en complejidad. 