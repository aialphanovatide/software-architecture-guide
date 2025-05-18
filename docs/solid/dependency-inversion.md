# Principio de Inversión de Dependencias (DIP)

> "Los módulos de alto nivel no deberían depender de módulos de bajo nivel. Ambos deberían depender de abstracciones."
>
> "Las abstracciones no deberían depender de los detalles. Los detalles deberían depender de las abstracciones."
> 
> — Robert C. Martin

## ¿Qué es?

El Principio de Inversión de Dependencias establece que los componentes de alto nivel (políticas de negocio, flujos de trabajo) no deben depender directamente de componentes de bajo nivel (implementaciones específicas, infraestructura). En cambio, ambos deben depender de abstracciones.

## ¿Por qué es importante?

- Reduce el acoplamiento entre módulos
- Facilita el cambio de implementaciones
- Mejora la testabilidad del código
- Permite el desarrollo en paralelo de componentes
- Promueve un diseño modular y flexible

## Ejemplo problemático

```python
class ServicioNotificacionEmail:
    def enviar_email(self, destinatario, asunto, mensaje):
        print(f"Enviando email a {destinatario}, Asunto: {asunto}, Mensaje: {mensaje}")
        # Lógica para enviar email...

class GestorUsuarios:
    def __init__(self):
        # Dependencia directa de una implementación concreta
        self.notificador = ServicioNotificacionEmail()
    
    def registrar_usuario(self, email, nombre):
        # Lógica para registrar usuario...
        print(f"Usuario {nombre} registrado")
        
        # Dependencia rígida de una implementación específica
        self.notificador.enviar_email(
            email,
            "Bienvenido al sistema",
            f"Hola {nombre}, tu cuenta ha sido creada con éxito."
        )
```

Este diseño es problemático porque:
- `GestorUsuarios` depende directamente de `ServicioNotificacionEmail`
- Es difícil cambiar el mecanismo de notificación (SMS, push, etc.)
- Es difícil hacer pruebas unitarias sin enviar emails reales

## Solución aplicando DIP

```python
from abc import ABC, abstractmethod

# 1. Definir una abstracción
class ServicioNotificacion(ABC):
    @abstractmethod
    def enviar_notificacion(self, destinatario, asunto, mensaje):
        pass

# 2. Implementar la abstracción
class ServicioNotificacionEmail(ServicioNotificacion):
    def enviar_notificacion(self, destinatario, asunto, mensaje):
        print(f"Enviando email a {destinatario}, Asunto: {asunto}, Mensaje: {mensaje}")
        # Lógica para enviar email...

class ServicioNotificacionSMS(ServicioNotificacion):
    def enviar_notificacion(self, destinatario, asunto, mensaje):
        print(f"Enviando SMS a {destinatario}: {mensaje}")
        # Lógica para enviar SMS...

# 3. Alto nivel depende de abstracción mediante inyección de dependencias
class GestorUsuarios:
    def __init__(self, servicio_notificacion: ServicioNotificacion):
        # Dependencia de una abstracción, no de una implementación concreta
        self.notificador = servicio_notificacion
    
    def registrar_usuario(self, destinatario, nombre):
        # Lógica para registrar usuario...
        print(f"Usuario {nombre} registrado")
        
        # Usa la abstracción
        self.notificador.enviar_notificacion(
            destinatario,
            "Bienvenido al sistema",
            f"Hola {nombre}, tu cuenta ha sido creada con éxito."
        )

# 4. Configuración de la aplicación / contenedor DI
notificador_email = ServicioNotificacionEmail()
gestor = GestorUsuarios(notificador_email)
gestor.registrar_usuario("usuario@ejemplo.com", "Ana")

# Cambiar a SMS es sencillo
notificador_sms = ServicioNotificacionSMS()
gestor_con_sms = GestorUsuarios(notificador_sms)
gestor_con_sms.registrar_usuario("123456789", "Juan")
```

## Técnicas para implementar DIP

1. **Inyección de dependencias**: Pasar las dependencias desde el exterior
   - Inyección por constructor (preferida)
   - Inyección por método
   - Inyección por propiedad

2. **Contenedores de IoC** (Inversión de Control): Automatizar la inyección de dependencias

3. **Uso de interfaces/clases abstractas**: Definir contratos claros entre componentes

4. **Factories y Service Locators**: Aislar la creación de objetos concretos

## Beneficios de aplicar DIP

- **Desacoplamiento**: Componentes menos dependientes entre sí
- **Facilidad de cambio**: Implementaciones intercambiables
- **Testabilidad**: Fácil sustitución por mocks o stubs
- **Reutilización**: Componentes más genéricos y flexibles
- **Mantenibilidad**: Código más robusto ante cambios

## Retos comunes

- **Sobregeneralización**: Crear abstracciones innecesarias
- **Indirección excesiva**: Demasiadas capas que dificultan la comprensión
- **Abstracciones filtradas**: Cuando los detalles se filtran a través de las abstracciones

## Relación con otros principios SOLID

- Facilita el **Principio Abierto-Cerrado** al permitir extensiones sin modificación
- Apoya el **Principio de Sustitución de Liskov** mediante el uso adecuado de abstracciones
- Complementa el **Principio de Segregación de Interfaces** para crear dependencias específicas
- Refuerza el **Principio de Responsabilidad Única** al separar la creación de la lógica 