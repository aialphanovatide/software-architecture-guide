# Patrones Creacionales

Los patrones creacionales proporcionan diferentes mecanismos para crear objetos, lo que aumenta la flexibilidad y la reutilización del código existente. Estos patrones abstraen el proceso de instanciación y ayudan a que un sistema sea independiente de cómo se crean, componen y representan sus objetos.

## 1. Singleton

### Propósito
Garantizar que una clase tenga una única instancia y proporcionar un punto de acceso global a ella.

### Cuándo usarlo
- Cuando debe haber exactamente una instancia de una clase
- Cuando se necesita un punto de acceso global y controlado
- Para recursos compartidos como conexiones a bases de datos, pools de objetos o configuraciones

### Ejemplo en Python

```python
class Singleton:
    _instancia = None
    
    def __new__(cls):
        if cls._instancia is None:
            cls._instancia = super().__new__(cls)
        return cls._instancia
    
    def __init__(self):
        # La inicialización se ejecutará cada vez, pero solo
        # hay una instancia.
        if not hasattr(self, 'inicializado'):
            self.inicializado = True
            self.datos = []
    
    def agregar_dato(self, dato):
        self.datos.append(dato)
        
    def obtener_datos(self):
        return self.datos

# Uso
s1 = Singleton()
s1.agregar_dato("datos 1")

s2 = Singleton()  # Devuelve la misma instancia
print(s2.obtener_datos())  # ['datos 1']
```

### Ejemplo en TypeScript

```typescript
class Singleton {
    private static instance: Singleton;
    private data: string[] = [];
    
    private constructor() {
        // Constructor privado para evitar instanciación directa
    }
    
    public static getInstance(): Singleton {
        if (!Singleton.instance) {
            Singleton.instance = new Singleton();
        }
        return Singleton.instance;
    }
    
    public addData(item: string): void {
        this.data.push(item);
    }
    
    public getData(): string[] {
        return this.data;
    }
}

// Uso
const s1 = Singleton.getInstance();
s1.addData("datos 1");

const s2 = Singleton.getInstance();
console.log(s2.getData());  // ['datos 1']
```

### Consideraciones
- Puede dificultar las pruebas unitarias
- Viola el principio de responsabilidad única
- Es esencialmente un global state con todos sus inconvenientes
- En ambientes concurrentes, requiere sincronización

## 2. Factory Method

### Propósito
Definir una interfaz para crear un objeto, pero dejar que las subclases decidan qué clase instanciar.

### Cuándo usarlo
- Cuando una clase no puede anticipar la clase de objetos que debe crear
- Cuando una clase quiere que sus subclases especifiquen los objetos que crean
- Cuando las clases delegan responsabilidad a una de varias subclases auxiliares

### Ejemplo en Python

```python
from abc import ABC, abstractmethod

# Producto abstracto
class Documento(ABC):
    @abstractmethod
    def crear(self):
        pass

# Productos concretos
class DocumentoPDF(Documento):
    def crear(self):
        return "Creando PDF"

class DocumentoWord(Documento):
    def crear(self):
        return "Creando DOCX"

# Creador abstracto
class CreadorDocumento(ABC):
    @abstractmethod
    def factory_method(self):
        pass
    
    def operacion(self):
        documento = self.factory_method()
        resultado = documento.crear()
        return resultado

# Creadores concretos
class CreadorPDF(CreadorDocumento):
    def factory_method(self):
        return DocumentoPDF()

class CreadorWord(CreadorDocumento):
    def factory_method(self):
        return DocumentoWord()

# Uso
creador_pdf = CreadorPDF()
print(creador_pdf.operacion())  # "Creando PDF"

creador_word = CreadorWord()
print(creador_word.operacion())  # "Creando DOCX"
```

### Consideraciones
- Introduce flexibilidad para extender el sistema con nuevos tipos de productos
- El código se vuelve más complejo debido a la jerarquía de clases

## 3. Abstract Factory

### Propósito
Proporcionar una interfaz para crear familias de objetos relacionados o dependientes sin especificar sus clases concretas.

### Cuándo usarlo
- Cuando un sistema debe ser independiente de cómo se crean sus productos
- Cuando un sistema debe trabajar con múltiples familias de productos
- Cuando se desea proporcionar una biblioteca de productos y solo revelar sus interfaces

### Ejemplo en Python

```python
from abc import ABC, abstractmethod

# Productos abstractos
class Boton(ABC):
    @abstractmethod
    def pintar(self):
        pass

class CajadeTexto(ABC):
    @abstractmethod
    def pintar(self):
        pass

# Productos concretos - Familia Windows
class BotonWindows(Boton):
    def pintar(self):
        return "Botón estilo Windows"

class CajaTextoWindows(CajadeTexto):
    def pintar(self):
        return "Caja de texto estilo Windows"

# Productos concretos - Familia macOS
class BotonMacOS(Boton):
    def pintar(self):
        return "Botón estilo macOS"

class CajaTextoMacOS(CajadeTexto):
    def pintar(self):
        return "Caja de texto estilo macOS"

# Fábrica abstracta
class FabricaUI(ABC):
    @abstractmethod
    def crear_boton(self):
        pass
    
    @abstractmethod
    def crear_caja_texto(self):
        pass

# Fábricas concretas
class FabricaUIWindows(FabricaUI):
    def crear_boton(self):
        return BotonWindows()
    
    def crear_caja_texto(self):
        return CajaTextoWindows()

class FabricaUIMacOS(FabricaUI):
    def crear_boton(self):
        return BotonMacOS()
    
    def crear_caja_texto(self):
        return CajaTextoMacOS()

# Cliente
class Aplicacion:
    def __init__(self, fabrica):
        self.fabrica = fabrica
        self.boton = None
        self.caja_texto = None
    
    def crear_ui(self):
        self.boton = self.fabrica.crear_boton()
        self.caja_texto = self.fabrica.crear_caja_texto()
    
    def pintar(self):
        return [self.boton.pintar(), self.caja_texto.pintar()]

# Uso
app_windows = Aplicacion(FabricaUIWindows())
app_windows.crear_ui()
print(app_windows.pintar())  # ["Botón estilo Windows", "Caja de texto estilo Windows"]

app_macos = Aplicacion(FabricaUIMacOS())
app_macos.crear_ui()
print(app_macos.pintar())  # ["Botón estilo macOS", "Caja de texto estilo macOS"]
```

### Consideraciones
- Facilita el intercambio de familias de productos
- Promueve la consistencia entre productos
- Agregar nuevos productos puede ser complicado, ya que implica modificar la interfaz de la fábrica

## 4. Builder

### Propósito
Separar la construcción de un objeto complejo de su representación, de modo que el mismo proceso de construcción pueda crear diferentes representaciones.

### Cuándo usarlo
- Cuando el proceso de construcción debe permitir diferentes representaciones del objeto construido
- Cuando el algoritmo para crear un objeto complejo debe ser independiente de las partes y de cómo se ensamblan
- Cuando la construcción de un objeto requiere muchos parámetros, algunos opcionales

### Ejemplo en Python

```python
class Hamburguesa:
    def __init__(self):
        self.pan = None
        self.carne = None
        self.lechuga = False
        self.tomate = False
        self.queso = False
        self.cebolla = False
    
    def __str__(self):
        ingredientes = [self.pan, self.carne]
        if self.lechuga:
            ingredientes.append("lechuga")
        if self.tomate:
            ingredientes.append("tomate")
        if self.queso:
            ingredientes.append("queso")
        if self.cebolla:
            ingredientes.append("cebolla")
        return f"Hamburguesa con {', '.join(ingredientes)}"

class ConstructorHamburguesa:
    def __init__(self):
        self.hamburguesa = Hamburguesa()
    
    def reset(self):
        self.hamburguesa = Hamburguesa()
        return self
    
    def con_pan(self, tipo):
        self.hamburguesa.pan = tipo
        return self
    
    def con_carne(self, tipo):
        self.hamburguesa.carne = tipo
        return self
    
    def con_lechuga(self):
        self.hamburguesa.lechuga = True
        return self
    
    def con_tomate(self):
        self.hamburguesa.tomate = True
        return self
    
    def con_queso(self):
        self.hamburguesa.queso = True
        return self
    
    def con_cebolla(self):
        self.hamburguesa.cebolla = True
        return self
    
    def build(self):
        resultado = self.hamburguesa
        self.reset()
        return resultado

# Uso
constructor = ConstructorHamburguesa()

hamburguesa_clasica = constructor.con_pan("blanco") \
                               .con_carne("res") \
                               .con_lechuga() \
                               .con_tomate() \
                               .build()

hamburguesa_queso = constructor.con_pan("integral") \
                              .con_carne("pollo") \
                              .con_queso() \
                              .build()

print(hamburguesa_clasica)  # Hamburguesa con pan blanco, carne de res, lechuga, tomate
print(hamburguesa_queso)    # Hamburguesa con pan integral, carne de pollo, queso
```

### Consideraciones
- Permite crear diferentes representaciones del mismo objeto
- Aísla el código de construcción del código de representación
- Proporciona control sobre el proceso de construcción

## 5. Prototype

### Propósito
Permite crear nuevos objetos copiando un objeto existente, conocido como prototipo.

### Cuándo usarlo
- Cuando las clases a instanciar se especifican en tiempo de ejecución
- Para evitar construir una jerarquía de fábricas paralela a la jerarquía de productos
- Cuando las instancias de una clase pueden tener solo unas pocas combinaciones de estado

### Ejemplo en Python

```python
import copy

class Prototipo:
    def __init__(self):
        self.objetos = {}
    
    def registrar_objeto(self, nombre, objeto):
        self.objetos[nombre] = objeto
    
    def anular_registro(self, nombre):
        del self.objetos[nombre]
    
    def clonar(self, nombre, **atributos):
        obj = copy.deepcopy(self.objetos.get(nombre))
        if not obj:
            raise ValueError(f"Prototipo {nombre} no encontrado")
        
        # Personalizar el clon con atributos adicionales
        obj.__dict__.update(atributos)
        return obj

class Documento:
    def __init__(self, nombre, contenido):
        self.nombre = nombre
        self.contenido = contenido
    
    def __str__(self):
        return f"Documento: {self.nombre}, Contenido: {self.contenido}"

# Uso
registro = Prototipo()
doc_original = Documento("template", "Este es un documento plantilla")
registro.registrar_objeto("doc_basico", doc_original)

# Crear clones con modificaciones
doc1 = registro.clonar("doc_basico", nombre="Reporte 1", contenido="Contenido del reporte 1")
doc2 = registro.clonar("doc_basico", nombre="Reporte 2")

print(doc1)  # Documento: Reporte 1, Contenido: Contenido del reporte 1
print(doc2)  # Documento: Reporte 2, Contenido: Este es un documento plantilla
```

### Consideraciones
- Reduce la necesidad de subclases
- Permite agregar o eliminar objetos en tiempo de ejecución
- Proporciona una alternativa a la herencia para variar el comportamiento
- En lenguajes modernos, puede preferirse usar mecanismos nativos de clonación

## Selección del patrón creacional adecuado

Para elegir el patrón creacional más adecuado, considera:

1. **Singleton**: Usa cuando necesites exactamente una instancia compartida, pero ten cuidado con sus inconvenientes
2. **Factory Method**: Ideal cuando quieres encapsular la creación de objetos y permitir la extensibilidad por subclases
3. **Abstract Factory**: Útil para crear familias de objetos relacionados sin especificar sus clases concretas
4. **Builder**: Perfecto para objetos complejos con múltiples representaciones o cuando la construcción requiere muchos pasos
5. **Prototype**: Excelente cuando la clonación es más eficiente que la creación desde cero

Recuerda que los patrones no son mutuamente excluyentes y a menudo se combinan para resolver problemas más complejos. 