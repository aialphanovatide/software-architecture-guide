# Principio de Responsabilidad Única (SRP)

> "Una clase debe tener una sola razón para cambiar."
> 
> — Robert C. Martin

## ¿Qué es?

El Principio de Responsabilidad Única establece que cada clase o módulo debe tener responsabilidad sobre una sola parte de la funcionalidad del software, y esta responsabilidad debe estar completamente encapsulada por la clase.

## ¿Por qué es importante?

Cuando una clase asume múltiples responsabilidades:
- Se vuelve más difícil de entender y mantener
- Los cambios en una responsabilidad pueden afectar a otras
- Es más difícil de reutilizar
- Se vuelve más propensa a errores

## Ejemplo problemático

```python
class Usuario:
    def __init__(self, nombre, email):
        self.nombre = nombre
        self.email = email
        
    def validar_email(self):
        # Lógica para validar email
        return "@" in self.email
        
    def guardar_en_db(self):
        # Lógica para conectar a la base de datos
        # y guardar al usuario
        print(f"Guardando usuario {self.nombre} en la base de datos")
        
    def enviar_email_bienvenida(self):
        # Lógica para conectar al servicio de email
        # y enviar email de bienvenida
        print(f"Enviando email de bienvenida a {self.email}")
```

Esta clase `Usuario` tiene múltiples responsabilidades:
- Almacenar datos del usuario
- Validar datos
- Interactuar con la base de datos
- Enviar comunicaciones

## Solución aplicando SRP

```python
class Usuario:
    def __init__(self, nombre, email):
        self.nombre = nombre
        self.email = email

class ValidadorEmail:
    @staticmethod
    def validar(email):
        return "@" in email

class RepositorioUsuarios:
    def guardar(self, usuario):
        # Lógica para conectar a la base de datos y guardar
        print(f"Guardando usuario {usuario.nombre} en la base de datos")

class ServicioEmail:
    def enviar_bienvenida(self, usuario):
        # Lógica para enviar email
        print(f"Enviando email de bienvenida a {usuario.email}")
```

## Beneficios de esta implementación

- Cada clase tiene una única responsabilidad bien definida
- Las clases son más fáciles de entender y mantener
- Los cambios en una funcionalidad no afectan al resto
- Las clases se pueden reutilizar en diferentes contextos

## Consideraciones prácticas

- El tamaño no es lo importante; la cohesión y el propósito sí lo son
- Una clase pequeña puede violar SRP si tiene múltiples responsabilidades
- El contexto importa; lo que constituye una "responsabilidad" depende del dominio

## Detección de violaciones del SRP

Señales de que una clase podría estar violando SRP:
- Métodos que operan en diferentes partes del estado interno
- La clase crece constantemente con nuevas funcionalidades
- Dificultad para describir lo que hace la clase en una sola frase
- La clase tiene muchas dependencias

SRP es el fundamento de los principios SOLID y su correcta aplicación facilita la implementación de los demás principios. 