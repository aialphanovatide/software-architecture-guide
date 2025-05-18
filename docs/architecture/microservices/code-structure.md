# Estructura de Código para Microservicios

Una estructura de código bien organizada es fundamental para el éxito a largo plazo de un proyecto de microservicios. Esta sección presenta patrones de organización de código recomendados para microservicios, con ejemplos en Python (FastAPI/Flask) y TypeScript (Node.js).

## Principios Generales

Al estructurar el código de microservicios, es importante seguir estos principios:

1. **Coherencia**: Mantener un patrón consistente en todos los servicios
2. **Modularidad**: Organizar el código en módulos con responsabilidades claras
3. **Testabilidad**: Facilitar las pruebas automatizadas
4. **Desacoplamiento**: Minimizar dependencias entre componentes
5. **Autocontención**: Cada servicio debe ser independiente

## Estructura Recomendada para Microservicios

A continuación se presenta una estructura de directorios recomendada para cada microservicio:

```
servicio-usuarios/
├── src/                         # Código fuente principal
│   ├── api/                     # Definición de API y endpoints
│   │   ├── __init__.py
│   │   ├── routes/              # Endpoints de la API agrupados por recurso
│   │   │   ├── __init__.py
│   │   │   ├── usuarios.py
│   │   │   └── autenticacion.py
│   │   ├── middlewares/         # Middlewares de la API
│   │   │   ├── __init__.py
│   │   │   ├── authorization.py
│   │   │   └── logging.py
│   │   └── schemas/             # Esquemas de validación y serialización
│   │       ├── __init__.py
│   │       └── usuario.py
│   ├── core/                    # Núcleo de la aplicación
│   │   ├── __init__.py
│   │   ├── config.py            # Configuración de la aplicación
│   │   ├── exceptions.py        # Excepciones personalizadas
│   │   └── logging.py           # Configuración de logging
│   ├── domain/                  # Lógica de dominio
│   │   ├── __init__.py
│   │   ├── models/              # Entidades y objetos de valor
│   │   │   ├── __init__.py
│   │   │   └── usuario.py
│   │   └── services/            # Servicios de dominio
│   │       ├── __init__.py
│   │       └── usuario_service.py
│   ├── application/             # Casos de uso y servicios de aplicación
│   │   ├── __init__.py
│   │   ├── commands/            # Comandos (acciones que modifican el estado)
│   │   │   ├── __init__.py
│   │   │   ├── crear_usuario.py
│   │   │   └── actualizar_usuario.py
│   │   └── queries/             # Consultas (acciones que no modifican el estado)
│   │       ├── __init__.py
│   │       └── obtener_usuario.py
│   ├── infrastructure/          # Implementaciones de infraestructura
│   │   ├── __init__.py
│   │   ├── database/            # Configuración de la base de datos
│   │   │   ├── __init__.py
│   │   │   ├── models.py        # Modelos ORM
│   │   │   └── connection.py    # Configuración de la conexión
│   │   ├── repositories/        # Implementaciones de repositorios
│   │   │   ├── __init__.py
│   │   │   └── usuario_repository.py
│   │   ├── messaging/           # Integración con sistemas de mensajería
│   │   │   ├── __init__.py
│   │   │   ├── producer.py
│   │   │   └── consumer.py
│   │   └── clients/             # Clientes para servicios externos
│   │       ├── __init__.py
│   │       └── servicio_notificaciones.py
│   └── main.py                  # Punto de entrada de la aplicación
├── tests/                       # Tests automatizados
│   ├── __init__.py
│   ├── conftest.py              # Configuración de pruebas
│   ├── unit/                    # Pruebas unitarias
│   │   ├── __init__.py
│   │   ├── test_domain/
│   │   └── test_application/
│   ├── integration/             # Pruebas de integración
│   │   ├── __init__.py
│   │   └── test_repositories/
│   └── api/                     # Pruebas de API
│       ├── __init__.py
│       └── test_routes/
├── scripts/                     # Scripts de utilidad
│   ├── seed_db.py
│   └── run_migrations.py
├── Dockerfile                   # Definición del contenedor
├── docker-compose.yml           # Configuración para desarrollo local
├── requirements.txt             # Dependencias
├── pytest.ini                   # Configuración de pytest
├── .env.example                 # Ejemplo de variables de entorno
├── README.md                    # Documentación del servicio
└── setup.py                     # Configuración de empaquetado
```

## Implementación en Python (FastAPI)

### Punto de Entrada de la Aplicación

```python
# src/main.py
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.api.routes import usuarios, autenticacion
from src.core.config import settings
from src.infrastructure.database.connection import init_db

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Microservicio de gestión de usuarios",
    version="1.0.0",
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir rutas
app.include_router(usuarios.router, prefix="/api/v1", tags=["usuarios"])
app.include_router(autenticacion.router, prefix="/api/v1", tags=["autenticacion"])

@app.on_event("startup")
async def startup_event():
    await init_db()

@app.get("/health", tags=["health"])
async def health():
    return {"status": "ok"}

if __name__ == "__main__":
    uvicorn.run("src.main:app", host="0.0.0.0", port=8000, reload=True)
```

### Definición de Rutas

```python
# src/api/routes/usuarios.py
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List

from src.api.schemas.usuario import UsuarioCreate, UsuarioResponse, UsuarioUpdate
from src.application.commands.crear_usuario import crear_usuario
from src.application.commands.actualizar_usuario import actualizar_usuario
from src.application.queries.obtener_usuario import obtener_usuario, listar_usuarios
from src.core.exceptions import UsuarioNotFoundError

router = APIRouter()

@router.post("/usuarios", response_model=UsuarioResponse, status_code=status.HTTP_201_CREATED)
async def create_usuario(usuario_data: UsuarioCreate):
    try:
        usuario = await crear_usuario(usuario_data)
        return usuario
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

@router.get("/usuarios", response_model=List[UsuarioResponse])
async def get_usuarios():
    return await listar_usuarios()

@router.get("/usuarios/{usuario_id}", response_model=UsuarioResponse)
async def get_usuario(usuario_id: int):
    try:
        usuario = await obtener_usuario(usuario_id)
        return usuario
    except UsuarioNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Usuario con ID {usuario_id} no encontrado"
        )

@router.put("/usuarios/{usuario_id}", response_model=UsuarioResponse)
async def update_usuario(usuario_id: int, usuario_data: UsuarioUpdate):
    try:
        usuario = await actualizar_usuario(usuario_id, usuario_data)
        return usuario
    except UsuarioNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Usuario con ID {usuario_id} no encontrado"
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
```

### Esquemas de API

```python
# src/api/schemas/usuario.py
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class UsuarioBase(BaseModel):
    nombre: str = Field(..., min_length=2, max_length=100)
    email: EmailStr

class UsuarioCreate(UsuarioBase):
    password: str = Field(..., min_length=8)

class UsuarioUpdate(BaseModel):
    nombre: Optional[str] = Field(None, min_length=2, max_length=100)
    email: Optional[EmailStr] = None
    activo: Optional[bool] = None

class UsuarioResponse(UsuarioBase):
    id: int
    activo: bool
    fecha_registro: datetime

    class Config:
        orm_mode = True
```

### Modelo de Dominio

```python
# src/domain/models/usuario.py
from datetime import datetime
from typing import Optional

class Usuario:
    def __init__(
        self,
        nombre: str,
        email: str,
        password_hash: str,
        id: Optional[int] = None,
        activo: bool = True,
        fecha_registro: Optional[datetime] = None
    ):
        self.id = id
        self.nombre = nombre
        self.email = email
        self.password_hash = password_hash
        self.activo = activo
        self.fecha_registro = fecha_registro or datetime.now()

    def activar(self):
        self.activo = True

    def desactivar(self):
        self.activo = False

    def actualizar_informacion(self, nombre=None, email=None):
        if nombre:
            self.nombre = nombre
        if email:
            self.email = email
```

### Implementación del Repositorio

```python
# src/infrastructure/repositories/usuario_repository.py
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from src.domain.models.usuario import Usuario
from src.infrastructure.database.models import UsuarioModel
from src.infrastructure.database.connection import get_session

class UsuarioRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, usuario_id: int) -> Optional[Usuario]:
        result = await self.session.execute(
            select(UsuarioModel).where(UsuarioModel.id == usuario_id)
        )
        usuario_model = result.scalar_one_or_none()
        if not usuario_model:
            return None

        return self._map_to_domain(usuario_model)

    async def get_by_email(self, email: str) -> Optional[Usuario]:
        result = await self.session.execute(
            select(UsuarioModel).where(UsuarioModel.email == email)
        )
        usuario_model = result.scalar_one_or_none()
        if not usuario_model:
            return None

        return self._map_to_domain(usuario_model)

    async def list_all(self) -> List[Usuario]:
        result = await self.session.execute(select(UsuarioModel))
        usuario_models = result.scalars().all()
        return [self._map_to_domain(usuario) for usuario in usuario_models]

    async def create(self, usuario: Usuario) -> Usuario:
        usuario_model = UsuarioModel(
            nombre=usuario.nombre,
            email=usuario.email,
            password_hash=usuario.password_hash,
            activo=usuario.activo,
            fecha_registro=usuario.fecha_registro
        )
        self.session.add(usuario_model)
        await self.session.commit()
        await self.session.refresh(usuario_model)
        return self._map_to_domain(usuario_model)

    async def update(self, usuario: Usuario) -> Usuario:
        result = await self.session.execute(
            select(UsuarioModel).where(UsuarioModel.id == usuario.id)
        )
        usuario_model = result.scalar_one()
        
        usuario_model.nombre = usuario.nombre
        usuario_model.email = usuario.email
        usuario_model.activo = usuario.activo
        
        await self.session.commit()
        await self.session.refresh(usuario_model)
        return self._map_to_domain(usuario_model)

    def _map_to_domain(self, usuario_model: UsuarioModel) -> Usuario:
        return Usuario(
            id=usuario_model.id,
            nombre=usuario_model.nombre,
            email=usuario_model.email,
            password_hash=usuario_model.password_hash,
            activo=usuario_model.activo,
            fecha_registro=usuario_model.fecha_registro
        )
```

## Implementación en TypeScript (Node.js)

La misma estructura puede adaptarse para TypeScript con Node.js:

```typescript
// src/domain/models/User.ts
export class User {
  constructor(
    public readonly id: number | null,
    public name: string,
    public email: string,
    public passwordHash: string,
    public active: boolean = true,
    public readonly registrationDate: Date = new Date()
  ) {}

  activate(): void {
    this.active = true;
  }

  deactivate(): void {
    this.active = false;
  }

  updateInfo(name?: string, email?: string): void {
    if (name) {
      this.name = name;
    }
    if (email) {
      this.email = email;
    }
  }
}
```

```typescript
// src/infrastructure/repositories/UserRepository.ts
import { PrismaClient } from '@prisma/client';
import { User } from '../../domain/models/User';
import { IUserRepository } from '../../domain/repositories/IUserRepository';

export class UserRepository implements IUserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: number): Promise<User | null> {
    const userModel = await this.prisma.user.findUnique({
      where: { id }
    });

    if (!userModel) {
      return null;
    }

    return this.mapToDomain(userModel);
  }

  async findByEmail(email: string): Promise<User | null> {
    const userModel = await this.prisma.user.findUnique({
      where: { email }
    });

    if (!userModel) {
      return null;
    }

    return this.mapToDomain(userModel);
  }

  async findAll(): Promise<User[]> {
    const userModels = await this.prisma.user.findMany();
    return userModels.map(this.mapToDomain);
  }

  async create(user: User): Promise<User> {
    const userModel = await this.prisma.user.create({
      data: {
        name: user.name,
        email: user.email,
        passwordHash: user.passwordHash,
        active: user.active,
        registrationDate: user.registrationDate
      }
    });

    return this.mapToDomain(userModel);
  }

  async update(user: User): Promise<User> {
    if (!user.id) {
      throw new Error('Cannot update user without ID');
    }

    const userModel = await this.prisma.user.update({
      where: { id: user.id },
      data: {
        name: user.name,
        email: user.email,
        active: user.active
      }
    });

    return this.mapToDomain(userModel);
  }

  private mapToDomain(userModel: any): User {
    return new User(
      userModel.id,
      userModel.name,
      userModel.email,
      userModel.passwordHash,
      userModel.active,
      userModel.registrationDate
    );
  }
}
```

## Consideraciones para la Estructura de Código

### 1. Separación por Capacidades de Negocio

Los microservicios deben estar organizados en torno a capacidades de negocio, no tecnologías. Cada servicio debe representar un dominio de negocio específico.

### 2. Interfaz vs. Implementación

Utiliza interfaces para definir contratos, especialmente para repositorios y servicios. Esto permite intercambiar implementaciones fácilmente.

```python
# src/domain/repositories/usuario_repository.py
from abc import ABC, abstractmethod
from typing import List, Optional
from src.domain.models.usuario import Usuario

class IUsuarioRepository(ABC):
    @abstractmethod
    async def get_by_id(self, usuario_id: int) -> Optional[Usuario]:
        pass

    @abstractmethod
    async def get_by_email(self, email: str) -> Optional[Usuario]:
        pass

    @abstractmethod
    async def list_all(self) -> List[Usuario]:
        pass

    @abstractmethod
    async def create(self, usuario: Usuario) -> Usuario:
        pass

    @abstractmethod
    async def update(self, usuario: Usuario) -> Usuario:
        pass
```

### 3. Gestión de Configuración

Separa la configuración del código utilizando variables de entorno y archivos de configuración.

```python
# src/core/config.py
from pydantic import BaseSettings, PostgresDsn, validator
from typing import List, Optional
import os

class Settings(BaseSettings):
    PROJECT_NAME: str = "Servicio de Usuarios"
    API_PREFIX: str = "/api/v1"
    
    POSTGRES_HOST: str
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str
    POSTGRES_DB: str
    POSTGRES_PORT: str = "5432"
    DATABASE_URI: Optional[PostgresDsn] = None

    @validator("DATABASE_URI", pre=True)
    def assemble_db_connection(cls, v: Optional[str], values: dict) -> str:
        if v:
            return v
        return PostgresDsn.build(
            scheme="postgresql+asyncpg",
            user=values.get("POSTGRES_USER"),
            password=values.get("POSTGRES_PASSWORD"),
            host=values.get("POSTGRES_HOST"),
            port=values.get("POSTGRES_PORT"),
            path=f"/{values.get('POSTGRES_DB') or ''}",
        )
    
    CORS_ORIGINS: List[str] = ["http://localhost:3000"]
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
```

### 4. Gestión de Errores

Define una estrategia clara para la gestión de errores, utilizando excepciones personalizadas para errores de dominio.

```python
# src/core/exceptions.py
class AppException(Exception):
    """Base exception for all application exceptions"""
    pass

class UsuarioNotFoundError(AppException):
    """Raised when a usuario is not found"""
    pass

class EmailAlreadyExistsError(AppException):
    """Raised when trying to create a usuario with an existing email"""
    pass

class AuthenticationError(AppException):
    """Raised for authentication errors"""
    pass
```

## Comunicación entre Microservicios

### 1. Clientes HTTP

```python
# src/infrastructure/clients/servicio_notificaciones.py
import httpx
from typing import Dict, Any

from src.core.config import settings

class ServicioNotificacionesClient:
    def __init__(self):
        self.base_url = settings.NOTIFICACIONES_SERVICE_URL
        self.timeout = 10.0

    async def enviar_email(self, destinatario: str, asunto: str, contenido: str) -> Dict[Any, Any]:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/api/v1/emails",
                json={
                    "destinatario": destinatario,
                    "asunto": asunto,
                    "contenido": contenido
                },
                timeout=self.timeout
            )
            response.raise_for_status()
            return response.json()
```

### 2. Integración con Mensajería

```python
# src/infrastructure/messaging/producer.py
import json
from typing import Any, Dict
import aio_pika

from src.core.config import settings

class EventProducer:
    def __init__(self):
        self.connection = None
        self.channel = None
        self.exchange = None

    async def connect(self):
        self.connection = await aio_pika.connect_robust(settings.RABBITMQ_URL)
        self.channel = await self.connection.channel()
        self.exchange = await self.channel.declare_exchange(
            "usuarios", aio_pika.ExchangeType.TOPIC
        )

    async def publish_event(self, routing_key: str, event_data: Dict[str, Any]):
        if not self.connection or self.connection.is_closed:
            await self.connect()

        message = aio_pika.Message(
            body=json.dumps(event_data).encode(),
            content_type="application/json"
        )
        
        await self.exchange.publish(
            message=message,
            routing_key=routing_key
        )

    async def close(self):
        if self.connection and not self.connection.is_closed:
            await self.connection.close()
```

## Contenerización

### Dockerfile

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código fuente
COPY . .

# Variables de entorno predeterminadas (serán sobreescritas en producción)
ENV PYTHONPATH=/app
ENV PORT=8000

# Exponer puerto
EXPOSE $PORT

# Comando para iniciar la aplicación
CMD ["python", "-m", "src.main"]
```

### Docker Compose para Desarrollo

```yaml
version: '3.8'

services:
  servicio-usuarios:
    build: .
    ports:
      - "8001:8000"
    volumes:
      - .:/app
    environment:
      - POSTGRES_HOST=postgres
      - POSTGRES_USER=app
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=usuarios_db
      - RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672//
    depends_on:
      - postgres
      - rabbitmq

  postgres:
    image: postgres:14
    environment:
      - POSTGRES_USER=app
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=usuarios_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "5672:5672"
      - "15672:15672"

volumes:
  postgres_data:
```

## Conclusión

Una estructura de código bien organizada es esencial para el éxito de un proyecto de microservicios. La estructura presentada en esta sección proporciona un equilibrio entre la simplicidad y la separación de responsabilidades, facilitando el mantenimiento a largo plazo y la escalabilidad del sistema.

Al seguir estos patrones, los equipos pueden mantener la coherencia en todos los servicios, lo que facilita el cambio de contexto entre diferentes partes del sistema y mejora la productividad general del equipo. 