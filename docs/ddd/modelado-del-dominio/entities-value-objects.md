# Entidades y Objetos de Valor en DDD: Ejemplo de Wallets

En DDD, las **entidades** y **objetos de valor** son los bloques fundamentales para modelar el dominio. Usaremos el dominio de gestión de wallets (billeteras digitales) para ilustrar estos conceptos.

## Entidades

Las entidades tienen identidad propia y persisten a lo largo del tiempo, incluso si sus atributos cambian.

### Ejemplo: Organization, User y Wallet

```python
from uuid import UUID, uuid4
from dataclasses import dataclass, field
from typing import Dict
from decimal import Decimal

@dataclass
class Organization:
    id: UUID
    name: str

@dataclass
class User:
    id: UUID
    organization_id: UUID
    email: str
    status: str  # 'ACTIVE', 'DISABLED'

@dataclass
class Wallet:
    id: UUID
    user_id: UUID
    organization_id: UUID
    status: str  # 'ACTIVE', 'FROZEN', 'CLOSED'
    balances: Dict[str, 'Balance'] = field(default_factory=dict)

    def add_balance(self, currency_code: str, amount: Decimal):
        if currency_code not in self.balances:
            self.balances[currency_code] = Balance(currency_code, Decimal('0'))
        self.balances[currency_code].amount += amount

    def deduct_balance(self, currency_code: str, amount: Decimal):
        if currency_code not in self.balances or self.balances[currency_code].amount < amount:
            raise ValueError('Insufficient balance')
        self.balances[currency_code].amount -= amount
```

## Objetos de Valor

Los objetos de valor no tienen identidad propia y son definidos solo por sus atributos. Son inmutables.

### Ejemplo: Balance y Currency

```python
from dataclasses import dataclass
from decimal import Decimal

@dataclass(frozen=True)
class Currency:
    code: str  # e.g., 'USD', 'BTC', 'USDC'
    name: str
    decimals: int = 2

@dataclass
class Balance:
    currency_code: str
    amount: Decimal
```

## Relaciones
- **Organization** tiene muchos **User**
- **User** tiene muchas **Wallet**
- **Wallet** tiene muchos **Balance** (uno por moneda)

## Resumen
Este modelo permite gestionar múltiples wallets por usuario, con soporte multimoneda y control de estados, aplicando los principios de DDD para separar claramente entidades y objetos de valor. 