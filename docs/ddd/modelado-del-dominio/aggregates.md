# Agregados en DDD: Concepto y Ejemplo Paso a Paso

En el Diseño Dirigido por el Dominio (DDD), los **agregados** ayudan a mantener la consistencia y simplicidad en sistemas complejos. Aquí aprenderás qué son, para qué sirven y cómo aplicarlos usando un ejemplo de billeteras digitales (wallets).

---

## Glosario de Términos

| Término         | Definición                                                                 |
|-----------------|----------------------------------------------------------------------------|
| Agregado        | Grupo de entidades y objetos de valor que deben mantenerse consistentes     |
| Raíz de Agregado| Entidad principal que controla el acceso y las modificaciones al agregado   |
| Invariante      | Regla de negocio que siempre debe cumplirse dentro del agregado             |

---

## ¿Qué es un Agregado?

Un **agregado** es como una "caja fuerte" que agrupa entidades y objetos de valor relacionados. Solo se puede modificar su contenido a través de una única puerta: la **raíz del agregado**. Así, garantizamos que las reglas de negocio (invariantes) nunca se rompan.

- **¿Por qué usar agregados?**
  - Mantienen la consistencia de los datos
  - Simplifican el modelo de dominio
  - Facilitan el trabajo en equipo y la evolución del sistema

---

## Ejemplo Práctico: Wallet como Agregado

Imagina una plataforma donde los usuarios tienen varias wallets (billeteras) en diferentes monedas. Queremos garantizar:
- No transferir más dinero del que hay
- Que ambas wallets sean de la misma organización
- Que los cambios sean atómicos (todo o nada)

### 1. Definimos las Entidades y Objetos de Valor

```python
from uuid import UUID
from dataclasses import dataclass, field
from typing import Dict
from decimal import Decimal

@dataclass(frozen=True)
class Balance:
    """Objeto de valor: representa el saldo en una moneda específica"""
    currency_code: str
    amount: Decimal

@dataclass
class Wallet:
    """Entidad y raíz del agregado: controla el acceso y las reglas"""
    id: UUID
    user_id: UUID
    organization_id: UUID
    status: str  # 'ACTIVE', 'FROZEN', 'CLOSED'
    balances: Dict[str, Balance] = field(default_factory=dict)

    def transfer_to(self, to_wallet: 'Wallet', amount: Decimal, currency_code: str):
        """Transfiere saldo a otra wallet, cumpliendo las reglas del dominio"""
        # 1. Ambas wallets deben estar activas
        if self.status != 'ACTIVE' or to_wallet.status != 'ACTIVE':
            raise ValueError('Ambas wallets deben estar ACTIVAS')
        # 2. Deben ser de la misma organización
        if self.organization_id != to_wallet.organization_id:
            raise ValueError('Las wallets deben ser de la misma organización')
        # 3. No se puede transferir más de lo que hay
        saldo_actual = self.balances.get(currency_code, Balance(currency_code, Decimal('0'))).amount
        if saldo_actual < amount:
            raise ValueError('Saldo insuficiente')
        # 4. Actualización atómica
        self.balances[currency_code] = Balance(currency_code, saldo_actual - amount)
        to_wallet.add_balance(currency_code, amount)

    def add_balance(self, currency_code: str, amount: Decimal):
        """Agrega saldo a la wallet en la moneda indicada"""
        saldo_actual = self.balances.get(currency_code, Balance(currency_code, Decimal('0'))).amount
        self.balances[currency_code] = Balance(currency_code, saldo_actual + amount)

# Ejemplo de uso:
# Transferir 100 USDC de una wallet a otra (misma organización)
wallet_a.transfer_to(wallet_b, Decimal('100'), 'USDC')
```

---

## ¿Qué aprendimos?

- **Solo la raíz del agregado** (`Wallet`) puede modificar el estado interno y aplicar las reglas.
- Las **invariantes** (reglas de negocio) se verifican siempre antes de modificar el estado.
- El modelo es fácil de entender y mantener, incluso cuando el sistema crece.

---

## Reglas de Oro para Agregados

- ✅ Define claramente la raíz del agregado
- ✅ Todas las modificaciones deben pasar por la raíz
- ✅ Protege las invariantes del dominio dentro del agregado
- ✅ Mantén los agregados pequeños y enfocados
- ✅ Usa ejemplos y pruebas para validar las reglas

> **Recuerda:** ¡Siempre que quieras modificar algo importante, hazlo a través de la raíz del agregado! 