# Ejemplos Paso a Paso de DDD

Este documento proporciona ejemplos concretos y prácticos de Diseño Dirigido por el Dominio (DDD) adaptados para equipos que están comenzando. Utilizaremos un caso sencillo pero completo para mostrar cómo aplicar los conceptos de DDD de forma gradual.

## Ejemplo: Sistema de Biblioteca

Vamos a construir un sistema simple para gestionar préstamos de libros en una biblioteca, aplicando los conceptos de DDD paso a paso.

### 1. Definir el Lenguaje Ubicuo

Primero, creamos un glosario con términos claros:

| Término | Definición |
|---------|------------|
| Libro | Recurso físico que puede ser prestado a un usuario |
| Ejemplar | Copia física específica de un libro (con número único) |
| Usuario | Persona registrada que puede pedir prestados ejemplares |
| Préstamo | Periodo durante el cual un usuario tiene un ejemplar |
| Reserva | Solicitud de un usuario para obtener un libro cuando esté disponible |
| Catálogo | Colección completa de libros disponibles en la biblioteca |

### 2. Identificar Entidades y Objetos de Valor

**Entidades** (tienen identidad única):
- Usuario
- Ejemplar
- Préstamo
- Reserva

**Objetos de Valor** (no tienen identidad, importa su contenido):
- Información del Libro (título, autor, ISBN)
- Dirección
- Periodo de Préstamo
- Estado del Ejemplar (disponible, prestado, en reparación)

### 3. Construir Objetos de Valor

Empezamos con algunos objetos de valor sencillos:

```python
from dataclasses import dataclass
from datetime import datetime, timedelta
from enum import Enum, auto
from typing import Optional

@dataclass(frozen=True)
class InformacionLibro:
    """Objeto de valor que contiene información sobre un libro"""
    titulo: str
    autor: str
    isbn: str
    año_publicacion: int
    
    def __post_init__(self):
        # Validaciones básicas
        if not self.isbn or len(self.isbn) != 13:
            raise ValueError("ISBN debe tener 13 caracteres")
        if self.año_publicacion > datetime.now().year:
            raise ValueError("Año de publicación no puede ser futuro")


class EstadoEjemplar(Enum):
    """Estados posibles de un ejemplar"""
    DISPONIBLE = auto()
    PRESTADO = auto()
    EN_REPARACION = auto()
    EXTRAVIADO = auto()


@dataclass(frozen=True)
class PeriodoPrestamo:
    """Representa un período de préstamo con fecha inicio y fin"""
    fecha_inicio: datetime
    fecha_fin: datetime
    
    def __post_init__(self):
        if self.fecha_fin <= self.fecha_inicio:
            raise ValueError("La fecha fin debe ser posterior a la fecha inicio")
    
    @classmethod
    def crear_periodo_estandar(cls, desde: datetime, dias: int = 14):
        """Crea un período estándar de préstamo (por defecto 14 días)"""
        return cls(desde, desde + timedelta(days=dias))
    
    def esta_vigente(self) -> bool:
        """Verifica si el periodo actual está vigente"""
        return datetime.now() <= self.fecha_fin
    
    def dias_restantes(self) -> int:
        """Calcula días restantes, 0 si ya venció"""
        if not self.esta_vigente():
            return 0
        return (self.fecha_fin - datetime.now()).days
```

### 4. Construir Entidades

Ahora creamos algunas entidades básicas:

```python
class Usuario:
    """Entidad Usuario que puede pedir prestados ejemplares"""
    
    def __init__(self, usuario_id: str, nombre: str, email: str):
        self.id = usuario_id
        self.nombre = nombre
        self.email = email
        self.activo = True
        self.fecha_registro = datetime.now()
        self.prestamos_activos = 0
    
    def puede_pedir_prestado(self) -> bool:
        """Verifica si el usuario puede pedir más ejemplares prestados"""
        LIMITE_PRESTAMOS = 3
        return self.activo and self.prestamos_activos < LIMITE_PRESTAMOS
    
    def registrar_nuevo_prestamo(self) -> None:
        """Registra un nuevo préstamo para este usuario"""
        if not self.puede_pedir_prestado():
            raise ValueError("El usuario no puede pedir más ejemplares prestados")
        self.prestamos_activos += 1
    
    def registrar_devolucion(self) -> None:
        """Registra la devolución de un préstamo"""
        if self.prestamos_activos <= 0:
            raise ValueError("El usuario no tiene préstamos activos")
        self.prestamos_activos -= 1


class Ejemplar:
    """Entidad que representa una copia física de un libro"""
    
    def __init__(self, ejemplar_id: str, info_libro: InformacionLibro):
        self.id = ejemplar_id
        self.info_libro = info_libro
        self.estado = EstadoEjemplar.DISPONIBLE
        self.fecha_adquisicion = datetime.now()
        self.prestamo_actual: Optional[str] = None  # ID del préstamo actual
    
    def esta_disponible(self) -> bool:
        """Verifica si el ejemplar está disponible para préstamo"""
        return self.estado == EstadoEjemplar.DISPONIBLE
    
    def prestar(self, prestamo_id: str) -> None:
        """Marca el ejemplar como prestado"""
        if not self.esta_disponible():
            raise ValueError(f"El ejemplar no está disponible: {self.estado}")
        
        self.estado = EstadoEjemplar.PRESTADO
        self.prestamo_actual = prestamo_id
    
    def devolver(self) -> None:
        """Registra la devolución del ejemplar"""
        if self.estado != EstadoEjemplar.PRESTADO:
            raise ValueError(f"No se puede devolver un ejemplar que no está prestado: {self.estado}")
        
        self.estado = EstadoEjemplar.DISPONIBLE
        self.prestamo_actual = None
    
    def marcar_en_reparacion(self) -> None:
        """Marca el ejemplar como en reparación"""
        if self.estado == EstadoEjemplar.PRESTADO:
            raise ValueError("No se puede reparar un ejemplar prestado")
        
        self.estado = EstadoEjemplar.EN_REPARACION
```

### 5. Construir un Agregado con su Raíz

Ahora crearemos el agregado `Préstamo`, que encapsula la lógica de negocio:

```python
class Prestamo:
    """Agregado raíz que representa un préstamo de un ejemplar a un usuario"""
    
    def __init__(self, prestamo_id: str, usuario_id: str, ejemplar_id: str):
        self.id = prestamo_id
        self.usuario_id = usuario_id  # Referencia por ID
        self.ejemplar_id = ejemplar_id  # Referencia por ID
        self.fecha_prestamo = datetime.now()
        self.periodo = PeriodoPrestamo.crear_periodo_estandar(self.fecha_prestamo)
        self.fecha_devolucion: Optional[datetime] = None
        self.estado = "activo"  # activo, devuelto, vencido
        
        # Registramos eventos de dominio para posible publicación
        self._eventos = [
            PrestamoCreado(self.id, self.usuario_id, self.ejemplar_id, self.periodo)
        ]
    
    def esta_activo(self) -> bool:
        """Verifica si el préstamo está activo"""
        return self.estado == "activo"
    
    def esta_vencido(self) -> bool:
        """Verifica si el préstamo está vencido"""
        return self.esta_activo() and not self.periodo.esta_vigente()
    
    def renovar(self, dias: int = 14) -> None:
        """Renueva el préstamo por un período adicional"""
        if not self.esta_activo():
            raise ValueError("No se puede renovar un préstamo que no está activo")
        
        if self.esta_vencido():
            raise ValueError("No se puede renovar un préstamo vencido")
        
        # Crear nuevo período desde la fecha fin actual
        nueva_fecha_inicio = self.periodo.fecha_fin
        self.periodo = PeriodoPrestamo(
            nueva_fecha_inicio, 
            nueva_fecha_inicio + timedelta(days=dias)
        )
        
        self._eventos.append(
            PrestamoRenovado(self.id, self.periodo)
        )
    
    def devolver(self) -> None:
        """Registra la devolución del préstamo"""
        if not self.esta_activo():
            raise ValueError("No se puede devolver un préstamo que no está activo")
        
        self.estado = "devuelto"
        self.fecha_devolucion = datetime.now()
        
        self._eventos.append(
            PrestamoDevuelto(self.id, self.fecha_devolucion)
        )
    
    def obtener_eventos(self):
        """Devuelve y limpia los eventos pendientes"""
        eventos = self._eventos.copy()
        self._eventos.clear()
        return eventos


# Eventos de dominio (pueden ser publicados a otros contextos)
@dataclass
class PrestamoCreado:
    prestamo_id: str
    usuario_id: str
    ejemplar_id: str
    periodo: PeriodoPrestamo


@dataclass
class PrestamoRenovado:
    prestamo_id: str
    nuevo_periodo: PeriodoPrestamo


@dataclass
class PrestamoDevuelto:
    prestamo_id: str
    fecha_devolucion: datetime
```

### 6. Crear un Repositorio

El repositorio permite persistir y recuperar agregados:

```python
from abc import ABC, abstractmethod
from typing import Optional, List

class RepositorioPrestamos(ABC):
    """Interfaz para el repositorio de préstamos"""
    
    @abstractmethod
    def obtener_por_id(self, prestamo_id: str) -> Optional[Prestamo]:
        """Recupera un préstamo por su ID"""
        pass
    
    @abstractmethod
    def obtener_por_usuario(self, usuario_id: str) -> List[Prestamo]:
        """Recupera todos los préstamos de un usuario"""
        pass
    
    @abstractmethod
    def obtener_por_ejemplar(self, ejemplar_id: str) -> Optional[Prestamo]:
        """Recupera el préstamo activo de un ejemplar"""
        pass
    
    @abstractmethod
    def guardar(self, prestamo: Prestamo) -> None:
        """Guarda un préstamo nuevo o actualiza uno existente"""
        pass


# Implementación simple en memoria para ejemplos
class RepositorioPrestamosEnMemoria(RepositorioPrestamos):
    """Implementación en memoria del repositorio de préstamos"""
    
    def __init__(self):
        self.prestamos = {}  # Dict[str, Prestamo]
    
    def obtener_por_id(self, prestamo_id: str) -> Optional[Prestamo]:
        return self.prestamos.get(prestamo_id)
    
    def obtener_por_usuario(self, usuario_id: str) -> List[Prestamo]:
        return [
            p for p in self.prestamos.values() 
            if p.usuario_id == usuario_id and p.esta_activo()
        ]
    
    def obtener_por_ejemplar(self, ejemplar_id: str) -> Optional[Prestamo]:
        for prestamo in self.prestamos.values():
            if prestamo.ejemplar_id == ejemplar_id and prestamo.esta_activo():
                return prestamo
        return None
    
    def guardar(self, prestamo: Prestamo) -> None:
        self.prestamos[prestamo.id] = prestamo
```

### 7. Implementar un Servicio de Dominio

Los servicios de dominio implementan operaciones que involucran múltiples agregados:

```python
class ServicioVerificacionPrestamos:
    """Servicio de dominio para verificar disponibilidad de préstamos"""
    
    def __init__(
        self, 
        repositorio_usuarios, 
        repositorio_ejemplares, 
        repositorio_prestamos
    ):
        self.repositorio_usuarios = repositorio_usuarios
        self.repositorio_ejemplares = repositorio_ejemplares
        self.repositorio_prestamos = repositorio_prestamos
    
    def puede_realizar_prestamo(self, usuario_id: str, ejemplar_id: str) -> bool:
        """Verifica si se puede realizar un préstamo específico"""
        usuario = self.repositorio_usuarios.obtener_por_id(usuario_id)
        if not usuario or not usuario.puede_pedir_prestado():
            return False
            
        ejemplar = self.repositorio_ejemplares.obtener_por_id(ejemplar_id)
        if not ejemplar or not ejemplar.esta_disponible():
            return False
            
        return True
    
    def obtener_prestamos_a_vencer(self, dias: int = 3) -> List[Prestamo]:
        """Encuentra préstamos próximos a vencer en los próximos días"""
        prestamos_activos = self.repositorio_prestamos.obtener_activos()
        return [
            p for p in prestamos_activos 
            if 0 < p.periodo.dias_restantes() <= dias
        ]
```

### 8. Implementar un Servicio de Aplicación

Los servicios de aplicación coordinan las operaciones complejas del sistema:

```python
class ServicioPrestamos:
    """Servicio de aplicación que coordina operaciones de préstamo"""
    
    def __init__(
        self, 
        repositorio_usuarios,
        repositorio_ejemplares,
        repositorio_prestamos,
        servicio_verificacion,
        publicador_eventos
    ):
        self.repositorio_usuarios = repositorio_usuarios
        self.repositorio_ejemplares = repositorio_ejemplares
        self.repositorio_prestamos = repositorio_prestamos
        self.servicio_verificacion = servicio_verificacion
        self.publicador_eventos = publicador_eventos
    
    def realizar_prestamo(self, usuario_id: str, ejemplar_id: str) -> Prestamo:
        """Realiza un nuevo préstamo"""
        # Verificar que se pueda hacer el préstamo
        if not self.servicio_verificacion.puede_realizar_prestamo(usuario_id, ejemplar_id):
            raise ValueError("No se puede realizar el préstamo")
        
        # Obtener entidades
        usuario = self.repositorio_usuarios.obtener_por_id(usuario_id)
        ejemplar = self.repositorio_ejemplares.obtener_por_id(ejemplar_id)
        
        # Generar ID único para el préstamo
        prestamo_id = f"PREST-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        
        # Crear el nuevo préstamo
        prestamo = Prestamo(prestamo_id, usuario_id, ejemplar_id)
        
        # Actualizar entidades relacionadas
        usuario.registrar_nuevo_prestamo()
        ejemplar.prestar(prestamo_id)
        
        # Persistir cambios
        self.repositorio_usuarios.guardar(usuario)
        self.repositorio_ejemplares.guardar(ejemplar)
        self.repositorio_prestamos.guardar(prestamo)
        
        # Publicar eventos de dominio
        for evento in prestamo.obtener_eventos():
            self.publicador_eventos.publicar(evento)
        
        return prestamo
    
    def devolver_prestamo(self, prestamo_id: str) -> None:
        """Procesa la devolución de un préstamo"""
        # Obtener el préstamo
        prestamo = self.repositorio_prestamos.obtener_por_id(prestamo_id)
        if not prestamo:
            raise ValueError(f"Préstamo no encontrado: {prestamo_id}")
        
        if not prestamo.esta_activo():
            raise ValueError("El préstamo ya fue devuelto")
        
        # Obtener entidades relacionadas
        usuario = self.repositorio_usuarios.obtener_por_id(prestamo.usuario_id)
        ejemplar = self.repositorio_ejemplares.obtener_por_id(prestamo.ejemplar_id)
        
        # Registrar devolución
        prestamo.devolver()
        usuario.registrar_devolucion()
        ejemplar.devolver()
        
        # Persistir cambios
        self.repositorio_prestamos.guardar(prestamo)
        self.repositorio_usuarios.guardar(usuario)
        self.repositorio_ejemplares.guardar(ejemplar)
        
        # Publicar eventos de dominio
        for evento in prestamo.obtener_eventos():
            self.publicador_eventos.publicar(evento)
```

### 9. Ejemplo de Uso Completo

Aquí hay una demostración de cómo usaríamos el sistema en la práctica:

```python
# Crear implementaciones de repositorios en memoria para el ejemplo
repositorio_usuarios = RepositorioUsuariosEnMemoria()
repositorio_ejemplares = RepositorioEjemplaresEnMemoria()
repositorio_prestamos = RepositorioPrestamosEnMemoria()

# Crear un servicio de verificación
servicio_verificacion = ServicioVerificacionPrestamos(
    repositorio_usuarios,
    repositorio_ejemplares,
    repositorio_prestamos
)

# Crear un publicador de eventos simple
class PublicadorEventos:
    def publicar(self, evento):
        print(f"Evento publicado: {evento}")

publicador = PublicadorEventos()

# Crear el servicio de aplicación
servicio_prestamos = ServicioPrestamos(
    repositorio_usuarios,
    repositorio_ejemplares,
    repositorio_prestamos,
    servicio_verificacion,
    publicador
)

# Crear un usuario
usuario = Usuario("U001", "Ana García", "ana@ejemplo.com")
repositorio_usuarios.guardar(usuario)

# Crear información de libro y ejemplar
info_libro = InformacionLibro(
    "El Principito", 
    "Antoine de Saint-Exupéry", 
    "9788478887194", 
    1943
)
ejemplar = Ejemplar("E001", info_libro)
repositorio_ejemplares.guardar(ejemplar)

# Realizar un préstamo
try:
    prestamo = servicio_prestamos.realizar_prestamo("U001", "E001")
    print(f"Préstamo realizado: {prestamo.id}")
    print(f"Fecha de devolución: {prestamo.periodo.fecha_fin}")
except ValueError as e:
    print(f"Error al realizar préstamo: {e}")

# Devolver el préstamo
try:
    servicio_prestamos.devolver_prestamo(prestamo.id)
    print(f"Préstamo {prestamo.id} devuelto correctamente")
except ValueError as e:
    print(f"Error al devolver préstamo: {e}")
```

## Progresión de Aprendizaje

Este ejemplo muestra una progresión natural de conceptos de DDD:

1. **Comenzamos con el Lenguaje Ubicuo**: definiendo términos claros
2. **Luego identificamos Entidades y Objetos de Valor**: diferenciando conceptos con y sin identidad
3. **Construimos Agregados**: agrupando elementos relacionados con reglas de consistencia
4. **Definimos Repositorios**: para persistencia y recuperación de agregados
5. **Creamos Servicios de Dominio**: para encapsular lógica que involucra múltiples agregados
6. **Implementamos Servicios de Aplicación**: para orquestar casos de uso completos

## Siguientes Pasos

Una vez que domines estos conceptos, puedes avanzar a:

1. **Contextos Delimitados**: separar diferentes áreas del sistema (catalogación, préstamos, membresías)
2. **Eventos de Dominio**: para comunicación entre contextos y desacoplamiento
3. **Lenguaje Ubicuo más rico**: refinando constantemente el modelo junto con expertos del dominio

Recuerda que DDD es un proceso iterativo. Tu modelo evolucionará con el tiempo a medida que entiendas mejor el dominio. 