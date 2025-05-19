# Principio de Responsabilidad Única (SRP)

> "Una clase debe tener una sola razón para cambiar."
> 
> — Robert C. Martin

## ¿Qué es el SRP?
El Principio de Responsabilidad Única dice que cada clase, función o módulo debe encargarse de una sola cosa. Si una clase hace muchas cosas, será difícil de entender, mantener y probar.

---

## Caso de uso: Registro de usuarios

Imagina que tienes que crear una función para registrar usuarios en una aplicación. ¿Qué suele pasar si no aplicamos SRP?

### Problema (antes de SRP)

```python
class Usuario:
    def __init__(self, nombre, email):
        self.nombre = nombre
        self.email = email
    
    def registrar(self):
        # 1. Validar email
        if "@" not in self.email:
            raise ValueError("Email inválido")
        # 2. Guardar en la base de datos
        print(f"Guardando usuario {self.nombre} en la base de datos")
        # 3. Enviar email de bienvenida
        print(f"Enviando email de bienvenida a {self.email}")
```

**¿Qué está mal aquí?**
- La clase `Usuario` valida emails, guarda en la base de datos y envía correos.
- Si cambia la forma de validar emails, guardar datos o enviar correos, hay que modificar esta clase.
- Es difícil de probar cada parte por separado.

---

## ¿Por qué es un problema?
- **Difícil de mantener:** Cambios en una parte pueden romper otras.
- **Difícil de probar:** No puedes probar la validación sin tocar la base de datos o el email.
- **Difícil de reutilizar:** No puedes usar la validación o el envío de emails en otros lugares fácilmente.

---

## Solución: Aplicando SRP

Dividimos las responsabilidades en clases separadas:

```python
class Usuario:
    def __init__(self, nombre, email):
        self.nombre = nombre
        self.email = email

class ValidadorEmail:
    @staticmethod
    def es_valido(email):
        return "@" in email

class RepositorioUsuarios:
    def guardar(self, usuario):
        print(f"Guardando usuario {usuario.nombre} en la base de datos")

class ServicioEmail:
    def enviar_bienvenida(self, usuario):
        print(f"Enviando email de bienvenida a {usuario.email}")

# Uso:
usuario = Usuario("Ana", "ana@ejemplo.com")
if ValidadorEmail.es_valido(usuario.email):
    repo = RepositorioUsuarios()
    repo.guardar(usuario)
    ServicioEmail().enviar_bienvenida(usuario)
else:
    print("Email inválido")
```

**¿Qué mejoró?**
- Cada clase tiene una sola responsabilidad.
- Puedes cambiar la validación, la base de datos o el email sin tocar las otras clases.
- Es más fácil de probar y mantener.

---

## Checklist para aplicar SRP
- [ ] ¿Tu clase o función hace solo una cosa?
- [ ] ¿Puedes describir su propósito en una sola frase?
- [ ] ¿Cambios en una parte del sistema requieren cambiar esta clase por más de una razón? (Si sí, separa responsabilidades)
- [ ] ¿Puedes probar cada parte de forma independiente?

---

## Resumen
El SRP te ayuda a escribir código más limpio, fácil de mantener y menos propenso a errores. Si una clase o función empieza a crecer y a hacer muchas cosas, ¡es momento de dividirla! 