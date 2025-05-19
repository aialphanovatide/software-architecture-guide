# Principio de Sustitución de Liskov (LSP)

> "Los subtipos deben poder sustituir a sus tipos base sin que el programa deje de funcionar correctamente."
> 
> — Barbara Liskov

## ¿Qué es el LSP?
El Principio de Sustitución de Liskov dice que si tienes una clase base y una subclase, deberías poder usar la subclase en lugar de la base sin que el programa falle o se comporte raro.

---

## Caso de uso: Procesadores de pago

Supón que tienes una plataforma SaaS que permite a los usuarios pagar su suscripción con tarjeta, PayPal o criptomonedas. El sistema espera que todos los procesadores de pago puedan procesar pagos y emitir reembolsos.

### Problema (antes de LSP)

```python
class ProcesadorPago:
    def procesar(self, monto):
        pass
    def reembolsar(self, id_transaccion):
        pass

class ProcesadorPagoTarjeta(ProcesadorPago):
    def procesar(self, monto):
        print(f"Pagando {monto} con tarjeta")
        return "id-tarjeta"
    def reembolsar(self, id_transaccion):
        print(f"Reembolsando {id_transaccion} con tarjeta")
        return True

class ProcesadorPagoCripto(ProcesadorPago):
    def procesar(self, monto):
        print(f"Pagando {monto} con cripto")
        return "id-cripto"
    def reembolsar(self, id_transaccion):
        # ¡Problema! No se puede reembolsar cripto automáticamente
        raise NotImplementedError("No se puede reembolsar pagos cripto")

# Uso:
def reembolsar_pago(procesador, monto):
    id_tx = procesador.procesar(monto)
    try:
        procesador.reembolsar(id_tx)
    except NotImplementedError:
        print("Este método de pago no soporta reembolsos automáticos")

reembolsar_pago(ProcesadorPagoTarjeta(), 100)  # OK
reembolsar_pago(ProcesadorPagoCripto(), 100)   # Falla
```

**¿Qué está mal aquí?**
- El sistema espera que todos los procesadores puedan reembolsar, pero cripto no puede.
- Usar la subclase `ProcesadorPagoCripto` en lugar de la base rompe el programa.

---

## ¿Por qué es un problema?
- **Errores inesperados:** El programa puede fallar en tiempo de ejecución.
- **Difícil de mantener:** No puedes confiar en que todas las subclases funcionen igual.
- **Rompe la lógica del cliente:** El código que usa la clase base no sabe si la subclase es compatible.

---

## Solución: Aplicando LSP

Ajustamos la jerarquía para que solo los procesadores que pueden reembolsar tengan ese método.

```python
from abc import ABC, abstractmethod

class ProcesadorPago(ABC):
    @abstractmethod
    def procesar(self, monto):
        pass

class ProcesadorReembolsable(ProcesadorPago):
    @abstractmethod
    def reembolsar(self, id_transaccion):
        pass

class ProcesadorPagoTarjeta(ProcesadorReembolsable):
    def procesar(self, monto):
        print(f"Pagando {monto} con tarjeta")
        return "id-tarjeta"
    def reembolsar(self, id_transaccion):
        print(f"Reembolsando {id_transaccion} con tarjeta")
        return True

class ProcesadorPagoCripto(ProcesadorPago):
    def procesar(self, monto):
        print(f"Pagando {monto} con cripto")
        return "id-cripto"

# Uso:
def reembolsar_pago(procesador, monto):
    id_tx = procesador.procesar(monto)
    if isinstance(procesador, ProcesadorReembolsable):
        procesador.reembolsar(id_tx)
    else:
        print("Este método de pago no soporta reembolsos automáticos")

reembolsar_pago(ProcesadorPagoTarjeta(), 100)  # OK
reembolsar_pago(ProcesadorPagoCripto(), 100)   # Mensaje claro
```

**¿Qué mejoró?**
- Ahora solo los procesadores que pueden reembolsar tienen ese método.
- El código cliente puede saber si un procesador soporta reembolsos.
- No hay sorpresas ni errores inesperados.

---

## Checklist para aplicar LSP
- [ ] ¿Puedes usar cualquier subclase en lugar de la clase base sin errores?
- [ ] ¿Las subclases cumplen todas las promesas de la clase base?
- [ ] ¿El código cliente no necesita saber detalles de la subclase?
- [ ] ¿Evitas lanzar excepciones inesperadas en métodos heredados?

---

## Resumen
El LSP te ayuda a crear jerarquías de clases seguras y predecibles. Si una subclase no puede cumplir lo que promete la clase base, ¡es mejor repensar la herencia o usar composición! 