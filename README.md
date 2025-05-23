# Guía de Arquitectura de Software

Este repositorio contiene una guía completa sobre principios, patrones y mejores prácticas de arquitectura de software. La documentación está construida usando MkDocs con el tema Material.

## Áreas de Enfoque

La guía se centra en:

1. Diseño Dirigido por el Dominio (DDD)
2. Arquitectura de Microservicios
3. Principios SOLID
4. Patrones de Diseño
5. Ejemplos de Implementación en Python y TypeScript

## Comenzando

### Requisitos Previos

- Python 3.8+
- Docker y Docker Compose (opcional)
- Make (opcional, para usar el Makefile)
- Token de Ngrok (opcional, para exponer el servicio a internet)

### Usando el Makefile

El proyecto incluye un Makefile para mayor comodidad:

```bash
# Mostrar todos los comandos disponibles
make help

# Operaciones de Docker
make build         # Construir la imagen Docker
make up            # Iniciar los servicios (docs y ngrok)
make down          # Detener los servicios
make logs          # Ver logs de los servicios
make start         # Construir e iniciar en Docker (combinado)
make restart       # Reiniciar los servicios
```

### Desarrollo Local

1. Clonar este repositorio:
   ```
   git clone <repository-url>
   cd software-architecture-guide
   ```

2. Instalar dependencias:
   ```
   pip install -r requirements.txt
   ```

3. Iniciar el servidor de desarrollo:
   ```
   mkdocs serve
   ```

4. Ver la documentación en `http://localhost:8000`

### Usando Docker Compose

1. Si deseas utilizar ngrok para exponer el servicio, configura tu token de autenticación:
   ```
   export NGROK_AUTHTOKEN=tu_token_de_ngrok
   ```

2. Iniciar los servicios:
   ```
   docker-compose up -d
   ```
   O usar: `make up`

3. Ver la documentación en `http://localhost:8000`

4. Si estás utilizando ngrok, puedes acceder a la interfaz web en `http://localhost:4040` para obtener la URL pública

5. Detener los servicios:
   ```
   docker-compose down
   ```
   O usar: `make down`

### Usando Docker (Método Legado)

1. Construir la imagen Docker:
   ```
   docker build -t software-architecture-guide .
   ```

2. Ejecutar el contenedor:
   ```
   docker run -p 8000:8000 software-architecture-guide
   ```

3. Ver la documentación en `http://localhost:8000`

## Construyendo la Documentación

Para construir archivos HTML estáticos:

```
mkdocs build
```

El sitio construido estará en el directorio `site`.

## Contribuir

Agradecemos las contribuciones a esta guía. Para contribuir:

1. Haz un fork del repositorio
2. Crea una rama de características
3. Haz tus cambios
4. Envía un pull request

## Estructura del Proyecto

```
software-architecture-guide/
├── docs/                    # Contenido de la documentación
│   ├── index.md             # Página de inicio
│   ├── glossary.md          # Glosario de términos
│   ├── architecture/        # Estilos arquitectónicos
│   │   ├── microservices/   # Microservicios
│   │   │   ├── resilience-patterns/ # Patrones de resiliencia
│   │   │   ├── principles.md
│   │   │   ├── deployment.md
│   │   │   ├── communication.md
│   │   │   ├── code-structure.md
│   │   │   └── example-implementation.md
│   ├── ddd/                 # Diseño Dirigido por el Dominio
│   ├── design-patterns/     # Patrones de diseño
│   ├── solid/               # Principios SOLID
│   ├── best-practices/      # Mejores prácticas
│   └── team-adoption/       # Estrategias de adopción en equipo
├── mkdocs.yml               # Configuración de MkDocs
├── docker-compose.yml       # Configuración de Docker Compose (incluye servicios docs y ngrok)
├── Makefile                 # Comandos de automatización
├── requirements.txt         # Dependencias de Python
└── dockerfile               # Configuración de Docker
```

