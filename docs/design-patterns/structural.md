# Patrones Estructurales

Los patrones estructurales se ocupan de cómo se combinan las clases y los objetos para formar estructuras más grandes y proporcionar nuevas funcionalidades. Estos patrones nos ayudan a asegurar que cuando una parte del sistema cambia, no es necesario cambiar todo el sistema.

## 1. Adapter (Adaptador)

### Propósito
Permitir que interfaces incompatibles trabajen juntas, convirtiendo la interfaz de una clase en otra que el cliente espera.

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

### Cuándo usarlo
- Para representar jerarquías parte-todo de objetos
- Para que los clientes puedan ignorar las diferencias entre composiciones de objetos y objetos individuales
- Para estructuras recursivas como sistemas de archivos, menús, etc.

### Ejemplo en Python

```python
from abc import ABC, abstractmethod
from typing import List

# Componente
class Componente(ABC):
    @abstractmethod
    def operacion(self) -> str:
        pass
    
    @abstractmethod
    def agregar(self, componente) -> None:
        pass
    
    @abstractmethod
    def eliminar(self, componente) -> None:
        pass
    
    @abstractmethod
    def es_compuesto(self) -> bool:
        pass

# Hoja
class Archivo(Componente):
    def __init__(self, nombre):
        self.nombre = nombre
    
    def operacion(self) -> str:
        return f"Archivo: {self.nombre}"
    
    def agregar(self, componente) -> None:
        raise NotImplementedError("No se puede agregar a un archivo")
    
    def eliminar(self, componente) -> None:
        raise NotImplementedError("No se puede eliminar de un archivo")
    
    def es_compuesto(self) -> bool:
        return False

# Compuesto
class Directorio(Componente):
    def __init__(self, nombre):
        self.nombre = nombre
        self.hijos: List[Componente] = []
    
    def operacion(self) -> str:
        resultados = [f"Directorio: {self.nombre}"]
        for hijo in self.hijos:
            # Añadir sangría para visualizar la jerarquía
            resultado_hijo = hijo.operacion()
            resultados.append(f"  {resultado_hijo}")
        return "\n".join(resultados)
    
    def agregar(self, componente) -> None:
        self.hijos.append(componente)
    
    def eliminar(self, componente) -> None:
        self.hijos.remove(componente)
    
    def es_compuesto(self) -> bool:
        return True

# Uso
archivo1 = Archivo("documento.txt")
archivo2 = Archivo("imagen.jpg")
archivo3 = Archivo("datos.csv")

directorio1 = Directorio("Documentos")
directorio1.agregar(archivo1)

directorio2 = Directorio("Imágenes")
directorio2.agregar(archivo2)

directorio_raiz = Directorio("Raíz")
directorio_raiz.agregar(directorio1)
directorio_raiz.agregar(directorio2)
directorio_raiz.agregar(archivo3)

print(directorio_raiz.operacion())
# Salida:
# Directorio: Raíz
#   Directorio: Documentos
#     Archivo: documento.txt
#   Directorio: Imágenes
#     Archivo: imagen.jpg
#   Archivo: datos.csv
```

### Consideraciones
- Simplifica el código del cliente al tratar colecciones y objetos individuales de manera uniforme
- Facilita añadir nuevos tipos de componentes
- Puede hacer el diseño demasiado general

## 4. Decorator (Decorador)

### Propósito
Añadir responsabilidades adicionales a un objeto dinámicamente. Los decoradores proporcionan una alternativa flexible a la herencia para extender la funcionalidad.

### Cuándo usarlo
- Para añadir responsabilidades a objetos individuales dinámicamente, sin afectar a otros objetos
- Para funcionalidades que pueden ser retiradas
- Cuando la extensión por herencia es impráctica por ser demasiado compleja o tener demasiadas subclases

### Ejemplo en Python

```python
from abc import ABC, abstractmethod

# Componente
class Notificacion(ABC):
    @abstractmethod
    def enviar(self, mensaje: str) -> str:
        pass

# Componente concreto
class NotificacionBasica(Notificacion):
    def enviar(self, mensaje: str) -> str:
        return f"Notificación: {mensaje}"

# Decorador base
class DecoradorNotificacion(Notificacion):
    def __init__(self, notificacion_envuelta: Notificacion):
        self.notificacion_envuelta = notificacion_envuelta
    
    def enviar(self, mensaje: str) -> str:
        return self.notificacion_envuelta.enviar(mensaje)

# Decoradores concretos
class NotificacionSMS(DecoradorNotificacion):
    def enviar(self, mensaje: str) -> str:
        return f"SMS: {self.notificacion_envuelta.enviar(mensaje)}"

class NotificacionEmail(DecoradorNotificacion):
    def enviar(self, mensaje: str) -> str:
        return f"Email: {self.notificacion_envuelta.enviar(mensaje)}"

class NotificacionPush(DecoradorNotificacion):
    def enviar(self, mensaje: str) -> str:
        return f"Push: {self.notificacion_envuelta.enviar(mensaje)}"

# Uso
notificacion = NotificacionBasica()
print(notificacion.enviar("¡Alerta!"))  # Notificación: ¡Alerta!

notificacion_sms = NotificacionSMS(notificacion)
print(notificacion_sms.enviar("¡Alerta!"))  # SMS: Notificación: ¡Alerta!

notificacion_email_sms = NotificacionEmail(notificacion_sms)
print(notificacion_email_sms.enviar("¡Alerta!"))  # Email: SMS: Notificación: ¡Alerta!

# Podemos combinar decoradores de diferentes maneras
notificacion_completa = NotificacionPush(NotificacionEmail(NotificacionSMS(NotificacionBasica())))
print(notificacion_completa.enviar("¡Alerta!"))  # Push: Email: SMS: Notificación: ¡Alerta!
```

### Consideraciones
- Más flexible que la herencia
- Permite añadir o retirar responsabilidades en tiempo de ejecución
- Evita clases sobrecargadas de características en lo alto de la jerarquía
- Puede resultar en muchos objetos pequeños y complicar la depuración

## 5. Facade (Fachada)

### Propósito
Proporcionar una interfaz unificada a un conjunto de interfaces en un subsistema. Define una interfaz de alto nivel que hace que el subsistema sea más fácil de usar.

### Cuándo usarlo
- Para proporcionar una interfaz simple a un subsistema complejo
- Para desacoplar un subsistema de sus clientes
- Para introducir una capa entre capas de software

### Ejemplo en Python

```python
# Subsistema complejo
class SistemaAudio:
    def configurar_volumen(self, nivel):
        return f"Volumen configurado a {nivel}%"
    
    def configurar_ecualizacion(self, bajos, medios, agudos):
        return f"Ecualización: bajos={bajos}, medios={medios}, agudos={agudos}"
    
    def encender(self):
        return "Sistema de audio encendido"
    
    def apagar(self):
        return "Sistema de audio apagado"

class SistemaVideo:
    def configurar_resolucion(self, resolucion):
        return f"Resolución configurada a {resolucion}"
    
    def configurar_brillo(self, brillo):
        return f"Brillo configurado a {brillo}%"
    
    def encender(self):
        return "Sistema de video encendido"
    
    def apagar(self):
        return "Sistema de video apagado"

class SistemaLuces:
    def atenuar(self, nivel):
        return f"Luces atenuadas a {nivel}%"
    
    def configurar_color(self, color):
        return f"Color de luces configurado a {color}"
    
    def encender(self):
        return "Sistema de luces encendido"
    
    def apagar(self):
        return "Sistema de luces apagado"

# Fachada
class SistemaCineEnCasa:
    def __init__(self):
        self.audio = SistemaAudio()
        self.video = SistemaVideo()
        self.luces = SistemaLuces()
    
    def ver_pelicula(self, pelicula):
        resultados = []
        resultados.append(self.audio.encender())
        resultados.append(self.video.encender())
        resultados.append(self.luces.encender())
        
        resultados.append(self.audio.configurar_volumen(70))
        resultados.append(self.audio.configurar_ecualizacion(80, 50, 60))
        resultados.append(self.video.configurar_resolucion("4K"))
        resultados.append(self.video.configurar_brillo(80))
        resultados.append(self.luces.atenuar(30))
        resultados.append(self.luces.configurar_color("azul tenue"))
        
        resultados.append(f"¡Disfrutando de la película {pelicula}!")
        return "\n".join(resultados)
    
    def finalizar_pelicula(self):
        resultados = []
        resultados.append(self.audio.apagar())
        resultados.append(self.video.apagar())
        resultados.append(self.luces.configurar_color("blanco"))
        resultados.append(self.luces.atenuar(100))
        return "\n".join(resultados)

# Uso
sistema_cine = SistemaCineEnCasa()
print(sistema_cine.ver_pelicula("El Padrino"))
print("\nFin de la película:\n")
print(sistema_cine.finalizar_pelicula())
```

### Consideraciones
- Simplifica el uso de subsistemas complejos
- Promueve el bajo acoplamiento entre el cliente y los subsistemas
- Puede convertirse en un objeto "dios" que hace demasiado

## 6. Proxy

### Propósito
Proporcionar un sustituto o marcador de posición para otro objeto para controlar el acceso a él.

### Cuándo usarlo
- Para control de acceso (Proxy de protección)
- Para cargar objetos pesados solo cuando sea necesario (Proxy virtual)
- Para añadir funcionalidad adicional al acceder a un objeto (Proxy inteligente)
- Para conexiones remotas (Proxy remoto)

### Ejemplo en Python

```python
from abc import ABC, abstractmethod
import time

# Sujeto
class Imagen(ABC):
    @abstractmethod
    def mostrar(self) -> str:
        pass

# Sujeto real
class ImagenReal(Imagen):
    def __init__(self, archivo):
        self.archivo = archivo
        self._cargar_desde_disco()
    
    def _cargar_desde_disco(self):
        # Simular carga de imagen pesada
        print(f"Cargando imagen {self.archivo}...")
        time.sleep(1)  # Simulación de tiempo de carga
        print(f"Imagen {self.archivo} cargada.")
    
    def mostrar(self) -> str:
        return f"Mostrando imagen {self.archivo}"

# Proxy
class ProxyImagen(Imagen):
    def __init__(self, archivo):
        self.archivo = archivo
        self.imagen_real = None
    
    def mostrar(self) -> str:
        # Cargar la imagen sólo cuando sea necesario
        if self.imagen_real is None:
            self.imagen_real = ImagenReal(self.archivo)
        
        return self.imagen_real.mostrar()

# Uso
imagenes = [
    ProxyImagen("imagen1.jpg"),
    ProxyImagen("imagen2.jpg"),
    ProxyImagen("imagen3.jpg")
]

# Las imágenes no se cargan hasta que se llama a mostrar
print("Galería iniciada, pero las imágenes aún no se han cargado.")

# Primera imagen mostrada - se cargará desde el disco
print(imagenes[0].mostrar())

# La misma imagen mostrada de nuevo - no se carga de nuevo
print(imagenes[0].mostrar())

# Otra imagen mostrada - se cargará desde el disco
print(imagenes[2].mostrar())
```

### Consideraciones
- Permite controlar el acceso al objeto original sin que los clientes lo sepan
- Puede mejorar el rendimiento mediante la carga diferida
- Añade una capa de indirección que puede impactar el rendimiento en accesos frecuentes

## 7. Flyweight (Peso Ligero)

### Propósito
Utilizar compartición para soportar grandes cantidades de objetos de granularidad fina eficientemente.

### Cuándo usarlo
- Cuando una aplicación utiliza un gran número de objetos
- Cuando los costos de almacenamiento son altos debido a la cantidad de objetos
- Cuando la mayoría del estado de los objetos puede ser externalizado
- Cuando muchos grupos de objetos pueden ser reemplazados por relativamente pocos objetos compartidos

### Ejemplo en Python

```python
import json
from typing import Dict

# Flyweight
class CaracterFlyweight:
    def __init__(self, tipo_fuente, tamaño, color):
        self.tipo_fuente = tipo_fuente
        self.tamaño = tamaño
        self.color = color
    
    def renderizar(self, texto, posicion_x, posicion_y):
        return f"Renderizando '{texto}' en ({posicion_x}, {posicion_y}) con {self.tipo_fuente}, tamaño {self.tamaño}, color {self.color}"

# Fábrica Flyweight
class FabricaCaracteres:
    def __init__(self):
        self.caracteres: Dict[str, CaracterFlyweight] = {}
    
    def obtener_caracter(self, tipo_fuente, tamaño, color):
        # Crear una clave para el flyweight
        clave = json.dumps([tipo_fuente, tamaño, color])
        
        # Si no existe, crear un nuevo flyweight
        if clave not in self.caracteres:
            self.caracteres[clave] = CaracterFlyweight(tipo_fuente, tamaño, color)
            print(f"Creando nuevo estilo de caracter: {clave}")
        else:
            print(f"Reutilizando estilo de caracter: {clave}")
        
        return self.caracteres[clave]
    
    def contar_caracteres(self):
        return len(self.caracteres)

# Cliente
class Editor:
    def __init__(self):
        self.fabrica = FabricaCaracteres()
        self.caracteres = []
    
    def agregar_caracter(self, texto, posicion_x, posicion_y, tipo_fuente, tamaño, color):
        caracter = self.fabrica.obtener_caracter(tipo_fuente, tamaño, color)
        self.caracteres.append((caracter, texto, posicion_x, posicion_y))
    
    def renderizar_documento(self):
        resultados = []
        for caracter, texto, posicion_x, posicion_y in self.caracteres:
            resultados.append(caracter.renderizar(texto, posicion_x, posicion_y))
        return "\n".join(resultados)

# Uso
editor = Editor()

# Agregar caracteres con diferentes estilos
editor.agregar_caracter("H", 10, 10, "Arial", 12, "Negro")
editor.agregar_caracter("o", 20, 10, "Arial", 12, "Negro")
editor.agregar_caracter("l", 30, 10, "Arial", 12, "Negro")
editor.agregar_caracter("a", 40, 10, "Arial", 12, "Negro")

# Agregar caracteres con diferentes estilos
editor.agregar_caracter("M", 10, 20, "Times New Roman", 14, "Rojo")
editor.agregar_caracter("u", 20, 20, "Times New Roman", 14, "Rojo")
editor.agregar_caracter("n", 30, 20, "Times New Roman", 14, "Rojo")
editor.agregar_caracter("d", 40, 20, "Times New Roman", 14, "Rojo")
editor.agregar_caracter("o", 50, 20, "Times New Roman", 14, "Rojo")

print(f"Número de estilos de caracteres únicos: {editor.fabrica.contar_caracteres()}")
print(editor.renderizar_documento())
```

### Consideraciones
- Reduce la huella de memoria cuando se tienen muchos objetos similares
- Puede introducir complejidad para gestionar el estado extrínseco
- Requiere identificar claramente qué partes del estado pueden compartirse

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