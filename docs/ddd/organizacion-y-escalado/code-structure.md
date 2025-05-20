# Estructura de Código para DDD

Una organización de código efectiva es crucial para implementar correctamente el Diseño Dirigido por el Dominio (DDD). Esta sección presenta una estructura recomendada para proyectos basados en DDD.

## Principios Fundamentales

Al estructurar código con DDD, es importante seguir estos principios:

1. **Aislamiento del dominio**: El modelo de dominio debe estar protegido de preocupaciones externas
2. **Capas claramente definidas**: Separación entre dominio, aplicación e infraestructura
3. **Lenguaje ubicuo**: Reflejar el lenguaje del dominio en el código
4. **Integridad del modelo**: Mantener consistencia y reglas de negocio en las entidades y agregados

## Estructura de Directorios Recomendada

```
proyecto/
├── src/
│   ├── domain/                      # El corazón de la aplicación
│   │   ├── model/                   # Entidades y objetos de valor
│   │   │   ├── usuario.py
│   │   │   ├── pedido.py
│   │   │   └── producto.py
│   │   ├── repository/              # Interfaces de repositorios
│   │   │   ├── usuario_repository.py
│   │   │   └── pedido_repository.py
│   │   ├── service/                 # Servicios de dominio
│   │   │   └── precio_service.py
│   │   ├── event/                   # Eventos de dominio
│   │   │   ├── usuario_events.py
│   │   │   └── pedido_events.py
│   │   └── exception/               # Excepciones de dominio
│   │       └── domain_exceptions.py
│   │
│   ├── application/                 # Orquestación de casos de uso
│   │   ├── command/                 # Comandos y sus manejadores
│   │   │   ├── crear_usuario.py
│   │   │   └── procesar_pedido.py
│   │   ├── query/                   # Consultas y sus manejadores
│   │   │   ├── buscar_usuarios.py
│   │   │   └── obtener_pedido.py
│   │   ├── dto/                     # Objetos de transferencia de datos
│   │   │   ├── usuario_dto.py
│   │   │   └── pedido_dto.py
│   │   └── service/                 # Servicios de aplicación
│   │       ├── usuario_service.py
│   │       └── pedido_service.py
│   │
│   ├── infrastructure/              # Implementaciones técnicas
│   │   ├── persistence/             # Persistencia de datos
│   │   │   ├── orm/                 # Modelos ORM
│   │   │   │   ├── usuario_model.py
│   │   │   │   └── pedido_model.py
│   │   │   └── repository/          # Implementaciones de repositorios
│   │   │       ├── usuario_repository_impl.py
│   │   │       └── pedido_repository_impl.py
│   │   ├── messaging/               # Mensajería y eventos
│   │   │   ├── event_bus.py
│   │   │   └── event_handlers.py
│   │   ├── api/                     # API REST o GraphQL
│   │   │   ├── controllers/
│   │   │   ├── middlewares/
│   │   │   └── schemas/
│   │   └── config/                  # Configuración
│   │       └── settings.py
│   │
│   └── interface/                   # Interfaces de usuario
│       ├── web/                     # Interfaz web (si aplica)
│       ├── cli/                     # Interfaz de línea de comandos
│       └── api/                     # APIs públicas
│
└── tests/                           # Pruebas
    ├── unit/                        # Pruebas unitarias
    ├── integration/                 # Pruebas de integración
    └── e2e/                         # Pruebas de extremo a extremo
```

## Implementación del Modelo de Dominio

### Entidades y Objetos de Valor

```python
# src/domain/model/usuario.py
from dataclasses import dataclass
from typing import Optional, List
from datetime import datetime
from uuid import UUID, uuid4

@dataclass(frozen=True)
class Email:
    """Objeto de valor para email con validación."""
    direccion: str
    
    def __post_init__(self):
        if "@" not in self.direccion:
            raise ValueError(f"Email inválido: {self.direccion}")

@dataclass(frozen=True)
class Direccion:
    """Objeto de valor para dirección postal."""
    calle: str
    ciudad: str
    codigo_postal: str
    pais: str

class Usuario:
    """Entidad Usuario con identidad clara y comportamiento asociado."""
    def __init__(
        self, 
        nombre: str, 
        email: Email, 
        direccion: Optional[Direccion] = None,
        id: Optional[UUID] = None
    ):
        self.id = id or uuid4()
        self.nombre = nombre
        self.email = email
        self.direccion = direccion
        self.fecha_registro = datetime.now()
        self.activo = True
        self._eventos = []
    
    def cambiar_email(self, nuevo_email: Email) -> None:
        """Cambia el email y registra el evento."""
        if nuevo_email.direccion == self.email.direccion:
            return
            
        email_anterior = self.email
        self.email = nuevo_email
        
        # Registrar un evento de dominio
        from src.domain.event.usuario_events import EmailCambiado
        self._eventos.append(
            EmailCambiado(
                usuario_id=self.id,
                email_anterior=email_anterior.direccion,
                nuevo_email=nuevo_email.direccion
            )
        )
    
    def cambiar_direccion(self, nueva_direccion: Direccion) -> None:
        """Actualiza la dirección del usuario."""
        self.direccion = nueva_direccion
    
    def desactivar(self) -> None:
        """Desactiva el usuario."""
        if not self.activo:
            return
            
        self.activo = False
        
        # Registrar evento
        from src.domain.event.usuario_events import UsuarioDesactivado
        self._eventos.append(UsuarioDesactivado(usuario_id=self.id))
    
    def obtener_eventos(self) -> List:
        """Retorna los eventos pendientes y limpia la lista."""
        eventos = self._eventos.copy()
        self._eventos.clear()
        return eventos
```

### Agregados y Reglas de Negocio

```python
# src/domain/model/pedido.py
from dataclasses import dataclass
from datetime import datetime
from typing import List, Optional
from uuid import UUID, uuid4

@dataclass(frozen=True)
class ProductoId:
    """Identificador de producto."""
    valor: UUID

@dataclass
class LineaPedido:
    """Objeto de valor que representa un ítem en un pedido."""
    producto_id: ProductoId
    cantidad: int
    precio_unitario: float
    
    @property
    def subtotal(self) -> float:
        return self.cantidad * self.precio_unitario

class Pedido:
    """Agregado raíz que encapsula las reglas de negocio para pedidos."""
    def __init__(
        self, 
        cliente_id: UUID,
        id: Optional[UUID] = None
    ):
        self.id = id or uuid4()
        self.cliente_id = cliente_id
        self.lineas: List[LineaPedido] = []
        self.fecha_creacion = datetime.now()
        self.estado = "borrador"
        self._eventos = []
    
    def agregar_producto(
        self, 
        producto_id: UUID, 
        cantidad: int, 
        precio_unitario: float
    ) -> None:
        """Agrega un producto al pedido."""
        if self.estado != "borrador":
            raise ValueError("No se pueden agregar productos a un pedido confirmado")
            
        if cantidad <= 0:
            raise ValueError("La cantidad debe ser mayor que cero")
            
        # Buscar si el producto ya está en el pedido
        for linea in self.lineas:
            if linea.producto_id.valor == producto_id:
                linea.cantidad += cantidad
                return
                
        # Agregar una nueva línea
        producto_id_obj = ProductoId(producto_id)
        self.lineas.append(
            LineaPedido(
                producto_id=producto_id_obj,
                cantidad=cantidad,
                precio_unitario=precio_unitario
            )
        )
    
    def eliminar_producto(self, producto_id: UUID) -> None:
        """Elimina un producto del pedido."""
        if self.estado != "borrador":
            raise ValueError("No se pueden eliminar productos de un pedido confirmado")
            
        self.lineas = [
            linea for linea in self.lineas 
            if linea.producto_id.valor != producto_id
        ]
    
    def confirmar(self) -> None:
        """Confirma el pedido si cumple las reglas de negocio."""
        if not self.lineas:
            raise ValueError("No se puede confirmar un pedido sin productos")
            
        if self.estado != "borrador":
            raise ValueError("El pedido ya ha sido confirmado")
            
        self.estado = "confirmado"
        
        # Registrar evento de dominio
        from src.domain.event.pedido_events import PedidoConfirmado
        self._eventos.append(
            PedidoConfirmado(
                pedido_id=self.id,
                cliente_id=self.cliente_id,
                total=self.total
            )
        )
    
    @property
    def total(self) -> float:
        """Calcula el total del pedido."""
        return sum(linea.subtotal for linea in self.lineas)
    
    def obtener_eventos(self) -> List:
        """Retorna los eventos pendientes y limpia la lista."""
        eventos = self._eventos.copy()
        self._eventos.clear()
        return eventos
```

## Interfaces de Repositorio

```python
# src/domain/repository/usuario_repository.py
from abc import ABC, abstractmethod
from typing import Optional, List
from uuid import UUID

from src.domain.model.usuario import Usuario, Email

class IUsuarioRepository(ABC):
    """Repositorio para acceso a la entidad Usuario."""
    
    @abstractmethod
    async def obtener_por_id(self, id: UUID) -> Optional[Usuario]:
        """Obtiene un usuario por su ID."""
        pass
    
    @abstractmethod
    async def obtener_por_email(self, email: Email) -> Optional[Usuario]:
        """Obtiene un usuario por su dirección de email."""
        pass
    
    @abstractmethod
    async def guardar(self, usuario: Usuario) -> Usuario:
        """Guarda un usuario (crea o actualiza)."""
        pass
    
    @abstractmethod
    async def eliminar(self, id: UUID) -> None:
        """Elimina un usuario por su ID."""
        pass
    
    @abstractmethod
    async def listar(self, limit: int = 100, offset: int = 0) -> List[Usuario]:
        """Lista usuarios con paginación."""
        pass
```

## Implementación de Repositorio

```python
# src/infrastructure/persistence/repository/usuario_repository_impl.py
from typing import Optional, List
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from src.domain.model.usuario import Usuario, Email, Direccion
from src.domain.repository.usuario_repository import IUsuarioRepository
from src.infrastructure.persistence.orm.usuario_model import UsuarioModel, DireccionModel

class SQLAlchemyUsuarioRepository(IUsuarioRepository):
    """Implementación de repositorio de Usuario con SQLAlchemy."""
    
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def obtener_por_id(self, id: UUID) -> Optional[Usuario]:
        result = await self.session.execute(
            select(UsuarioModel).where(UsuarioModel.id == id)
        )
        usuario_model = result.scalar_one_or_none()
        
        if not usuario_model:
            return None
            
        return self._map_to_domain(usuario_model)
    
    async def obtener_por_email(self, email: Email) -> Optional[Usuario]:
        result = await self.session.execute(
            select(UsuarioModel).where(UsuarioModel.email == email.direccion)
        )
        usuario_model = result.scalar_one_or_none()
        
        if not usuario_model:
            return None
            
        return self._map_to_domain(usuario_model)
    
    async def guardar(self, usuario: Usuario) -> Usuario:
        # Buscar si ya existe
        result = await self.session.execute(
            select(UsuarioModel).where(UsuarioModel.id == usuario.id)
        )
        usuario_model = result.scalar_one_or_none()
        
        if usuario_model:
            # Actualizar usuario existente
            usuario_model.nombre = usuario.nombre
            usuario_model.email = usuario.email.direccion
            usuario_model.activo = usuario.activo
            
            if usuario.direccion:
                if usuario_model.direccion:
                    # Actualizar dirección existente
                    usuario_model.direccion.calle = usuario.direccion.calle
                    usuario_model.direccion.ciudad = usuario.direccion.ciudad
                    usuario_model.direccion.codigo_postal = usuario.direccion.codigo_postal
                    usuario_model.direccion.pais = usuario.direccion.pais
                else:
                    # Crear nueva dirección
                    usuario_model.direccion = DireccionModel(
                        calle=usuario.direccion.calle,
                        ciudad=usuario.direccion.ciudad,
                        codigo_postal=usuario.direccion.codigo_postal,
                        pais=usuario.direccion.pais
                    )
            else:
                usuario_model.direccion = None
        else:
            # Crear nuevo usuario
            direccion_model = None
            if usuario.direccion:
                direccion_model = DireccionModel(
                    calle=usuario.direccion.calle,
                    ciudad=usuario.direccion.ciudad,
                    codigo_postal=usuario.direccion.codigo_postal,
                    pais=usuario.direccion.pais
                )
                
            usuario_model = UsuarioModel(
                id=usuario.id,
                nombre=usuario.nombre,
                email=usuario.email.direccion,
                fecha_registro=usuario.fecha_registro,
                activo=usuario.activo,
                direccion=direccion_model
            )
            self.session.add(usuario_model)
            
        await self.session.commit()
        await self.session.refresh(usuario_model)
        
        return self._map_to_domain(usuario_model)
    
    async def eliminar(self, id: UUID) -> None:
        result = await self.session.execute(
            select(UsuarioModel).where(UsuarioModel.id == id)
        )
        usuario_model = result.scalar_one_or_none()
        
        if usuario_model:
            await self.session.delete(usuario_model)
            await self.session.commit()
    
    async def listar(self, limit: int = 100, offset: int = 0) -> List[Usuario]:
        result = await self.session.execute(
            select(UsuarioModel)
            .limit(limit)
            .offset(offset)
        )
        usuario_models = result.scalars().all()
        
        return [self._map_to_domain(modelo) for modelo in usuario_models]
    
    def _map_to_domain(self, usuario_model: UsuarioModel) -> Usuario:
        direccion = None
        if usuario_model.direccion:
            direccion = Direccion(
                calle=usuario_model.direccion.calle,
                ciudad=usuario_model.direccion.ciudad,
                codigo_postal=usuario_model.direccion.codigo_postal,
                pais=usuario_model.direccion.pais
            )
            
        email = Email(direccion=usuario_model.email)
        
        return Usuario(
            id=usuario_model.id,
            nombre=usuario_model.nombre,
            email=email,
            direccion=direccion
        )
```

## Servicios de Aplicación

```python
# src/application/service/usuario_service.py
from typing import Optional
from uuid import UUID

from src.domain.model.usuario import Usuario, Email, Direccion
from src.domain.repository.usuario_repository import IUsuarioRepository
from src.application.dto.usuario_dto import UsuarioDTO, CrearUsuarioDTO, ActualizarUsuarioDTO
from src.infrastructure.messaging.event_bus import EventBus

class UsuarioService:
    """Servicio de aplicación para operaciones con usuarios."""
    
    def __init__(
        self, 
        usuario_repository: IUsuarioRepository,
        event_bus: EventBus
    ):
        self.usuario_repository = usuario_repository
        self.event_bus = event_bus
    
    async def crear_usuario(self, dto: CrearUsuarioDTO) -> UsuarioDTO:
        """Crea un nuevo usuario."""
        # Verificar si el email ya existe
        email = Email(direccion=dto.email)
        usuario_existente = await self.usuario_repository.obtener_por_email(email)
        
        if usuario_existente:
            raise ValueError(f"Ya existe un usuario con el email {dto.email}")
        
        # Crear dirección si se proporcionó
        direccion = None
        if dto.direccion:
            direccion = Direccion(
                calle=dto.direccion.calle,
                ciudad=dto.direccion.ciudad,
                codigo_postal=dto.direccion.codigo_postal,
                pais=dto.direccion.pais
            )
        
        # Crear entidad de dominio
        usuario = Usuario(
            nombre=dto.nombre,
            email=email,
            direccion=direccion
        )
        
        # Persistir y obtener eventos
        usuario_guardado = await self.usuario_repository.guardar(usuario)
        eventos = usuario.obtener_eventos()
        
        # Publicar eventos
        for evento in eventos:
            await self.event_bus.publicar(evento)
        
        # Mapear a DTO y retornar
        return self._map_to_dto(usuario_guardado)
    
    async def actualizar_usuario(self, id: UUID, dto: ActualizarUsuarioDTO) -> Optional[UsuarioDTO]:
        """Actualiza un usuario existente."""
        # Obtener usuario
        usuario = await self.usuario_repository.obtener_por_id(id)
        if not usuario:
            return None
        
        # Actualizar campos si fueron proporcionados
        if dto.nombre:
            usuario.nombre = dto.nombre
            
        if dto.email:
            nuevo_email = Email(direccion=dto.email)
            usuario.cambiar_email(nuevo_email)
            
        if dto.direccion:
            nueva_direccion = Direccion(
                calle=dto.direccion.calle,
                ciudad=dto.direccion.ciudad,
                codigo_postal=dto.direccion.codigo_postal,
                pais=dto.direccion.pais
            )
            usuario.cambiar_direccion(nueva_direccion)
        
        # Persistir y obtener eventos
        usuario_actualizado = await self.usuario_repository.guardar(usuario)
        eventos = usuario.obtener_eventos()
        
        # Publicar eventos
        for evento in eventos:
            await self.event_bus.publicar(evento)
        
        # Mapear a DTO y retornar
        return self._map_to_dto(usuario_actualizado)
    
    def _map_to_dto(self, usuario: Usuario) -> UsuarioDTO:
        """Mapea una entidad de dominio a un DTO."""
        return UsuarioDTO(
            id=str(usuario.id),
            nombre=usuario.nombre,
            email=usuario.email.direccion,
            direccion=(
                {
                    "calle": usuario.direccion.calle,
                    "ciudad": usuario.direccion.ciudad,
                    "codigo_postal": usuario.direccion.codigo_postal,
                    "pais": usuario.direccion.pais
                } if usuario.direccion else None
            ),
            fecha_registro=usuario.fecha_registro.isoformat(),
            activo=usuario.activo
        )
```

## Casos de Uso con CQRS

```python
# src/application/command/crear_usuario.py
from dataclasses import dataclass
from typing import Optional, Dict, Any

from src.domain.model.usuario import Email, Direccion, Usuario
from src.domain.repository.usuario_repository import IUsuarioRepository
from src.infrastructure.messaging.event_bus import EventBus

@dataclass
class CrearUsuarioCommand:
    """Comando para crear un nuevo usuario."""
    nombre: str
    email: str
    direccion: Optional[Dict[str, str]] = None

class CrearUsuarioHandler:
    """Manejador para el comando CrearUsuario."""
    
    def __init__(
        self, 
        usuario_repository: IUsuarioRepository,
        event_bus: EventBus
    ):
        self.usuario_repository = usuario_repository
        self.event_bus = event_bus
    
    async def handle(self, command: CrearUsuarioCommand) -> Dict[str, Any]:
        """Ejecuta el comando para crear un usuario."""
        # Validar email
        email = Email(direccion=command.email)
        
        # Verificar si ya existe
        usuario_existente = await self.usuario_repository.obtener_por_email(email)
        if usuario_existente:
            raise ValueError(f"Ya existe un usuario con el email {command.email}")
        
        # Crear dirección si se proporcionó
        direccion = None
        if command.direccion:
            direccion = Direccion(
                calle=command.direccion.get("calle", ""),
                ciudad=command.direccion.get("ciudad", ""),
                codigo_postal=command.direccion.get("codigo_postal", ""),
                pais=command.direccion.get("pais", "")
            )
        
        # Crear usuario
        usuario = Usuario(
            nombre=command.nombre,
            email=email,
            direccion=direccion
        )
        
        # Persistir
        usuario_guardado = await self.usuario_repository.guardar(usuario)
        
        # Publicar eventos
        eventos = usuario.obtener_eventos()
        for evento in eventos:
            await self.event_bus.publicar(evento)
        
        # Retornar resultado
        return {
            "id": str(usuario_guardado.id),
            "nombre": usuario_guardado.nombre,
            "email": usuario_guardado.email.direccion
        }
```

## Consideraciones para Implementar DDD

### 1. Enfoques Alternativos de Estructura

Existen variaciones en la estructura de directorios según las preferencias del equipo:

**Estructura por Módulos de Dominio:**

```
proyecto/
├── src/
│   ├── usuarios/                   # Módulo de usuarios
│   │   ├── domain/                 # Modelo de dominio
│   │   ├── application/            # Casos de uso
│   │   └── infrastructure/         # Implementaciones
│   │
│   ├── pedidos/                    # Módulo de pedidos
│   │   ├── domain/
│   │   ├── application/
│   │   └── infrastructure/
│   │
│   └── shared/                     # Código compartido
└── tests/
```

### 2. Consistencia en el Modelo de Dominio

- Usar tipos específicos del dominio en lugar de tipos primitivos
- Encapsular lógica de negocio dentro de entidades y agregados
- Definir claramente límites de agregados
- Evitar lógica de dominio en capas externas

### 3. Patrón Repositorio

- Usar repositorios como colecciones en memoria
- Devolver entidades completas, no DTOs, desde repositorios
- Implementar transacciones a nivel de unidad de trabajo

### 4. Aplicación vs. Dominio

- Mantener el dominio libre de dependencias externas
- Usar servicios de aplicación para orquestar la lógica entre entidades
- Implementar transformación de DTOs en la capa de aplicación

## Conclusión

La implementación efectiva de DDD requiere una estructura de código cuidadosamente diseñada que refleje los conceptos y patrones del dominio. Con la estructura presentada, se logra:

- Aislar el dominio de las preocupaciones técnicas
- Facilitar los cambios y evolución del modelo
- Mejorar la comprensión del sistema
- Mapear correctamente el lenguaje ubicuo al código

Esta estructura proporciona un punto de partida sólido para proyectos basados en DDD, pero debe adaptarse según las necesidades específicas del proyecto y equipo. 