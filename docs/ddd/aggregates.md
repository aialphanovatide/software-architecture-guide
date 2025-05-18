# Agregados en DDD

Los agregados son uno de los patrones fundamentales en el Diseño Dirigido por el Dominio (DDD) que ayudan a gestionar la complejidad en sistemas con muchas entidades relacionadas.

## ¿Qué es un Agregado?

Un agregado es un grupo de objetos relacionados que se tratan como una unidad para propósitos de cambios de datos. Cada agregado tiene:

- Una **raíz de agregado**: Una entidad específica que sirve como punto de entrada al agregado
- **Límites claros**: Define qué está dentro y fuera del agregado
- **Reglas de consistencia**: Garantiza que el agregado siempre esté en un estado válido

## Propósito de los Agregados

Los agregados resuelven varios problemas prácticos:

1. **Garantizan la consistencia**: Todas las reglas de negocio se aplican como una unidad
2. **Simplifican el modelo**: Reducen las relaciones directas entre objetos
3. **Protegen la integridad de los datos**: Evitan modificaciones no autorizadas
4. **Definen límites transaccionales**: Establecen qué se actualiza atómicamente

## Ejemplo Simple

Consideremos un sistema de comercio electrónico:

```python
class Pedido:
    """Raíz de agregado para el pedido"""
    
    def __init__(self, pedido_id, cliente_id):
        self.id = pedido_id
        self.cliente_id = cliente_id
        self.lineas = []  # Entidades dentro del agregado
        self.estado = "borrador"
    
    def agregar_producto(self, producto_id, cantidad, precio):
        """Solo la raíz puede modificar elementos internos"""
        if self.estado != "borrador":
            raise ValueError("No se pueden agregar productos a un pedido confirmado")
        
        # Validación interna antes de agregar una línea
        if cantidad <= 0:
            raise ValueError("La cantidad debe ser mayor que cero")
            
        linea = LineaPedido(self.id, producto_id, cantidad, precio)
        self.lineas.append(linea)
        
    def confirmar(self):
        """Cambio de estado que asegura consistencia"""
        if not self.lineas:
            raise ValueError("No se puede confirmar un pedido sin productos")
            
        if self.estado != "borrador":
            raise ValueError("Solo se pueden confirmar pedidos en borrador")
            
        self.estado = "confirmado"
        
    def total(self):
        """Calcula el total del pedido"""
        return sum(linea.subtotal() for linea in self.lineas)


class LineaPedido:
    """Entidad dentro del agregado Pedido"""
    
    def __init__(self, pedido_id, producto_id, cantidad, precio):
        self.pedido_id = pedido_id
        self.producto_id = producto_id
        self.cantidad = cantidad
        self.precio = precio
    
    def subtotal(self):
        return self.cantidad * self.precio
```

## Reglas para Diseñar Agregados

### 1. Diseñar agregados pequeños

Los agregados más pequeños son más fáciles de entender y modificar. Intenta mantener un agregado centrado en un concepto de negocio específico.

### 2. Referenciar otros agregados por identidad

Cuando un agregado necesita referenciar a otro, debe hacerlo por ID, no por referencia directa:

```python
# Correcto: Referencia por ID
class Pedido:
    def __init__(self, pedido_id, cliente_id):  # Cliente referenciado por ID
        self.id = pedido_id
        self.cliente_id = cliente_id

# Incorrecto: Referencia directa
class Pedido:
    def __init__(self, pedido_id, cliente):  # Referencia directa al objeto Cliente
        self.id = pedido_id
        self.cliente = cliente
```

### 3. Actualizar un agregado por operación

Cada operación de negocio debería actualizar un solo agregado. Si necesitas actualizar múltiples agregados, considera:

- Usar eventos de dominio para propagación eventual
- Revisar si tus límites de agregado son correctos
- Implementar un proceso de negocio para coordinar los cambios

## Aplicación Práctica de Agregados

### Ejemplo en un Sistema de Inventario

```python
class Producto:
    """Raíz de agregado para Producto"""
    
    def __init__(self, producto_id, nombre, precio, stock_actual):
        self.id = producto_id
        self.nombre = nombre
        self.precio = precio
        self._stock_actual = stock_actual
        self._reservas = []
    
    def reservar_stock(self, cantidad, pedido_id):
        """Método que asegura invariantes de negocio"""
        if cantidad <= 0:
            raise ValueError("La cantidad debe ser positiva")
            
        if self._stock_disponible() < cantidad:
            raise StockInsuficienteError(
                f"Stock insuficiente. Disponible: {self._stock_disponible()}, Solicitado: {cantidad}"
            )
            
        reserva = Reserva(pedido_id, cantidad)
        self._reservas.append(reserva)
        
    def confirmar_reserva(self, pedido_id):
        """Confirma una reserva y reduce el stock"""
        reserva = self._encontrar_reserva(pedido_id)
        if not reserva:
            raise ReservaNoEncontradaError(f"No existe reserva para el pedido {pedido_id}")
            
        self._stock_actual -= reserva.cantidad
        self._reservas.remove(reserva)
        
    def _stock_disponible(self):
        """Calcula stock disponible considerando reservas"""
        reservado = sum(reserva.cantidad for reserva in self._reservas)
        return self._stock_actual - reservado
        
    def _encontrar_reserva(self, pedido_id):
        """Encuentra una reserva por su pedido_id"""
        for reserva in self._reservas:
            if reserva.pedido_id == pedido_id:
                return reserva
        return None


class Reserva:
    """Objeto valor dentro del agregado Producto"""
    
    def __init__(self, pedido_id, cantidad):
        self.pedido_id = pedido_id
        self.cantidad = cantidad
        self.fecha_creacion = datetime.now()
```

## Persistencia de Agregados

Los agregados se cargan y guardan como una unidad:

```python
class ProductoRepository:
    def __init__(self, db_connection):
        self.db = db_connection
    
    def obtener_por_id(self, producto_id):
        """Carga el agregado completo desde la base de datos"""
        producto_data = self.db.execute(
            "SELECT id, nombre, precio, stock_actual FROM productos WHERE id = ?",
            (producto_id,)
        ).fetchone()
        
        if not producto_data:
            return None
            
        producto = Producto(
            producto_id=producto_data["id"],
            nombre=producto_data["nombre"],
            precio=producto_data["precio"],
            stock_actual=producto_data["stock_actual"]
        )
        
        # Cargar las reservas asociadas
        reservas_data = self.db.execute(
            "SELECT pedido_id, cantidad FROM reservas WHERE producto_id = ?",
            (producto_id,)
        ).fetchall()
        
        for reserva_data in reservas_data:
            # Recreamos el estado del agregado completo
            reserva = Reserva(
                pedido_id=reserva_data["pedido_id"],
                cantidad=reserva_data["cantidad"]
            )
            producto._reservas.append(reserva)
            
        return producto
        
    def guardar(self, producto):
        """Persiste todo el agregado"""
        # Actualizar la tabla de productos
        self.db.execute(
            """
            UPDATE productos 
            SET nombre = ?, precio = ?, stock_actual = ?
            WHERE id = ?
            """,
            (producto.nombre, producto.precio, producto._stock_actual, producto.id)
        )
        
        # Eliminar las reservas existentes
        self.db.execute(
            "DELETE FROM reservas WHERE producto_id = ?",
            (producto.id,)
        )
        
        # Insertar las reservas actuales
        for reserva in producto._reservas:
            self.db.execute(
                """
                INSERT INTO reservas (producto_id, pedido_id, cantidad, fecha_creacion)
                VALUES (?, ?, ?, ?)
                """,
                (producto.id, reserva.pedido_id, reserva.cantidad, reserva.fecha_creacion)
            )
            
        self.db.commit()
```

## Conclusión

Los agregados son una herramienta fundamental para manejar la complejidad en sistemas con muchas entidades relacionadas. Al diseñar agregados efectivos:

1. Mantén los agregados pequeños y enfocados
2. Asegúrate de que cada agregado proteja sus propias reglas de negocio
3. Usa referencias por ID entre agregados
4. Actualiza un solo agregado por operación cuando sea posible

Estos principios te ayudarán a crear sistemas más mantenibles, con reglas de negocio claras y consistentes. 