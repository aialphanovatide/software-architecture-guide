# Patrones Creacionales

Los patrones creacionales proporcionan diferentes mecanismos para crear objetos, lo que aumenta la flexibilidad y la reutilización del código existente. Estos patrones abstraen el proceso de instanciación y ayudan a que un sistema sea independiente de cómo se crean, componen y representan sus objetos.

## 1. Singleton

### Propósito
Garantizar que una clase tenga una única instancia y proporcionar un punto de acceso global a ella.

### Caso de uso: Conexión a base de datos
Supón que tienes una aplicación SaaS y necesitas que toda la app use una sola conexión a la base de datos para evitar problemas de recursos y mantener la eficiencia.

---

### Problema (antes de Singleton)

```python
class ConexionDB:
    def __init__(self):
        print("Conectando a la base de datos...")

# Cada vez que creas una instancia, se abre una nueva conexión
conn1 = ConexionDB()  # Conectando a la base de datos...
conn2 = ConexionDB()  # Conectando a la base de datos...
```

**¿Qué está mal aquí?**
- Se crean múltiples conexiones innecesarias.
- Puede saturar la base de datos y consumir recursos.
- No hay un punto de acceso global ni control.

---

### Solución: Aplicando Singleton

```python
class ConexionDB:
    _instancia = None

    def __new__(cls):
        if cls._instancia is None:
            print("Conectando a la base de datos...")
            cls._instancia = super().__new__(cls)
        return cls._instancia

    def query(self, sql):
        print(f"Ejecutando: {sql}")

# Uso
conn1 = ConexionDB()  # Conectando a la base de datos...
conn2 = ConexionDB()  # No vuelve a conectar
print(conn1 is conn2)  # True
conn1.query("SELECT * FROM users;")
```

**¿Qué mejoró?**
- Solo se crea una conexión a la base de datos.
- Todos los módulos usan la misma instancia.
- Mejor uso de recursos y control global.

---

### Checklist para aplicar Singleton
- [ ] ¿Solo debe existir una instancia de la clase?
- [ ] ¿Necesitas un punto de acceso global?
- [ ] ¿El recurso es costoso o compartido (DB, logger, etc.)?
- [ ] ¿Evitas crear instancias adicionales accidentalmente?

---

### Consideraciones
- Puede dificultar las pruebas unitarias
- Viola el principio de responsabilidad única
- Es esencialmente un global state con todos sus inconvenientes
- En ambientes concurrentes, requiere sincronización

## 2. Factory Method

### Propósito
Definir una interfaz para crear un objeto, pero dejar que las subclases decidan qué clase instanciar.

### Caso de uso: Notificaciones en un e-commerce
Supón que tu tienda online quiere enviar notificaciones a los usuarios por diferentes canales: email, SMS o push. Cada canal tiene su propia lógica, pero el sistema debe ser fácil de extender si agregas nuevos canales.

---

### Problema (antes de Factory Method)

```python
class Notificador:
    def enviar(self, tipo, mensaje):
        if tipo == "email":
            print(f"Enviando email: {mensaje}")
        elif tipo == "sms":
            print(f"Enviando SMS: {mensaje}")
        elif tipo == "push":
            print(f"Enviando push: {mensaje}")
        # Si agregas un nuevo canal, tienes que modificar esta clase
```

**¿Qué está mal aquí?**
- Cada vez que agregas un nuevo canal, tienes que modificar la clase.
- El código se llena de condicionales y es difícil de mantener.
- No puedes cambiar la lógica de notificación en tiempo de ejecución.

---

### Solución: Aplicando Factory Method

```python
from abc import ABC, abstractmethod

# Producto abstracto
class Notificacion(ABC):
    @abstractmethod
    def enviar(self, mensaje):
        pass

# Productos concretos
class NotificacionEmail(Notificacion):
    def enviar(self, mensaje):
        print(f"Enviando email: {mensaje}")

class NotificacionSMS(Notificacion):
    def enviar(self, mensaje):
        print(f"Enviando SMS: {mensaje}")

class NotificacionPush(Notificacion):
    def enviar(self, mensaje):
        print(f"Enviando push: {mensaje}")

# Creador abstracto
class CreadorNotificacion(ABC):
    @abstractmethod
    def factory_method(self):
        pass
    def notificar(self, mensaje):
        notificacion = self.factory_method()
        notificacion.enviar(mensaje)

# Creadores concretos
class CreadorEmail(CreadorNotificacion):
    def factory_method(self):
        return NotificacionEmail()

class CreadorSMS(CreadorNotificacion):
    def factory_method(self):
        return NotificacionSMS()

class CreadorPush(CreadorNotificacion):
    def factory_method(self):
        return NotificacionPush()

# Uso
creador = CreadorEmail()
creador.notificar("Tu pedido fue enviado")  # Enviando email: Tu pedido fue enviado

creador = CreadorSMS()
creador.notificar("Tu pedido fue entregado")  # Enviando SMS: Tu pedido fue entregado

creador = CreadorPush()
creador.notificar("¡Tienes una nueva oferta!")  # Enviando push: ¡Tienes una nueva oferta!
```

**¿Qué mejoró?**
- Puedes agregar nuevos canales sin modificar el código existente.
- El código es más limpio y fácil de mantener.
- Puedes cambiar la lógica de notificación en tiempo de ejecución.

---

### Checklist para aplicar Factory Method
- [ ] ¿Tienes diferentes formas de crear un objeto según el contexto?
- [ ] ¿Quieres evitar condicionales grandes y repetitivos?
- [ ] ¿Necesitas que el sistema sea fácil de extender con nuevos tipos de objetos?
- [ ] ¿Quieres delegar la creación de objetos a subclases?

## 3. Abstract Factory

### Propósito
Proporcionar una interfaz para crear familias de objetos relacionados o dependientes sin especificar sus clases concretas.

### Caso de uso: Interfaces de usuario para web y móvil en una app de pagos
Supón que tu app de pagos necesita mostrar botones y formularios adaptados a web y móvil. Quieres que el sistema sea fácil de extender si agregas nuevas plataformas.

---

### Problema (antes de Abstract Factory)

```python
class UIFactory:
    def crear_boton(self, plataforma):
        if plataforma == "web":
            return "Botón web"
        elif plataforma == "movil":
            return "Botón móvil"
    def crear_formulario(self, plataforma):
        if plataforma == "web":
            return "Formulario web"
        elif plataforma == "movil":
            return "Formulario móvil"
# Si agregas una nueva plataforma, tienes que modificar la clase
```

**¿Qué está mal aquí?**
- Cada vez que agregas una nueva plataforma, tienes que modificar la clase.
- El código se llena de condicionales y es difícil de mantener.
- No puedes cambiar la familia de componentes en tiempo de ejecución.

---

### Solución: Aplicando Abstract Factory

```python
from abc import ABC, abstractmethod

# Productos abstractos
class Boton(ABC):
    @abstractmethod
    def render(self):
        pass

class Formulario(ABC):
    @abstractmethod
    def render(self):
        pass

# Productos concretos para web
class BotonWeb(Boton):
    def render(self):
        return "Botón web"

class FormularioWeb(Formulario):
    def render(self):
        return "Formulario web"

# Productos concretos para móvil
class BotonMovil(Boton):
    def render(self):
        return "Botón móvil"

class FormularioMovil(Formulario):
    def render(self):
        return "Formulario móvil"

# Fábrica abstracta
class UIFactory(ABC):
    @abstractmethod
    def crear_boton(self):
        pass
    @abstractmethod
    def crear_formulario(self):
        pass

# Fábricas concretas
class WebFactory(UIFactory):
    def crear_boton(self):
        return BotonWeb()
    def crear_formulario(self):
        return FormularioWeb()

class MovilFactory(UIFactory):
    def crear_boton(self):
        return BotonMovil()
    def crear_formulario(self):
        return FormularioMovil()

# Cliente
class AppPagos:
    def __init__(self, factory: UIFactory):
        self.boton = factory.crear_boton()
        self.formulario = factory.crear_formulario()
    def mostrar_ui(self):
        print(self.boton.render())
        print(self.formulario.render())

# Uso
app_web = AppPagos(WebFactory())
app_web.mostrar_ui()  # Botón web, Formulario web

app_movil = AppPagos(MovilFactory())
app_movil.mostrar_ui()  # Botón móvil, Formulario móvil
```

**¿Qué mejoró?**
- Puedes agregar nuevas plataformas sin modificar el código existente.
- El código es más limpio y fácil de mantener.
- Puedes cambiar la familia de componentes en tiempo de ejecución.

---

### Checklist para aplicar Abstract Factory
- [ ] ¿Necesitas crear familias de objetos relacionados?
- [ ] ¿Quieres evitar condicionales grandes y repetitivos?
- [ ] ¿El sistema debe ser fácil de extender con nuevas familias de productos?
- [ ] ¿Quieres desacoplar la creación de objetos de su uso?

## 4. Builder

### Propósito
Separar la construcción de un objeto complejo de su representación, de modo que el mismo proceso de construcción pueda crear diferentes representaciones.

### Caso de uso: Construcción de órdenes de compra personalizadas en un e-commerce
Supón que tu tienda online permite a los usuarios crear órdenes de compra con diferentes opciones: productos, cupones, envío exprés, regalo, etc. El proceso puede ser complejo y variar según el cliente.

---

### Problema (antes de Builder)

```python
class Orden:
    def __init__(self, productos, cupon=None, envio=None, regalo=False):
        self.productos = productos
        self.cupon = cupon
        self.envio = envio
        self.regalo = regalo

# Crear una orden con muchas combinaciones puede ser confuso
orden1 = Orden(["camisa", "pantalón"])
orden2 = Orden(["camisa"], cupon="DESCUENTO10", envio="exprés", regalo=True)
```

**¿Qué está mal aquí?**
- El constructor tiene muchos parámetros opcionales.
- Es fácil cometer errores al pasar los argumentos.
- El código es difícil de leer y mantener.

---

### Solución: Aplicando Builder

```python
class Orden:
    def __init__(self):
        self.productos = []
        self.cupon = None
        self.envio = None
        self.regalo = False
    def __str__(self):
        return f"Orden: productos={self.productos}, cupon={self.cupon}, envio={self.envio}, regalo={self.regalo}"

class OrdenBuilder:
    def __init__(self):
        self.orden = Orden()
    def agregar_producto(self, producto):
        self.orden.productos.append(producto)
        return self
    def con_cupon(self, cupon):
        self.orden.cupon = cupon
        return self
    def con_envio(self, tipo):
        self.orden.envio = tipo
        return self
    def como_regalo(self):
        self.orden.regalo = True
        return self
    def build(self):
        return self.orden

# Uso
builder = OrdenBuilder()
orden1 = builder.agregar_producto("camisa").agregar_producto("pantalón").build()
orden2 = builder.agregar_producto("camisa").con_cupon("DESCUENTO10").con_envio("exprés").como_regalo().build()

print(orden1)  # Orden: productos=['camisa', 'pantalón'], cupon=None, envio=None, regalo=False
print(orden2)  # Orden: productos=['camisa', 'pantalón', 'camisa'], cupon=DESCUENTO10, envio=exprés, regalo=True
```

**¿Qué mejoró?**
- El proceso de construcción es claro y flexible.
- Puedes crear diferentes combinaciones fácilmente.
- El código es más legible y menos propenso a errores.

---

### Checklist para aplicar Builder
- [ ] ¿El objeto a construir es complejo y tiene muchas opciones?
- [ ] ¿Quieres evitar constructores con muchos parámetros?
- [ ] ¿Necesitas diferentes representaciones del mismo objeto?
- [ ] ¿Quieres que el proceso de construcción sea claro y paso a paso?

## 5. Prototype

### Propósito
Permite crear nuevos objetos copiando un objeto existente, conocido como prototipo.

### Caso de uso: Clonar plantillas de productos para vendedores en un marketplace
Supón que en un marketplace (tipo Mercado Libre) los vendedores pueden crear plantillas de productos y luego clonarlas para nuevos productos similares, ahorrando tiempo y evitando errores.

---

### Problema (antes de Prototype)

```python
class Producto:
    def __init__(self, nombre, precio, categoria, descripcion):
        self.nombre = nombre
        self.precio = precio
        self.categoria = categoria
        self.descripcion = descripcion

# Si quieres crear un producto similar, tienes que copiar todo manualmente
producto1 = Producto("Zapatillas", 100, "Calzado", "Zapatillas deportivas")
producto2 = Producto(producto1.nombre, producto1.precio, producto1.categoria, producto1.descripcion)
producto2.nombre = "Zapatillas edición limitada"
```

**¿Qué está mal aquí?**
- Copiar manualmente es propenso a errores.
- Si cambias la estructura de Producto, tienes que actualizar todos los lugares donde se copia.
- No es eficiente ni escalable.

---

### Solución: Aplicando Prototype

```python
import copy

class Producto:
    def __init__(self, nombre, precio, categoria, descripcion):
        self.nombre = nombre
        self.precio = precio
        self.categoria = categoria
        self.descripcion = descripcion
    def __str__(self):
        return f"Producto: {self.nombre}, Precio: {self.precio}, Categoría: {self.categoria}, Desc: {self.descripcion}"
    def clonar(self, **atributos):
        nuevo = copy.deepcopy(self)
        nuevo.__dict__.update(atributos)
        return nuevo

# Uso
plantilla = Producto("Zapatillas", 100, "Calzado", "Zapatillas deportivas")
producto1 = plantilla.clonar(nombre="Zapatillas edición limitada", precio=120)
producto2 = plantilla.clonar(nombre="Zapatillas niño", precio=80)

print(producto1)  # Producto: Zapatillas edición limitada, Precio: 120, Categoría: Calzado, Desc: Zapatillas deportivas
print(producto2)  # Producto: Zapatillas niño, Precio: 80, Categoría: Calzado, Desc: Zapatillas deportivas
```

**¿Qué mejoró?**
- Puedes clonar productos fácilmente y personalizarlos.
- Menos errores y código más limpio.
- Si cambias la estructura, solo actualizas la clase.

---

### Checklist para aplicar Prototype
- [ ] ¿Necesitas crear muchos objetos similares?
- [ ] ¿Quieres evitar copiar y pegar código?
- [ ] ¿El proceso de creación es costoso o complejo?
- [ ] ¿Quieres permitir la personalización rápida de objetos clonados?

## Selección del patrón creacional adecuado

Para elegir el patrón creacional más adecuado, considera:

1. **Singleton**: Usa cuando necesites exactamente una instancia compartida, pero ten cuidado con sus inconvenientes
2. **Factory Method**: Ideal cuando quieres encapsular la creación de objetos y permitir la extensibilidad por subclases
3. **Abstract Factory**: Útil para crear familias de objetos relacionados sin especificar sus clases concretas
4. **Builder**: Perfecto para objetos complejos con múltiples representaciones o cuando la construcción requiere muchos pasos
5. **Prototype**: Excelente cuando la clonación es más eficiente que la creación desde cero

Recuerda que los patrones no son mutuamente excluyentes y a menudo se combinan para resolver problemas más complejos. 