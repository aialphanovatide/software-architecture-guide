# Contextos Delimitados

Los Contextos Delimitados (Bounded Contexts) son un concepto central en el Diseño Dirigido por el Dominio (DDD) que ayuda a manejar la complejidad en modelos de dominio grandes dividiendo el dominio en múltiples modelos conceptuales con límites explícitos.

## ¿Qué son los Contextos Delimitados?

Un Contexto Delimitado es:

- Una frontera conceptual alrededor de un modelo de dominio particular
- Un límite dentro del cual un término específico tiene un significado claro y consistente
- Una unidad de trabajo donde se aplica un [Lenguaje Ubicuo](ubiquitous-language.md) determinado
- Un subsistema con responsabilidades y reglas de negocio específicas

## ¿Por qué son necesarios los Contextos Delimitados?

En sistemas complejos, mantener un único modelo unificado se vuelve imposible porque:

- El mismo término puede tener significados diferentes en distintas partes del negocio
- Diferentes equipos pueden estar trabajando en partes diferentes del sistema
- Un modelo que intenta abarcar todo se vuelve difícil de entender y mantener
- Diferentes partes del sistema evolucionan a ritmos diferentes

## Identificación de Contextos Delimitados

Los Contextos Delimitados suelen alinearse con:

1. **Áreas organizacionales**: Departamentos o equipos con diferentes responsabilidades
2. **Procesos de negocio distintos**: Actividades empresariales diferentes
3. **Discontinuidades lingüísticas**: Cuando el mismo término significa algo diferente en distintas áreas

### Signos de que necesitas dividir un contexto:

- El modelo se está volviendo demasiado complejo y grande
- Hay términos que tienen diferentes significados según quién los use
- Diferentes partes del sistema cambian por razones distintas
- Hay reglas de negocio que solo aplican a ciertas partes del sistema

## Estructura de un Contexto Delimitado

Cada Contexto Delimitado contiene:

1. **Modelo de dominio**: Las entidades, objetos de valor, agregados, etc., específicos de ese contexto
2. **Lenguaje Ubicuo**: La terminología precisa utilizada dentro del contexto
3. **Interfaces de comunicación**: Los puntos de integración con otros contextos
4. **Límites explícitos**: Barreras claras que determinan qué está dentro y fuera del contexto

## Mapa de Contextos (Context Map)

El Mapa de Contextos es una herramienta visual que muestra las relaciones entre diferentes Contextos Delimitados.

### Elementos de un Mapa de Contextos:

- **Contextos Delimitados**: Representados como cajas o círculos
- **Relaciones entre contextos**: Flechas o líneas que conectan los contextos
- **Patrones de integración**: Anotaciones que describen el tipo de relación

### Patrones de relación entre contextos:

1. **Partnership (Asociación)**: Dos contextos colaboran para lograr un objetivo común
2. **Shared Kernel (Núcleo Compartido)**: Un subconjunto del modelo compartido entre dos contextos
3. **Customer-Supplier (Cliente-Proveedor)**: Un contexto (proveedor) proporciona servicios a otro (cliente)
4. **Conformist (Conformista)**: Un contexto se adapta al modelo de otro sin influir en él
5. **Anticorruption Layer (Capa Anticorrupción)**: Un contexto protege su modelo mediante una capa de traducción
6. **Open Host Service (Servicio Anfitrión Abierto)**: Un contexto proporciona una API clara y bien documentada
7. **Published Language (Lenguaje Publicado)**: Un formato compartido para la comunicación entre contextos
8. **Separate Ways (Caminos Separados)**: Contextos que deciden no integrarse

## Implementación de Contextos Delimitados

### 1. Separación en el código

```python
# Módulo para el Contexto de Ventas
class ventas:
    class Pedido:
        def __init__(self, cliente_id, items):
            self.cliente_id = cliente_id
            self.items = items
            self.estado = "creado"
            
        def confirmar(self):
            self.estado = "confirmado"
            return EventoPedidoConfirmado(self.id)

# Módulo para el Contexto de Envíos
class envios:
    class Envio:
        def __init__(self, pedido_id, direccion, items):
            self.pedido_id = pedido_id
            self.direccion = direccion
            self.items = items
            self.estado = "pendiente"
            
        def despachar(self):
            self.estado = "en_transito"
            return EventoEnvioDespachado(self.id)
```

### 2. Separación en repositorios de código

```
proyecto/
├── contextos/
│   ├── ventas/
│   │   ├── dominio/
│   │   │   ├── pedido.py
│   │   │   ├── cliente.py
│   │   │   └── producto.py
│   │   ├── aplicacion/
│   │   │   ├── comandos/
│   │   │   └── consultas/
│   │   └── infraestructura/
│   │       ├── repositorios/
│   │       └── api/
│   │
│   └── envios/
│       ├── dominio/
│       │   ├── envio.py
│       │   ├── ruta.py
│       │   └── paquete.py
│       ├── aplicacion/
│       │   ├── comandos/
│       │   └── consultas/
│       └── infraestructura/
│           ├── repositorios/
│           └── api/
```

### 3. Separación en servicios (en una arquitectura de microservicios)

```
                  +--------------------+   REST/GraphQL   +--------------------+
                  |                    |<---------------->|                    |
                  |  Servicio Ventas   |                  |  Servicio Envíos   |
                  |                    |                  |                    |
                  +--------------------+                  +--------------------+
                      ^           |                          ^           |
                      |           |                          |           |
                      |           v                          |           v
                  +----------+  +----------+            +----------+  +----------+
                  |          |  |          |            |          |  |          |
                  |   BD     |  |  Cola    |            |   BD     |  |  Cola    |
                  | Ventas   |  | Eventos  |            | Envíos   |  | Eventos  |
                  |          |  |          |            |          |  |          |
                  +----------+  +----------+            +----------+  +----------+
```

## Patrones de implementación para la comunicación entre contextos

### 1. Integración mediante eventos de dominio

```python
# En el Contexto de Ventas
class ServicioPedidos:
    def __init__(self, repositorio_pedidos, publicador_eventos):
        self.repositorio_pedidos = repositorio_pedidos
        self.publicador_eventos = publicador_eventos
    
    def confirmar_pedido(self, pedido_id):
        pedido = self.repositorio_pedidos.obtener_por_id(pedido_id)
        if not pedido:
            raise PedidoNoEncontradoError(f"Pedido {pedido_id} no encontrado")
        
        pedido.confirmar()
        self.repositorio_pedidos.guardar(pedido)
        
        # Publicar evento para que lo consuma el Contexto de Envíos
        evento = EventoPedidoConfirmado(
            pedido_id=pedido.id,
            cliente_id=pedido.cliente_id,
            items=pedido.items,
            direccion_entrega=pedido.direccion_entrega
        )
        self.publicador_eventos.publicar("pedidos.confirmado", evento)

# En el Contexto de Envíos
class ManejadorPedidosConfirmados:
    def __init__(self, servicio_envios):
        self.servicio_envios = servicio_envios
    
    def manejar(self, evento):
        # Crear un envío basado en el pedido confirmado
        self.servicio_envios.crear_envio(
            pedido_id=evento.pedido_id,
            direccion=evento.direccion_entrega,
            items=evento.items
        )
```

### 2. Capa Anticorrupción

```python
# Capa Anticorrupción para proteger el Contexto de Envíos
# de las peculiaridades del Contexto de Facturación

class AdaptadorSistemaFacturacion:
    def __init__(self, cliente_api_facturacion):
        self.cliente = cliente_api_facturacion
    
    def obtener_estado_factura(self, envio_id):
        # El sistema de facturación usa un formato diferente para las IDs
        id_factura = f"ENV{envio_id}F"
        
        # Llamada al sistema externo
        respuesta = self.cliente.obtener_factura(id_factura)
        
        # Traducir los estados de facturación a nuestro modelo
        if respuesta["estado"] == "PAID":
            return "pagada"
        elif respuesta["estado"] == "PENDING":
            return "pendiente"
        elif respuesta["estado"] == "CANCELLED":
            return "cancelada"
        else:
            return "desconocido"
```

## Consideraciones para definir Contextos Delimitados

### Tamaño adecuado

- **Demasiado grandes**: Se pierde el foco y se vuelven difíciles de entender
- **Demasiado pequeños**: Excesiva fragmentación y sobrecarga de comunicación

### Evolución a lo largo del tiempo

- Los Contextos Delimitados no son estáticos, evolucionan con el negocio
- Es normal refactorizar y reorganizar los contextos a medida que se comprende mejor el dominio

### Alineación con la organización

- Considerar la estructura de equipos al definir los contextos
- La Ley de Conway sugiere que los sistemas reflejarán la estructura de comunicación de la organización

## Errores comunes y cómo evitarlos

### 1. Contextos demasiado acoplados

**Problema**: Excesiva dependencia entre contextos, lo que limita la autonomía.

**Solución**: Utilizar patrones de integración como eventos de dominio que reducen el acoplamiento.

### 2. Inconsistencia en los límites

**Problema**: Límites borrosos o cambiantes entre contextos.

**Solución**: Documentar explícitamente los contextos y sus interfaces en un mapa de contextos.

### 3. Modelos que se filtran entre contextos

**Problema**: Conceptos de un contexto invadiendo otros contextos.

**Solución**: Implementar capas anticorrupción y adaptar/traducir conceptos entre contextos.

## Conclusión

Los Contextos Delimitados son una herramienta poderosa para gestionar la complejidad en sistemas grandes. Definir contextos claros permite:

- Simplificar la comprensión de partes específicas del sistema
- Minimizar el impacto de los cambios en otras áreas
- Habilitar el desarrollo en paralelo por diferentes equipos
- Mantener la integridad de los modelos de dominio

No existe un único enfoque correcto para delimitar contextos; lo importante es que los límites elegidos reflejen una separación significativa en el dominio y faciliten el desarrollo y mantenimiento del sistema. 