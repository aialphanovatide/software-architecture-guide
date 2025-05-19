# Principio de Abierto-Cerrado (OCP)

> "Las entidades de software deben estar abiertas para la extensión, pero cerradas para la modificación."
> 
> — Bertrand Meyer

## ¿Qué es el OCP?
El Principio de Abierto-Cerrado dice que tu código debe poder extenderse (añadir nuevas funciones) sin tener que cambiar el código que ya funciona. Así, puedes agregar nuevas reglas o comportamientos sin romper lo que ya existe.

---

## Caso de uso: Cálculo de comisiones con diferentes métodos de pago

Supón que tienes una plataforma SaaS que cobra comisión por cada pago recibido, y soporta tarjeta, PayPal y cripto. ¿Qué pasa si no aplicas OCP?

### Problema (antes de OCP)

```python
class CalculadoraComision:
    def calcular(self, metodo_pago, monto):
        if metodo_pago == "tarjeta":
            return monto * 0.03
        elif metodo_pago == "paypal":
            return monto * 0.04
        elif metodo_pago == "cripto":
            return monto * 0.01
        # Si quieres agregar un nuevo método, tienes que modificar esta clase
```

**¿Qué está mal aquí?**
- Cada vez que agregas un nuevo método de pago, tienes que modificar la clase.
- Si olvidas actualizarla, puedes tener errores.
- Si otros usan esta clase, puedes romper su código sin querer.

---

## ¿Por qué es un problema?
- **Riesgo de errores:** Modificar código que ya funciona puede romper cosas.
- **Difícil de mantener:** Cada cambio requiere revisar y modificar la clase.
- **No escala bien:** Si tienes muchos métodos de pago, la clase se vuelve enorme.

---

## Solución: Aplicando OCP

Usamos clases para cada tipo de comisión. Así, solo agregamos nuevas clases, sin tocar la calculadora principal.

```python
from abc import ABC, abstractmethod

class EstrategiaComision(ABC):
    @abstractmethod
    def calcular(self, monto):
        pass

class ComisionTarjeta(EstrategiaComision):
    def calcular(self, monto):
        return monto * 0.03

class ComisionPaypal(EstrategiaComision):
    def calcular(self, monto):
        return monto * 0.04

class ComisionCripto(EstrategiaComision):
    def calcular(self, monto):
        return monto * 0.01

# Si quieres un nuevo método, solo creas una nueva clase
class ComisionStripe(EstrategiaComision):
    def calcular(self, monto):
        return monto * 0.025

class CalculadoraComision:
    def calcular(self, monto, estrategia_comision):
        return estrategia_comision.calcular(monto)

# Uso:
print(CalculadoraComision().calcular(100, ComisionTarjeta()))  # 3.0
print(CalculadoraComision().calcular(100, ComisionCripto()))   # 1.0
```

**¿Qué mejoró?**
- Puedes agregar nuevos métodos de pago sin tocar la calculadora.
- El código es más fácil de mantener y probar.
- Menos riesgo de romper lo que ya funciona.

---

## Checklist para aplicar OCP
- [ ] ¿Puedes agregar nuevas funciones sin modificar el código existente?
- [ ] ¿Usas clases o funciones para extender el comportamiento?
- [ ] ¿Evitas grandes bloques de condicionales para cada caso nuevo?
- [ ] ¿Tu código es fácil de probar cuando agregas nuevas reglas?

---

## Resumen
El OCP te ayuda a crear sistemas que crecen sin miedo a romper lo que ya funciona. Si tienes que modificar mucho código para agregar una nueva función, ¡es momento de aplicar este principio!

## Visualización

```mermaid
classDiagram
    %% Diseño sin aplicar OCP
    class CalculadoraSinOCP {
        +calcularDescuento(producto, tipoDescuento)
    }
    
    note for CalculadoraSinOCP "Problema: Para añadir un nuevo tipo de descuento\ntenemos que modificar esta clase existente"
    
    %% Diseño aplicando OCP
    class CalculadoraOCP {
        +calcularDescuento(producto, estrategia)
    }
    
    class EstrategiaDescuento {
        <<interface>>
        +calcular(producto)
    }
    
    class DescuentoNormal {
        +calcular(producto)
    }
    
    class DescuentoPremium {
        +calcular(producto)
    }
    
    class DescuentoNuevo {
        +calcular(producto)
    }
    
    CalculadoraOCP --> EstrategiaDescuento : usa
    EstrategiaDescuento <|.. DescuentoNormal : implementa
    EstrategiaDescuento <|.. DescuentoPremium : implementa
    EstrategiaDescuento <|.. DescuentoNuevo : implementa
    
    note for EstrategiaDescuento "Solución: Para añadir funcionalidad\nsolo creamos una nueva implementación\nsin tocar el código existente"
```

## ¿Por qué es importante?

- **Reducción de riesgos**: Al no modificar código existente, se reduce el riesgo de introducir nuevos errores
- **Mantenibilidad**: El código se vuelve más fácil de mantener cuando las nuevas funcionalidades no requieren cambios en lo que ya funciona
- **Escalabilidad**: Facilita la evolución del sistema a medida que cambian los requisitos

## Técnicas para aplicar OCP

1. **Abstracción y polimorfismo**: Usar interfaces o clases abstractas para definir contratos
2. **Patrones de diseño**: Implementar patrones como Strategy, Template Method o Decorator
3. **Composición**: Preferir la composición sobre la herencia para lograr mayor flexibilidad
4. **Inyección de dependencias**: Pasar las dependencias a una clase en lugar de crearlas internamente

## Beneficios

- Facilidad para añadir nuevas funcionalidades sin arriesgar el código existente
- Mejor organización del código
- Mayor cohesión y menor acoplamiento
- Código más testeable

## Equilibrio en la aplicación

Aplicar OCP no significa crear abstracciones excesivas desde el principio:

1. No intentes anticipar todos los posibles cambios futuros
2. Aplica el principio cuando identifiques áreas que cambian frecuentemente
3. Sigue el enfoque "primero lo simple, luego lo flexible"

## Relación con otros principios SOLID

- Se complementa con el **Principio de Inversión de Dependencias** (depender de abstracciones)
- El **Principio de Sustitución de Liskov** garantiza que las extensiones se comporten adecuadamente
- El **Principio de Segregación de Interfaces** ayuda a crear interfaces más específicas y fáciles de extender 