# Patrones Estructurales

Los patrones estructurales se ocupan de cómo se combinan las clases y los objetos para formar estructuras más grandes y proporcionar nuevas funcionalidades. Estos patrones nos ayudan a asegurar que cuando una parte del sistema cambia, no es necesario cambiar todo el sistema.

## 1. Adapter (Adaptador)

### Propósito
Permitir que interfaces incompatibles trabajen juntas, convirtiendo la interfaz de una clase en otra que el cliente espera.

### Caso de uso: Integrar un API de pagos cripto con una interfaz de pagos tradicional
Supón que tu plataforma SaaS acepta pagos tradicionales (tarjeta, PayPal) y ahora quieres aceptar pagos cripto, pero la API de cripto tiene una interfaz diferente.

---

### Problema (antes de Adapter)

```python
# Interfaz esperada por el sistema
class ProcesadorPagoTradicional:
    def pagar(self, monto):
        pass

# API de cripto con interfaz diferente
class ApiPagoCripto:
    def send_crypto(self, wallet, amount):
        print(f"Enviando {amount} a la wallet {wallet}")
        return True

# El sistema espera usar 'pagar', pero la API cripto usa 'send_crypto'
# No son compatibles directamente
```

**¿Qué está mal aquí?**
- No puedes usar la API de cripto donde el sistema espera un procesador tradicional.
- Tendrías que modificar el sistema o la API, lo que no es deseable.

---

### Solución: Aplicando Adapter

```python
# Adaptador que convierte la interfaz cripto a la tradicional
class AdaptadorPagoCripto(ProcesadorPagoTradicional):
    def __init__(self, api_cripto, wallet):
        self.api_cripto = api_cripto
        self.wallet = wallet
    def pagar(self, monto):
        return self.api_cripto.send_crypto(self.wallet, monto)

# Uso
api_cripto = ApiPagoCripto()
adaptador = AdaptadorPagoCripto(api_cripto, "WALLET123")
adaptador.pagar(50)  # Enviando 50 a la wallet WALLET123
```

**¿Qué mejoró?**
- Puedes integrar la API cripto sin modificar el sistema ni la API.
- El sistema puede tratar todos los procesadores de pago de la misma forma.
- Facilita la extensión y el mantenimiento.

---

### Checklist para aplicar Adapter
- [ ] ¿Tienes dos interfaces incompatibles que deben trabajar juntas?
- [ ] ¿No puedes (o no quieres) modificar el código original?
- [ ] ¿Necesitas reutilizar código existente en un nuevo contexto?
- [ ] ¿Quieres mantener el sistema desacoplado de implementaciones externas?

### Cuándo usarlo
- Cuando necesitas usar una clase existente pero su interfaz no coincide con la que necesitas
- Para crear una clase reutilizable que coopere con clases que no tienen necesariamente interfaces compatibles
- Para integrar sistemas heredados o bibliotecas externas

### Ejemplo en Python

```python
# Interfaz esperada por el cliente
class ObjetivoJSON:
    def request(self) -> dict:
        pass

# Clase existente con interfaz incompatible
class ServicioXML:
    def request_xml(self) -> str:
        return "<data><item>1</item><item>2</item></data>"

# Adaptador que convierte XML a JSON
class AdaptadorXMLaJSON(ObjetivoJSON):
    def __init__(self, servicio_xml: ServicioXML):
        self.servicio_xml = servicio_xml
    
    def request(self) -> dict:
        # Simulamos la conversión de XML a JSON
        xml = self.servicio_xml.request_xml()
        # En un caso real, usaríamos una biblioteca para parsear XML
        if "<data><item>1</item><item>2</item></data>" in xml:
            return {"data": {"items": [1, 2]}}
        return {}

# Cliente que espera JSON
class Cliente:
    def __init__(self, servicio_json: ObjetivoJSON):
        self.servicio_json = servicio_json
    
    def ejecutar(self) -> None:
        datos = self.servicio_json.request()
        print(f"Recibidos datos en JSON: {datos}")

# Uso
servicio_xml = ServicioXML()
adaptador = AdaptadorXMLaJSON(servicio_xml)
cliente = Cliente(adaptador)
cliente.ejecutar()  # Recibidos datos en JSON: {'data': {'items': [1, 2]}}
```

### Consideraciones
- Permite que clases con interfaces incompatibles trabajen juntas
- Aumenta la reutilización de código existente
- Puede introducir una pequeña sobrecarga de rendimiento

## 2. Bridge (Puente)

### Propósito
Separar una abstracción de su implementación para que ambas puedan variar independientemente.

### Caso de uso: Métodos de envío y transportistas en e-commerce
Supón que tu tienda online ofrece varios métodos de envío (normal, exprés, locker) y trabaja con diferentes transportistas (DHL, FedEx, Correo). Quieres poder combinar cualquier método con cualquier transportista, y que sea fácil agregar nuevos métodos o transportistas sin modificar el resto del sistema.

---

### Problema (antes de Bridge)

```python
class EnvioNormalDHL:
    def enviar(self, pedido):
        print(f"Enviando {pedido} por DHL normal")

class EnvioNormalFedEx:
    def enviar(self, pedido):
        print(f"Enviando {pedido} por FedEx normal")

class EnvioExpresDHL:
    def enviar(self, pedido):
        print(f"Enviando {pedido} por DHL exprés")

# Si agregas un nuevo método o transportista, tienes que crear muchas clases nuevas
```

**¿Qué está mal aquí?**
- El número de clases crece rápidamente (combinación de métodos x transportistas).
- Es difícil mantener y extender el sistema.
- No puedes agregar fácilmente nuevos métodos o transportistas.

---

### Solución: Aplicando Bridge

```python
from abc import ABC, abstractmethod

# Implementación: Transportistas
class Transportista(ABC):
    @abstractmethod
    def enviar(self, pedido, tipo_envio):
        pass

class DHL(Transportista):
    def enviar(self, pedido, tipo_envio):
        print(f"Enviando {pedido} por DHL ({tipo_envio})")

class FedEx(Transportista):
    def enviar(self, pedido, tipo_envio):
        print(f"Enviando {pedido} por FedEx ({tipo_envio})")

class Correo(Transportista):
    def enviar(self, pedido, tipo_envio):
        print(f"Enviando {pedido} por Correo ({tipo_envio})")

# Abstracción: Métodos de envío
class MetodoEnvio(ABC):
    def __init__(self, transportista: Transportista):
        self.transportista = transportista
    @abstractmethod
    def enviar(self, pedido):
        pass

class EnvioNormal(MetodoEnvio):
    def enviar(self, pedido):
        self.transportista.enviar(pedido, "normal")

class EnvioExpres(MetodoEnvio):
    def enviar(self, pedido):
        self.transportista.enviar(pedido, "exprés")

class EnvioLocker(MetodoEnvio):
    def enviar(self, pedido):
        self.transportista.enviar(pedido, "locker")

# Uso
pedido = "Pedido #1234"

envio1 = EnvioNormal(DHL())
envio1.enviar(pedido)  # Enviando Pedido #1234 por DHL (normal)

envio2 = EnvioExpres(FedEx())
envio2.enviar(pedido)  # Enviando Pedido #1234 por FedEx (exprés)

envio3 = EnvioLocker(Correo())
envio3.enviar(pedido)  # Enviando Pedido #1234 por Correo (locker)
```

**¿Qué mejoró?**
- Puedes combinar cualquier método de envío con cualquier transportista.
- Agregar nuevos métodos o transportistas es fácil y no afecta el resto del sistema.
- El código es más limpio, flexible y mantenible.

---

### Checklist para aplicar Bridge
- [ ] ¿Tienes dos dimensiones que pueden variar independientemente (por ejemplo, métodos y transportistas)?
- [ ] ¿Quieres evitar una explosión de clases por combinaciones?
- [ ] ¿Necesitas poder extender el sistema fácilmente en ambas dimensiones?
- [ ] ¿Quieres mantener el código desacoplado y flexible?

### Cuándo usarlo
- Cuando quieres evitar un enlace permanente entre una abstracción y su implementación
- Cuando tanto la abstracción como su implementación deben ser extensibles por subclases
- Cuando cambios en la implementación no deben afectar al cliente

### Ejemplo en Python

```python
from abc import ABC, abstractmethod

# Implementación
class DispositivoSalida(ABC):
    @abstractmethod
    def mostrar(self, datos):
        pass

class Pantalla(DispositivoSalida):
    def mostrar(self, datos):
        return f"Mostrando en pantalla: {datos}"

class Impresora(DispositivoSalida):
    def mostrar(self, datos):
        return f"Imprimiendo: {datos}"

# Abstracción
class Documento(ABC):
    def __init__(self, implementacion: DispositivoSalida):
        self.implementacion = implementacion
    
    @abstractmethod
    def mostrar(self):
        pass

# Abstracciones refinadas
class DocumentoTexto(Documento):
    def __init__(self, implementacion: DispositivoSalida, texto: str):
        super().__init__(implementacion)
        self.texto = texto
    
    def mostrar(self):
        return self.implementacion.mostrar(self.texto)

class DocumentoImagen(Documento):
    def __init__(self, implementacion: DispositivoSalida, ruta_imagen: str):
        super().__init__(implementacion)
        self.ruta_imagen = ruta_imagen
    
    def mostrar(self):
        return self.implementacion.mostrar(f"Imagen en {self.ruta_imagen}")

# Uso
pantalla = Pantalla()
impresora = Impresora()

doc_texto_pantalla = DocumentoTexto(pantalla, "Hola mundo")
doc_texto_impresora = DocumentoTexto(impresora, "Hola mundo")
doc_imagen_pantalla = DocumentoImagen(pantalla, "/img/foto.jpg")

print(doc_texto_pantalla.mostrar())    # Mostrando en pantalla: Hola mundo
print(doc_texto_impresora.mostrar())   # Imprimiendo: Hola mundo
print(doc_imagen_pantalla.mostrar())   # Mostrando en pantalla: Imagen en /img/foto.jpg
```

### Consideraciones
- Aumenta la extensibilidad: nuevas abstracciones e implementaciones pueden ser desarrolladas independientemente
- Oculta detalles de implementación al cliente
- Promueve el principio de responsabilidad única

## 3. Composite (Compuesto)

### Propósito
Componer objetos en estructuras de árbol para representar jerarquías parte-todo. Permite a los clientes tratar objetos individuales y composiciones de objetos de manera uniforme.

### Caso de uso: Carrito de compras con productos y combos en e-commerce
Supón que tu tienda online permite a los usuarios agregar productos simples y combos (agrupaciones de productos) al carrito. Quieres que el sistema trate ambos casos de la misma forma, para calcular el precio total, mostrar el contenido, etc.

---

### Problema (antes de Composite)

```python
class Producto:
    def __init__(self, nombre, precio):
        self.nombre = nombre
        self.precio = precio

# Si quieres combos, tienes que tratarlos aparte
class Combo:
    def __init__(self, nombre, productos):
        self.nombre = nombre
        self.productos = productos

# Calcular el total requiere lógica especial para combos
productos = [Producto("camisa", 20), Producto("pantalón", 30)]
combo = Combo("Pack verano", [Producto("gafas", 15), Producto("gorra", 10)])
carrito = productos + [combo]

total = 0
for item in carrito:
    if isinstance(item, Producto):
        total += item.precio
    elif isinstance(item, Combo):
        for prod in item.productos:
            total += prod.precio
```

**¿Qué está mal aquí?**
- El código del carrito se complica con condicionales.
- Si agregas nuevos tipos de agrupaciones, tienes que modificar la lógica.
- No puedes tratar productos y combos de forma uniforme.

---

### Solución: Aplicando Composite

```python
from abc import ABC, abstractmethod

class ItemCarrito(ABC):
    @abstractmethod
    def precio(self):
        pass
    @abstractmethod
    def mostrar(self, nivel=0):
        pass

class Producto(ItemCarrito):
    def __init__(self, nombre, precio):
        self.nombre = nombre
        self._precio = precio
    def precio(self):
        return self._precio
    def mostrar(self, nivel=0):
        print("  " * nivel + f"Producto: {self.nombre} (${self._precio})")

class Combo(ItemCarrito):
    def __init__(self, nombre):
        self.nombre = nombre
        self.items = []
    def agregar(self, item):
        self.items.append(item)
    def precio(self):
        return sum(item.precio() for item in self.items)
    def mostrar(self, nivel=0):
        print("  " * nivel + f"Combo: {self.nombre}")
        for item in self.items:
            item.mostrar(nivel + 1)

# Uso
camisa = Producto("camisa", 20)
pantalon = Producto("pantalón", 30)
gafas = Producto("gafas", 15)
gorra = Producto("gorra", 10)

combo_verano = Combo("Pack verano")
combo_verano.agregar(gafas)
combo_verano.agregar(gorra)

carrito = [camisa, pantalon, combo_verano]

total = sum(item.precio() for item in carrito)
print(f"Total: ${total}")

print("Contenido del carrito:")
for item in carrito:
    item.mostrar()
```

**¿Qué mejoró?**
- Puedes tratar productos y combos de la misma forma.
- El código es más limpio y fácil de extender.
- Puedes anidar combos dentro de combos si lo necesitas.

---

### Checklist para aplicar Composite
- [ ] ¿Tienes objetos individuales y agrupaciones que quieres tratar igual?
- [ ] ¿Quieres evitar condicionales para distinguir tipos?
- [ ] ¿Necesitas estructuras jerárquicas (parte-todo)?
- [ ] ¿Quieres que el sistema sea fácil de extender con nuevos tipos de agrupaciones?

## 4. Decorator (Decorador)

### Propósito
Añadir responsabilidades adicionales a un objeto dinámicamente. Los decoradores proporcionan una alternativa flexible a la herencia para extender la funcionalidad.

### Caso de uso: Añadir funcionalidades extra a un pedido en e-commerce
Supón que tu tienda online permite a los usuarios agregar servicios extra a su pedido: seguimiento premium, seguro, envoltorio de regalo, etc. Quieres que los usuarios puedan combinar estos extras de forma flexible, sin crear una clase diferente para cada combinación.

---

### Problema (antes de Decorator)

```python
class Pedido:
    def __init__(self, descripcion):
        self.descripcion = descripcion
    def procesar(self):
        print(f"Procesando pedido: {self.descripcion}")

class PedidoConSeguimiento(Pedido):
    def procesar(self):
        super().procesar()
        print("Agregando seguimiento premium")

class PedidoConSeguro(Pedido):
    def procesar(self):
        super().procesar()
        print("Agregando seguro")

# Si quieres combinar extras, tienes que crear más subclases
class PedidoConSeguimientoYSeguro(Pedido):
    def procesar(self):
        super().procesar()
        print("Agregando seguimiento premium")
        print("Agregando seguro")
```

**¿Qué está mal aquí?**
- El número de subclases crece rápidamente si hay muchas combinaciones.
- Es difícil mantener y extender el sistema.
- No puedes añadir o quitar extras dinámicamente.

---

### Solución: Aplicando Decorator

```python
from abc import ABC, abstractmethod

class Pedido(ABC):
    @abstractmethod
    def procesar(self):
        pass

class PedidoBase(Pedido):
    def __init__(self, descripcion):
        self.descripcion = descripcion
    def procesar(self):
        print(f"Procesando pedido: {self.descripcion}")

class DecoradorPedido(Pedido):
    def __init__(self, pedido: Pedido):
        self.pedido = pedido
    def procesar(self):
        self.pedido.procesar()

class SeguimientoPremium(DecoradorPedido):
    def procesar(self):
        super().procesar()
        print("Agregando seguimiento premium")

class SeguroEnvio(DecoradorPedido):
    def procesar(self):
        super().procesar()
        print("Agregando seguro de envío")

class EnvoltorioRegalo(DecoradorPedido):
    def procesar(self):
        super().procesar()
        print("Agregando envoltorio de regalo")

# Uso
pedido = PedidoBase("Pedido #1234")
pedido = SeguimientoPremium(pedido)
pedido = SeguroEnvio(pedido)
pedido = EnvoltorioRegalo(pedido)
pedido.procesar()
# Procesando pedido: Pedido #1234
# Agregando seguimiento premium
# Agregando seguro de envío
# Agregando envoltorio de regalo
```

**¿Qué mejoró?**
- Puedes añadir o quitar extras dinámicamente.
- No necesitas crear una subclase para cada combinación.
- El código es más flexible y fácil de mantener.

---

### Checklist para aplicar Decorator
- [ ] ¿Quieres añadir funcionalidades extra a objetos individuales?
- [ ] ¿Quieres evitar una explosión de subclases?
- [ ] ¿Necesitas añadir o quitar responsabilidades en tiempo de ejecución?
- [ ] ¿Quieres mantener el sistema flexible y extensible?

## 5. Facade (Fachada)

### Propósito
Proporcionar una interfaz unificada a un conjunto de interfaces en un subsistema. Define una interfaz de alto nivel que hace que el subsistema sea más fácil de usar.

### Caso de uso: Simplificar el proceso de checkout en e-commerce
Supón que tu tienda online tiene subsistemas separados para procesar pagos, gestionar envíos y generar facturas. El proceso de checkout es complejo y requiere coordinar varias operaciones. Quieres que el frontend o el backend de la app pueda hacer un solo llamado para realizar el checkout completo, sin preocuparse por los detalles internos.

---

### Problema (antes de Facade)

```python
class ProcesadorPagos:
    def pagar(self, pedido, tarjeta):
        print(f"Pagando {pedido} con tarjeta {tarjeta}")

class GestorEnvios:
    def enviar(self, pedido, direccion):
        print(f"Enviando {pedido} a {direccion}")

class GeneradorFacturas:
    def facturar(self, pedido):
        print(f"Generando factura para {pedido}")

# El cliente debe coordinar todo manualmente
procesador = ProcesadorPagos()
gestor = GestorEnvios()
generador = GeneradorFacturas()

pedido = "Pedido #1234"
procesador.pagar(pedido, "1234-5678-9012-3456")
gestor.enviar(pedido, "Calle Falsa 123")
generador.facturar(pedido)
```

**¿Qué está mal aquí?**
- El cliente debe conocer y coordinar todos los subsistemas.
- Si cambia la lógica interna, hay que modificar el cliente.
- El código es difícil de mantener y propenso a errores.

---

### Solución: Aplicando Facade

```python
class CheckoutFacade:
    def __init__(self):
        self.procesador = ProcesadorPagos()
        self.gestor = GestorEnvios()
        self.generador = GeneradorFacturas()
    def realizar_checkout(self, pedido, tarjeta, direccion):
        self.procesador.pagar(pedido, tarjeta)
        self.gestor.enviar(pedido, direccion)
        self.generador.facturar(pedido)
        print("Checkout completo!")

# Uso
checkout = CheckoutFacade()
checkout.realizar_checkout("Pedido #1234", "1234-5678-9012-3456", "Calle Falsa 123")
# Pagando Pedido #1234 con tarjeta 1234-5678-9012-3456
# Enviando Pedido #1234 a Calle Falsa 123
# Generando factura para Pedido #1234
# Checkout completo!
```

**¿Qué mejoró?**
- El cliente solo interactúa con una interfaz simple.
- Los detalles internos están encapsulados.
- El sistema es más fácil de mantener y extender.

---

### Checklist para aplicar Facade
- [ ] ¿Tienes un subsistema complejo con muchas operaciones?
- [ ] ¿Quieres simplificar la interacción para el cliente?
- [ ] ¿Quieres desacoplar el cliente de los detalles internos?
- [ ] ¿Necesitas una interfaz de alto nivel para coordinar varias operaciones?

## 6. Proxy

### Propósito
Proporcionar un sustituto o marcador de posición para otro objeto para controlar el acceso a él.

### Caso de uso: Carga diferida de imágenes de productos en una galería de e-commerce
Supón que tu tienda online muestra una galería con muchas imágenes de productos. Cargar todas las imágenes grandes de inmediato puede hacer que la página sea lenta. Quieres que las imágenes solo se carguen cuando el usuario realmente las ve (lazy loading), pero sin cambiar la forma en que el resto del sistema accede a ellas.

---

### Problema (antes de Proxy)

```python
class ImagenProducto:
    def __init__(self, archivo):
        print(f"Cargando imagen {archivo}...")
        self.archivo = archivo
    def mostrar(self):
        print(f"Mostrando imagen {self.archivo}")

# Todas las imágenes se cargan al crear la galería
imagenes = [ImagenProducto(f"img_{i}.jpg") for i in range(1, 4)]
for img in imagenes:
    img.mostrar()
```

**¿Qué está mal aquí?**
- Todas las imágenes se cargan aunque el usuario no las vea.
- El tiempo de carga inicial es alto.
- Se consumen recursos innecesariamente.

---

### Solución: Aplicando Proxy

```python
from abc import ABC, abstractmethod
import time

class Imagen(ABC):
    @abstractmethod
    def mostrar(self):
        pass

class ImagenReal(Imagen):
    def __init__(self, archivo):
        print(f"Cargando imagen {archivo}...")
        time.sleep(1)  # Simula carga pesada
        self.archivo = archivo
    def mostrar(self):
        print(f"Mostrando imagen {self.archivo}")

class ProxyImagen(Imagen):
    def __init__(self, archivo):
        self.archivo = archivo
        self.imagen_real = None
    def mostrar(self):
        if self.imagen_real is None:
            self.imagen_real = ImagenReal(self.archivo)
        self.imagen_real.mostrar()

# Uso
imagenes = [ProxyImagen(f"img_{i}.jpg") for i in range(1, 4)]
print("Galería iniciada, pero las imágenes aún no se han cargado.")

# Solo se carga la imagen cuando se muestra
imagenes[0].mostrar()  # Carga y muestra img_1.jpg
imagenes[0].mostrar()  # Solo muestra, no vuelve a cargar
imagenes[2].mostrar()  # Carga y muestra img_3.jpg
```

**¿Qué mejoró?**
- Las imágenes solo se cargan cuando se necesitan.
- El tiempo de carga inicial es bajo.
- Se ahorran recursos y la experiencia de usuario mejora.

---

### Checklist para aplicar Proxy
- [ ] ¿Quieres controlar el acceso a un objeto costoso o sensible?
- [ ] ¿Necesitas cargar recursos solo cuando se usan realmente?
- [ ] ¿Quieres añadir lógica extra (caché, control de acceso, logging) sin cambiar el objeto real?
- [ ] ¿Quieres mantener la misma interfaz para el cliente?

## 7. Flyweight (Peso Ligero)

### Propósito
Utilizar compartición para soportar grandes cantidades de objetos de granularidad fina eficientemente.

### Caso de uso: Compartir atributos comunes entre productos en un catálogo grande de e-commerce
Supón que tu tienda online tiene miles de productos, muchos de los cuales comparten atributos como color, talla, marca o etiquetas. Si cada producto almacena una copia de estos atributos, el consumo de memoria puede ser muy alto. Quieres compartir estos datos entre productos que los tengan en común.

---

### Problema (antes de Flyweight)

```python
class Producto:
    def __init__(self, nombre, color, talla, marca):
        self.nombre = nombre
        self.color = color
        self.talla = talla
        self.marca = marca

# Cada producto almacena su propia copia de los atributos
productos = [
    Producto("Camiseta A", "rojo", "M", "Nike"),
    Producto("Camiseta B", "rojo", "M", "Nike"),
    Producto("Camiseta C", "azul", "L", "Adidas"),
]
```

**¿Qué está mal aquí?**
- Se duplican los mismos datos muchas veces en memoria.
- El sistema es ineficiente si hay miles de productos similares.
- No se aprovecha la compartición de datos comunes.

---

### Solución: Aplicando Flyweight

```python
class AtributosCompartidos:
    def __init__(self, color, talla, marca):
        self.color = color
        self.talla = talla
        self.marca = marca

class FlyweightFactory:
    _flyweights = {}
    @classmethod
    def obtener(cls, color, talla, marca):
        clave = (color, talla, marca)
        if clave not in cls._flyweights:
            cls._flyweights[clave] = AtributosCompartidos(color, talla, marca)
        return cls._flyweights[clave]

class Producto:
    def __init__(self, nombre, atributos):
        self.nombre = nombre
        self.atributos = atributos
    def mostrar(self):
        print(f"{self.nombre} - Color: {self.atributos.color}, Talla: {self.atributos.talla}, Marca: {self.atributos.marca}")

# Uso
productos = [
    Producto("Camiseta A", FlyweightFactory.obtener("rojo", "M", "Nike")),
    Producto("Camiseta B", FlyweightFactory.obtener("rojo", "M", "Nike")),
    Producto("Camiseta C", FlyweightFactory.obtener("azul", "L", "Adidas")),
]

for p in productos:
    p.mostrar()

print(f"Atributos únicos en memoria: {len(FlyweightFactory._flyweights)}")
```

**¿Qué mejoró?**
- Los atributos comunes se comparten entre productos.
- El consumo de memoria es mucho menor.
- El sistema es más eficiente y escalable.

---

### Checklist para aplicar Flyweight
- [ ] ¿Tienes muchos objetos similares que comparten datos?
- [ ] ¿Quieres reducir el consumo de memoria?
- [ ] ¿Los datos compartidos pueden ser inmutables?
- [ ] ¿Necesitas manejar grandes volúmenes de objetos eficientemente?

## Selección del patrón estructural adecuado

Para elegir el patrón estructural más apropiado, considera:

1. **Adapter**: Usar cuando necesites hacer trabajar juntas interfaces incompatibles
2. **Bridge**: Utilizar cuando quieras separar la abstracción de su implementación
3. **Composite**: Ideal para estructuras jerárquicas donde los clientes tratan colecciones y elementos individuales de manera uniforme
4. **Decorator**: Perfecto para añadir responsabilidades a objetos dinámicamente sin afectar a otros objetos
5. **Facade**: Usar para proporcionar una interfaz simplificada a un subsistema complejo
6. **Proxy**: Aplicar cuando necesites un objeto intermediario para controlar o gestionar el acceso al objeto real
7. **Flyweight**: Utilizar cuando necesites manejar eficientemente un gran número de objetos con estado compartido

Cada patrón estructural resuelve diferentes problemas de composición y relación entre objetos y clases, por lo que es importante entender bien el problema específico antes de seleccionar uno. 