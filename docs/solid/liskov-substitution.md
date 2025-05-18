# Principio de Sustitución de Liskov (LSP)

> "Si S es un subtipo de T, entonces los objetos de tipo T pueden ser reemplazados por objetos de tipo S sin alterar ninguna de las propiedades deseables del programa."
> 
> — Barbara Liskov

## ¿Qué es?

El Principio de Sustitución de Liskov establece que las clases derivadas deben poder sustituir a sus clases base sin afectar el comportamiento esperado del programa. En otras palabras, las subclases deben comportarse de manera que no sorprendan a quienes usan la clase base.

## Visualización

```mermaid
classDiagram
    class Forma {
        <<abstract>>
        +calcularArea() float
    }
    
    class Rectángulo {
        -ancho: float
        -alto: float
        +establecerAncho(ancho: float)
        +establecerAlto(alto: float)
        +calcularArea() float
    }
    
    class Cuadrado {
        -lado: float
        +establecerLado(lado: float)
        +calcularArea() float
    }

    Forma <|-- Rectángulo : Correcto✓
    Forma <|-- Cuadrado : Correcto✓
    
    class RectánguloLSP {
        -ancho: float
        -alto: float
        +establecerAncho(ancho: float)
        +establecerAlto(alto: float)
        +calcularArea() float
    }
    
    class CuadradoLSP~Viola LSP~ {
        -lado: float
        +establecerAncho(ancho: float)
        +establecerAlto(alto: float)
        +calcularArea() float
    }

    RectánguloLSP <|-- CuadradoLSP : Incorrecto✗
    
    note for CuadradoLSP "Si establecerAncho cambia tanto ancho como alto,\n viola las expectativas de RectánguloLSP"
```

## ¿Por qué es importante?

- Garantiza que la herencia se utilice correctamente
- Evita comportamientos inesperados al usar polimorfismo
- Facilita la extensión de código sin introducir errores
- Promueve un diseño más coherente y predecible

## Ejemplo problemático

```python
class Rectangulo:
    def __init__(self, ancho, alto):
        self.ancho = ancho
        self.alto = alto
        
    def establecer_ancho(self, ancho):
        self.ancho = ancho
        
    def establecer_alto(self, alto):
        self.alto = alto
        
    def calcular_area(self):
        return self.ancho * self.alto

class Cuadrado(Rectangulo):
    def __init__(self, lado):
        super().__init__(lado, lado)
        
    # Aquí está el problema - rompe el comportamiento esperado
    def establecer_ancho(self, ancho):
        self.ancho = ancho
        self.alto = ancho  # Un cuadrado debe tener lados iguales
        
    def establecer_alto(self, alto):
        self.ancho = alto  # Un cuadrado debe tener lados iguales
        self.alto = alto
```

```python
def calcular_y_mostrar_area(rectangulo):
    rectangulo.establecer_ancho(5)
    rectangulo.establecer_alto(4)
    # Este código espera que el área sea 5*4=20
    assert rectangulo.calcular_area() == 20
    return rectangulo.calcular_area()

# Esto funciona
r = Rectangulo(3, 3)
calcular_y_mostrar_area(r)  # Devuelve 20 como se esperaba

# Esto falla
c = Cuadrado(3)
calcular_y_mostrar_area(c)  # Devuelve 16 en lugar de 20 - ¡Viola LSP!
```

## Solución aplicando LSP

Una mejor solución sería evitar la herencia en este caso y usar composición o interfaces diferentes:

```python
from abc import ABC, abstractmethod

class Forma(ABC):
    @abstractmethod
    def calcular_area(self):
        pass

class Rectangulo(Forma):
    def __init__(self, ancho, alto):
        self.ancho = ancho
        self.alto = alto
        
    def establecer_ancho(self, ancho):
        self.ancho = ancho
        
    def establecer_alto(self, alto):
        self.alto = alto
        
    def calcular_area(self):
        return self.ancho * self.alto

class Cuadrado(Forma):
    def __init__(self, lado):
        self.lado = lado
        
    def establecer_lado(self, lado):
        self.lado = lado
        
    def calcular_area(self):
        return self.lado * self.lado
```

## Reglas para cumplir con LSP

Para asegurar que tus subtipos cumplen con el Principio de Sustitución de Liskov:

1. **Precondiciones**: No pueden ser más estrictas en la subclase
2. **Postcondiciones**: No pueden ser más débiles en la subclase
3. **Invariantes**: Deben mantenerse en las subclases
4. **Restricciones históricas**: La historia de estados permitidos no debe cambiar
5. **No introducir excepciones nuevas** que no estén en la clase base

## Señales de violación del LSP

- Sobrescrituras de métodos que lanzan excepciones inesperadas
- Métodos sobrescritos que no hacen nada o tienen comportamientos radicalmente diferentes
- Comprobaciones `instanceof` o `type()` frecuentes
- Comentarios como "No llamar a este método en X situación"

## Beneficios de aplicar LSP

- Mayor reusabilidad de código
- Mejor diseño de herencia
- Facilita la implementación del Principio Abierto-Cerrado
- Menor acoplamiento entre componentes
- Código más fácil de probar

## Relación con otros principios SOLID

- Complementa el **Principio Abierto-Cerrado** al garantizar que las extensiones funcionan correctamente
- Apoya la **Inversión de Dependencias** al permitir trabajar con abstracciones de manera segura
- Se relaciona con el **Principio de Segregación de Interfaces** para crear contratos bien definidos 