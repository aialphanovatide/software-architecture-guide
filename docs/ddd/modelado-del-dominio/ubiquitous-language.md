# Lenguaje Ubicuo

El Lenguaje Ubicuo es uno de los conceptos fundamentales del Diseño Dirigido por el Dominio (DDD). Se refiere a un lenguaje común, compartido entre todos los miembros del equipo, que refleja con precisión los conceptos y procesos del dominio de negocio.

## ¿Qué es el Lenguaje Ubicuo?

El Lenguaje Ubicuo es:

- Un vocabulario común entre desarrolladores y expertos del dominio
- Un lenguaje que se utiliza consistentemente en todas las formas de comunicación
- Un puente que conecta el modelo de dominio con la implementación del código
- Una herramienta para reducir la ambigüedad y mejorar la comunicación

## Importancia del Lenguaje Ubicuo

### Para los Desarrolladores
- Reduce la "traducción" constante entre términos técnicos y de negocio
- Permite entender mejor el dominio que están modelando
- Guía las decisiones de diseño y arquitectura

### Para los Expertos del Dominio
- Facilita la validación de que el software realmente atiende sus necesidades
- Permite ver sus conceptos de negocio reflejados directamente en el software
- Mejora su capacidad para colaborar efectivamente con los desarrolladores

### Para el Proyecto
- Reduce malentendidos y errores de comunicación
- Mejora la documentación y la transferencia de conocimiento
- Crea un modelo de dominio más preciso y útil

## Desarrollo del Lenguaje Ubicuo

### 1. Identificación de Términos del Dominio

La primera fase consiste en identificar y catalogar los términos clave del dominio:

- **Sustantivos**: Representan entidades, objetos de valor y agregados
- **Verbos**: Representan operaciones, comandos y eventos
- **Reglas y restricciones**: Expresan políticas y lógica de negocio

#### Ejemplo: Sistema de Gestión de Pedidos

**Términos incorrectos o ambiguos**:
- "Actualizar registro en la base de datos"
- "Objeto cliente"
- "Cambiar estado de la tabla"

**Lenguaje Ubicuo correcto**:
- "Confirmar pedido"
- "Cliente"
- "Marcar pedido como entregado"

### 2. Documentación y Refinamiento

Una vez identificados los términos clave, deben ser documentados y refinados a través de:

- **Glosarios de términos**: Definiciones claras y acordadas
- **Mapas conceptuales**: Visualización de relaciones entre conceptos
- **Casos de uso escritos con el lenguaje**: Escenarios que utilizan los términos

#### Ejemplo de Glosario

```
Pedido: Una solicitud de compra iniciada por un Cliente que contiene una o más Líneas de Pedido.

Línea de Pedido: Un ítem específico dentro de un Pedido, que referencia un Producto y especifica una Cantidad.

Confirmar Pedido: Acción que valida un Pedido y lo prepara para su procesamiento.

Pedido Confirmado: Estado de un Pedido que ha sido validado y está listo para su preparación.
```

### 3. Implementación en el Código

El Lenguaje Ubicuo debe reflejarse directamente en el código:

```python
# Mal ejemplo (sin lenguaje ubicuo)
class Order:
    def update_status(self, new_status):
        self.status = new_status
        self.db.save(self)

# Buen ejemplo (con lenguaje ubicuo)
class Pedido:
    def confirmar(self):
        if not self.puede_ser_confirmado():
            raise PedidoInvalidoError("El pedido no puede ser confirmado")
        
        self.estado = EstadoPedido.CONFIRMADO
        self.fecha_confirmacion = datetime.now()
    
    def puede_ser_confirmado(self):
        return (self.estado == EstadoPedido.BORRADOR and
                all(linea.producto.disponible for linea in self.lineas_pedido))
```

### 4. Uso en Comunicación Diaria

El Lenguaje Ubicuo debe impregnar todos los aspectos de la comunicación:

- Reuniones de planificación
- Documentación técnica
- Historias de usuario y criterios de aceptación
- Mensajes de commit y nombres de ramas
- Logs y mensajes de error

## Ejemplos de Lenguaje Ubicuo en Diferentes Dominios

### Banca

```python
class CuentaBancaria:
    def __init__(self, numero_cuenta, titular):
        self.numero_cuenta = numero_cuenta
        self.titular = titular
        self.saldo = 0
        self.movimientos = []
    
    def depositar(self, monto, concepto):
        """Registrar un depósito en la cuenta"""
        self.saldo += monto
        self.movimientos.append(Movimiento(tipo=TipoMovimiento.DEPOSITO, 
                                          monto=monto, 
                                          concepto=concepto))
    
    def retirar(self, monto, concepto):
        """Registrar un retiro de la cuenta"""
        if monto > self.saldo:
            raise FondosInsuficientesError("Saldo insuficiente para realizar el retiro")
        
        self.saldo -= monto
        self.movimientos.append(Movimiento(tipo=TipoMovimiento.RETIRO, 
                                          monto=monto, 
                                          concepto=concepto))
```

### E-commerce

```python
class Carrito:
    def __init__(self, cliente):
        self.cliente = cliente
        self.items = []
        self.cupones_descuento = []
    
    def agregar_producto(self, producto, cantidad):
        """Agregar un producto al carrito de compras"""
        item_existente = next((i for i in self.items if i.producto.id == producto.id), None)
        
        if item_existente:
            item_existente.incrementar_cantidad(cantidad)
        else:
            self.items.append(ItemCarrito(producto, cantidad))
    
    def aplicar_cupon(self, cupon):
        """Aplicar un cupón de descuento al carrito"""
        if not cupon.es_valido(self.cliente, self.calcular_subtotal()):
            raise CuponInvalidoError("El cupón no es válido para este carrito")
        
        self.cupones_descuento.append(cupon)
    
    def convertir_a_pedido(self):
        """Convertir el carrito actual en un pedido"""
        if not self.items:
            raise CarritoVacioError("No se puede crear un pedido con un carrito vacío")
        
        return Pedido.crear_desde_carrito(self)
```

## Errores Comunes y Cómo Evitarlos

### Mezclar Lenguajes Técnicos y de Dominio

**Problema**: Usar términos técnicos (DTO, repositorio, API) en discusiones de dominio y viceversa.

**Solución**: Separar claramente las discusiones técnicas de las de dominio, usando el lenguaje apropiado en cada contexto.

### Inconsistencia en el Uso de Términos

**Problema**: Usar diferentes términos para el mismo concepto ("Cliente", "Usuario", "Comprador").

**Solución**: Mantener un glosario actualizado y correctamente la terminología en todo momento.

### Terminología Vaga o Ambigua

**Problema**: Usar términos genéricos que pueden interpretarse de diferentes maneras.

**Solución**: Definir cada término con precisión, incluyendo ejemplos y contraejemplos.

## Mantenimiento del Lenguaje Ubicuo

El Lenguaje Ubicuo debe evolucionar junto con el dominio:

1. **Revisiones periódicas**: Actualizar el glosario y verificar que todos siguen usándolo
2. **Refactorización del código**: Mantener el código alineado con el lenguaje actual
3. **Corrección de desviaciones**: Identificar y corregir términos que se están usando incorrectamente
4. **Evolución del modelo**: Ajustar el lenguaje cuando se descubren nuevos conocimientos del dominio

## Conclusión

Un Lenguaje Ubicuo bien desarrollado y mantenido es la base de un modelo de dominio efectivo y de una comunicación fluida en el equipo. Invierte tiempo en desarrollar este lenguaje común y verás cómo la calidad de tu software mejora sustancialmente, tanto en términos de cumplimiento de requisitos como de mantenibilidad a largo plazo. 