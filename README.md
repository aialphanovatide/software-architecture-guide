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

### Usando el Makefile

El proyecto incluye un Makefile para mayor comodidad:

```bash
# Mostrar todos los comandos disponibles
make help

# Desarrollo local
make setup    # Instalar dependencias
make run      # Ejecutar servidor de desarrollo local

# Operaciones de Docker
make start-docker    # Construir e iniciar en Docker
make docker-logs     # Ver logs
make docker-down     # Detener el contenedor Docker
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
   O usar: `make setup`

3. Iniciar el servidor de desarrollo:
   ```
   mkdocs serve
   ```
   O usar: `make run`

4. Ver la documentación en `http://localhost:8000`

### Usando Docker Compose

1. Iniciar el servicio:
   ```
   docker-compose up -d
   ```
   O usar: `make docker-up`

2. Ver la documentación en `http://localhost:8000`

3. Detener el servicio:
   ```
   docker-compose down
   ```
   O usar: `make docker-down`

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
O usar: `make build`

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
│   └── es/                  # Contenido en español
│       ├── index.md         # Página de inicio
│       ├── solid/           # Principios SOLID
│       ├── design-patterns/ # Patrones de diseño
│       ├── architecture/    # Estilos arquitectónicos
│       ├── ddd/             # Diseño Dirigido por el Dominio
│       ├── examples/        # Ejemplos de implementación
│       ├── best-practices/  # Mejores prácticas
│       └── team-adoption/   # Estrategias de adopción en equipo
├── mkdocs.yml               # Configuración de MkDocs
├── docker-compose.yml       # Configuración de Docker Compose
├── Makefile                 # Comandos de automatización
├── requirements.txt         # Dependencias de Python
└── dockerfile               # Configuración de Docker
```

## Licencia

[Tu Licencia] 