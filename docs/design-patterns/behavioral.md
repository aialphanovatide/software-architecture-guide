# Patrones de Comportamiento

Los patrones de comportamiento se centran en la comunicación efectiva y la asignación de responsabilidades entre objetos. Estos patrones abordan cómo los objetos interactúan y distribuyen responsabilidades entre sí.

## 1. Observer (Observador)

### Propósito
Definir una dependencia uno-a-muchos entre objetos para que cuando un objeto cambie de estado, todos sus dependientes sean notificados y actualizados automáticamente.

### Cuándo usarlo
- Cuando un cambio en un objeto requiere cambiar otros objetos y no sabes cuántos objetos necesitan cambiar
- Cuando un objeto debe notificar a otros sin hacer suposiciones sobre quiénes son esos objetos
- Para implementar comunicación publicador-suscriptor

### Ejemplo en Python

```python
from abc import ABC, abstractmethod
from typing import List

# Sujeto
class Sujeto(ABC):
    @abstractmethod
    def agregar_observador(self, observador):
        pass
    
    @abstractmethod
    def eliminar_observador(self, observador):
        pass
    
    @abstractmethod
    def notificar(self):
        pass

# Observador
class Observador(ABC):
    @abstractmethod
    def actualizar(self, temperatura: float, humedad: float, presion: float):
        pass

# Sujeto concreto
class EstacionMeteorologica(Sujeto):
    def __init__(self):
        self._observadores: List[Observador] = []
        self._temperatura = 0.0
        self._humedad = 0.0
        self._presion = 0.0
    
    def agregar_observador(self, observador: Observador):
        if observador not in self._observadores:
            self._observadores.append(observador)
    
    def eliminar_observador(self, observador: Observador):
        self._observadores.remove(observador)
    
    def notificar(self):
        for observador in self._observadores:
            observador.actualizar(self._temperatura, self._humedad, self._presion)
    
    def establecer_mediciones(self, temperatura: float, humedad: float, presion: float):
        self._temperatura = temperatura
        self._humedad = humedad
        self._presion = presion
        self.notificar()

# Observadores concretos
class PantallaActual(Observador):
    def actualizar(self, temperatura: float, humedad: float, presion: float):
        print(f"Pantalla Actual - Temperatura: {temperatura}°C, Humedad: {humedad}%, Presión: {presion} hPa")

class RegistroEstadisticas(Observador):
    def __init__(self):
        self._max_temp = float('-inf')
        self._min_temp = float('inf')
    
    def actualizar(self, temperatura: float, humedad: float, presion: float):
        if temperatura > self._max_temp:
            self._max_temp = temperatura
        if temperatura < self._min_temp:
            self._min_temp = temperatura
        
        print(f"Estadísticas - Temperatura Máxima: {self._max_temp}°C, Temperatura Mínima: {self._min_temp}°C")

class PronosticoSimple(Observador):
    def actualizar(self, temperatura: float, humedad: float, presion: float):
        if presion < 1000:
            print("Pronóstico: Posibilidad de lluvia")
        else:
            print("Pronóstico: Clima estable")

# Uso
estacion = EstacionMeteorologica()

pantalla = PantallaActual()
estadisticas = RegistroEstadisticas()
pronostico = PronosticoSimple()

estacion.agregar_observador(pantalla)
estacion.agregar_observador(estadisticas)
estacion.agregar_observador(pronostico)

print("Primera medición:")
estacion.establecer_mediciones(25.5, 65.0, 1010.2)

print("\nSegunda medición:")
estacion.establecer_mediciones(26.8, 70.0, 990.5)
```

### Consideraciones
- Proporciona acoplamiento flexible entre sujetos y observadores
- Soporta comunicación broadcast (uno a muchos)
- Puede conducir a actualizaciones en cascada inesperadas

## 2. Strategy (Estrategia)

### Propósito
Definir una familia de algoritmos, encapsular cada uno, y hacerlos intercambiables. Permite que el algoritmo varíe independientemente de los clientes que lo utilizan.

### Cuándo usarlo
- Cuando necesitas diferentes variantes de un algoritmo
- Para aislar la lógica del negocio de los detalles de implementación del algoritmo
- Cuando una clase tiene múltiples comportamientos que aparecen como múltiples declaraciones condicionales

### Ejemplo en Python

```python
from abc import ABC, abstractmethod

# Estrategia
class EstrategiaPago(ABC):
    @abstractmethod
    def pagar(self, cantidad: float) -> str:
        pass

# Estrategias concretas
class PagoTarjetaCredito(EstrategiaPago):
    def __init__(self, numero: str, nombre: str, fecha_expiracion: str, cvv: str):
        self.numero = numero
        self.nombre = nombre
        self.fecha_expiracion = fecha_expiracion
        self.cvv = cvv
    
    def pagar(self, cantidad: float) -> str:
        return f"Pago de ${cantidad} realizado con tarjeta de crédito terminada en {self.numero[-4:]}"

class PagoPayPal(EstrategiaPago):
    def __init__(self, email: str, password: str):
        self.email = email
        self.password = password
    
    def pagar(self, cantidad: float) -> str:
        return f"Pago de ${cantidad} realizado con PayPal usando la cuenta {self.email}"

class PagoTransferenciaBancaria(EstrategiaPago):
    def __init__(self, cuenta_bancaria: str):
        self.cuenta_bancaria = cuenta_bancaria
    
    def pagar(self, cantidad: float) -> str:
        return f"Pago de ${cantidad} realizado mediante transferencia a la cuenta {self.cuenta_bancaria}"

# Contexto
class CarritoCompra:
    def __init__(self):
        self.items = []
        self.estrategia_pago = None
    
    def agregar_item(self, item, precio):
        self.items.append({"item": item, "precio": precio})
    
    def calcular_total(self):
        return sum(item["precio"] for item in self.items)
    
    def establecer_estrategia_pago(self, estrategia_pago: EstrategiaPago):
        self.estrategia_pago = estrategia_pago
    
    def pagar(self):
        if not self.estrategia_pago:
            raise Exception("No se ha establecido una estrategia de pago")
        
        total = self.calcular_total()
        return self.estrategia_pago.pagar(total)

# Uso
carrito = CarritoCompra()
carrito.agregar_item("Laptop", 1200.0)
carrito.agregar_item("Auriculares", 100.0)
carrito.agregar_item("Mouse", 50.0)

print(f"Total a pagar: ${carrito.calcular_total()}")

# El cliente decide pagar con tarjeta de crédito
carrito.establecer_estrategia_pago(PagoTarjetaCredito("1234567890123456", "Juan Pérez", "12/25", "123"))
print(carrito.pagar())

# O podría pagar con PayPal
carrito.establecer_estrategia_pago(PagoPayPal("juan.perez@example.com", "password"))
print(carrito.pagar())

# O podría pagar con transferencia bancaria
carrito.establecer_estrategia_pago(PagoTransferenciaBancaria("ES1234567890"))
print(carrito.pagar())
```

### Consideraciones
- Facilita el intercambio de algoritmos en tiempo de ejecución
- Elimina declaraciones condicionales
- Proporciona alternativas a la herencia para variar comportamientos
- Puede introducir objetos adicionales

## 3. Command (Comando)

### Propósito
Encapsular una solicitud como un objeto, permitiendo parametrizar clientes con diferentes solicitudes, encolar o registrar solicitudes, y soportar operaciones que se pueden deshacer.

### Cuándo usarlo
- Para parametrizar objetos con operaciones
- Para encolar, programar o ejecutar operaciones remotamente
- Para implementar operaciones que se pueden deshacer
- Para estructurar sistemas basados en operaciones de alto nivel construidas con operaciones primitivas

### Ejemplo en Python

```python
from abc import ABC, abstractmethod
from typing import List

# Comando
class Comando(ABC):
    @abstractmethod
    def ejecutar(self):
        pass
    
    @abstractmethod
    def deshacer(self):
        pass

# Receptor
class Editor:
    def __init__(self):
        self.texto = ""
        self.posicion_cursor = 0
    
    def insertar_texto(self, texto):
        # Insertar texto en la posición actual del cursor
        self.texto = self.texto[:self.posicion_cursor] + texto + self.texto[self.posicion_cursor:]
        self.posicion_cursor += len(texto)
    
    def eliminar_texto(self, longitud):
        # Eliminar texto desde la posición actual del cursor
        texto_eliminado = self.texto[self.posicion_cursor:self.posicion_cursor + longitud]
        self.texto = self.texto[:self.posicion_cursor] + self.texto[self.posicion_cursor + longitud:]
        return texto_eliminado
    
    def mover_cursor(self, posicion):
        # Mover el cursor a una posición específica
        if 0 <= posicion <= len(self.texto):
            self.posicion_cursor = posicion
    
    def obtener_estado(self):
        return f"Texto: '{self.texto}', Cursor en: {self.posicion_cursor}"

# Comandos concretos
class ComandoInsertar(Comando):
    def __init__(self, editor: Editor, texto: str):
        self.editor = editor
        self.texto = texto
        self.posicion_anterior = None
    
    def ejecutar(self):
        self.posicion_anterior = self.editor.posicion_cursor
        self.editor.insertar_texto(self.texto)
    
    def deshacer(self):
        self.editor.mover_cursor(self.posicion_anterior)
        self.editor.eliminar_texto(len(self.texto))

class ComandoEliminar(Comando):
    def __init__(self, editor: Editor, longitud: int):
        self.editor = editor
        self.longitud = longitud
        self.texto_eliminado = None
        self.posicion_anterior = None
    
    def ejecutar(self):
        self.posicion_anterior = self.editor.posicion_cursor
        self.texto_eliminado = self.editor.eliminar_texto(self.longitud)
    
    def deshacer(self):
        self.editor.mover_cursor(self.posicion_anterior)
        self.editor.insertar_texto(self.texto_eliminado)

class ComandoMoverCursor(Comando):
    def __init__(self, editor: Editor, posicion: int):
        self.editor = editor
        self.posicion = posicion
        self.posicion_anterior = None
    
    def ejecutar(self):
        self.posicion_anterior = self.editor.posicion_cursor
        self.editor.mover_cursor(self.posicion)
    
    def deshacer(self):
        self.editor.mover_cursor(self.posicion_anterior)

# Invocador (con historial)
class Historial:
    def __init__(self):
        self._comandos: List[Comando] = []
        self._indice = -1
    
    def ejecutar(self, comando: Comando):
        # Si estamos en medio del historial, eliminar los comandos futuros
        if self._indice < len(self._comandos) - 1:
            self._comandos = self._comandos[:self._indice + 1]
        
        # Ejecutar y guardar el comando
        comando.ejecutar()
        self._comandos.append(comando)
        self._indice += 1
    
    def deshacer(self):
        if self._indice >= 0:
            comando = self._comandos[self._indice]
            comando.deshacer()
            self._indice -= 1
            return True
        return False
    
    def rehacer(self):
        if self._indice < len(self._comandos) - 1:
            self._indice += 1
            comando = self._comandos[self._indice]
            comando.ejecutar()
            return True
        return False

# Uso
editor = Editor()
historial = Historial()

# Insertar texto
historial.ejecutar(ComandoInsertar(editor, "Hola "))
print(editor.obtener_estado())  # Texto: 'Hola ', Cursor en: 5

# Mover cursor
historial.ejecutar(ComandoMoverCursor(editor, 0))
print(editor.obtener_estado())  # Texto: 'Hola ', Cursor en: 0

# Insertar más texto
historial.ejecutar(ComandoInsertar(editor, "¡"))
print(editor.obtener_estado())  # Texto: '¡Hola ', Cursor en: 1

# Mover cursor al final
historial.ejecutar(ComandoMoverCursor(editor, 6))
print(editor.obtener_estado())  # Texto: '¡Hola ', Cursor en: 6

# Insertar más texto
historial.ejecutar(ComandoInsertar(editor, "Mundo!"))
print(editor.obtener_estado())  # Texto: '¡Hola Mundo!', Cursor en: 12

# Deshacer las últimas tres acciones
print("\nDeshaciendo...")
historial.deshacer()
print(editor.obtener_estado())
historial.deshacer()
print(editor.obtener_estado())
historial.deshacer()
print(editor.obtener_estado())

# Rehacer una acción
print("\nRehaciendo...")
historial.rehacer()
print(editor.obtener_estado())
```

### Consideraciones
- Desacopla el objeto que invoca la operación del que sabe cómo realizarla
- Permite crear secuencias de comandos complejas
- Facilita la implementación de características como deshacer/rehacer
- Puede llevar a un gran número de clases pequeñas

## 4. Template Method (Método Plantilla)

### Propósito
Definir el esqueleto de un algoritmo en una operación, aplazando algunos pasos a las subclases. Permite que las subclases redefinan ciertos pasos del algoritmo sin cambiar su estructura.

### Cuándo usarlo
- Para implementar las partes invariantes de un algoritmo una vez y dejar que las subclases implementen el comportamiento variable
- Cuando el comportamiento común entre subclases debe ser factorizado y localizado en una clase común
- Para controlar las extensiones de subclases

### Ejemplo en Python

```python
from abc import ABC, abstractmethod

# Clase abstracta con el método plantilla
class ProcesadorDocumento(ABC):
    # Método plantilla
    def procesar(self, documento):
        self.abrir_documento(documento)
        self.analizar_contenido(documento)
        self.verificar_formato()
        self.procesar_contenido()
        if self.requiere_firmas():
            self.verificar_firmas()
        self.guardar_documento()
        self.cerrar_documento()
    
    # Métodos abstractos que las subclases deben implementar
    @abstractmethod
    def analizar_contenido(self, documento):
        pass
    
    @abstractmethod
    def procesar_contenido(self):
        pass
    
    # Métodos con implementación predeterminada
    def abrir_documento(self, documento):
        print(f"Abriendo documento: {documento}")
    
    def verificar_formato(self):
        print("Verificando formato del documento")
    
    def guardar_documento(self):
        print("Guardando documento")
    
    def cerrar_documento(self):
        print("Cerrando documento")
    
    # Hook method (método gancho): proporciona implementación predeterminada
    # pero las subclases pueden anularlo
    def requiere_firmas(self):
        return True
    
    def verificar_firmas(self):
        print("Verificando firmas en el documento")

# Implementaciones concretas
class ProcesadorPDF(ProcesadorDocumento):
    def analizar_contenido(self, documento):
        print(f"Analizando contenido del PDF: {documento}")
    
    def procesar_contenido(self):
        print("Procesando contenido del PDF")
    
    # No requiere firmas, anulando el comportamiento predeterminado
    def requiere_firmas(self):
        return False

class ProcesadorContrato(ProcesadorDocumento):
    def analizar_contenido(self, documento):
        print(f"Analizando contenido del contrato: {documento}")
    
    def procesar_contenido(self):
        print("Procesando cláusulas del contrato")
    
    # Mejora la implementación del método
    def verificar_firmas(self):
        print("Verificando firmas electrónicas y sellos notariales")

# Uso
pdf = ProcesadorPDF()
print("Procesando PDF:")
pdf.procesar("informe.pdf")

print("\nProcesando Contrato:")
contrato = ProcesadorContrato()
contrato.procesar("acuerdo_legal.docx")
```

### Consideraciones
- Permite que los clientes anulen solo ciertos aspectos de un algoritmo grande
- Facilita el código duplicado en un método "plantilla"
- Proporciona una buena manera de implementar el principio de "las inversiones de control" o "don't call us, we'll call you"

## 5. Iterator (Iterador)

### Propósito
Proporcionar una forma de acceder secuencialmente a los elementos de un objeto agregado sin exponer su representación subyacente.

### Cuándo usarlo
- Para acceder al contenido de un objeto agregado sin exponer su representación interna
- Para soportar múltiples recorridos de objetos agregados
- Para proporcionar una interfaz uniforme para recorrer diferentes estructuras agregadas

### Ejemplo en Python

```python
from abc import ABC, abstractmethod
from typing import List, Any

# Iterador abstracto
class Iterador(ABC):
    @abstractmethod
    def siguiente(self) -> Any:
        pass
    
    @abstractmethod
    def hay_siguiente(self) -> bool:
        pass
    
    @abstractmethod
    def actual(self) -> Any:
        pass

# Colección abstracta
class Coleccion(ABC):
    @abstractmethod
    def crear_iterador(self) -> Iterador:
        pass

# Iterador concreto
class IteradorArreglo(Iterador):
    def __init__(self, coleccion: List[Any]):
        self._coleccion = coleccion
        self._indice = 0
    
    def siguiente(self) -> Any:
        item = self._coleccion[self._indice]
        self._indice += 1
        return item
    
    def hay_siguiente(self) -> bool:
        return self._indice < len(self._coleccion)
    
    def actual(self) -> Any:
        if self._indice < len(self._coleccion):
            return self._coleccion[self._indice]
        return None

# Colección concreta
class ArregloPersonalizado(Coleccion):
    def __init__(self):
        self._items: List[Any] = []
    
    def agregar_item(self, item: Any):
        self._items.append(item)
    
    def crear_iterador(self) -> Iterador:
        return IteradorArreglo(self._items)

# Uso
arreglo = ArregloPersonalizado()
arreglo.agregar_item("Elemento 1")
arreglo.agregar_item("Elemento 2")
arreglo.agregar_item("Elemento 3")

iterador = arreglo.crear_iterador()

print("Iterando sobre la colección:")
while iterador.hay_siguiente():
    print(iterador.siguiente())

# En Python moderno, se usaría el protocolo de iterador nativo
# Ejemplo equivalente usando el protocolo de iterador de Python:
class ArregloModerno:
    def __init__(self):
        self._items = []
    
    def agregar_item(self, item):
        self._items.append(item)
    
    def __iter__(self):
        self._indice = 0
        return self
    
    def __next__(self):
        if self._indice < len(self._items):
            item = self._items[self._indice]
            self._indice += 1
            return item
        else:
            raise StopIteration

print("\nUsando el protocolo de iterador nativo de Python:")
arreglo_moderno = ArregloModerno()
arreglo_moderno.agregar_item("Elemento A")
arreglo_moderno.agregar_item("Elemento B")
arreglo_moderno.agregar_item("Elemento C")

for item in arreglo_moderno:
    print(item)
```

### Consideraciones
- Simplifica la interfaz del contenedor
- Permite múltiples recorridos en paralelo
- Los lenguajes modernos como Python proporcionan soporte integrado para iteradores
- Puede introducir clases adicionales a la jerarquía

## Selección del patrón de comportamiento adecuado

Para elegir el patrón de comportamiento más apropiado, considera:

1. **Observer**: Ideal para establecer relaciones uno-a-muchos entre objetos, donde los cambios en un objeto deben reflejarse en otros
2. **Strategy**: Perfecto cuando necesitas variantes intercambiables de un algoritmo
3. **Command**: Excelente para encapsular solicitudes como objetos y permitir operaciones como deshacer/rehacer
4. **Template Method**: Útil para definir el esqueleto de un algoritmo, dejando algunos pasos específicos a las subclases
5. **Iterator**: Adecuado para proporcionar acceso secuencial a elementos de una colección sin exponer su estructura interna
6. **State**: Ayuda a que un objeto altere su comportamiento cuando su estado interno cambia
7. **Chain of Responsibility**: Permite que múltiples objetos manejen una solicitud sin que el emisor conozca qué objeto la procesará

Los patrones de comportamiento mejoran la comunicación entre objetos y definen claramente las responsabilidades, lo que lleva a sistemas más flexibles y mantenibles. 