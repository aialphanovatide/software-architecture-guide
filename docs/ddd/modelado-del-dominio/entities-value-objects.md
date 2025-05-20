# Entidades y Objetos de Valor

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

## Ciclo de Vida de las Entidades

A diferencia de los objetos de valor, las entidades en DDD tienen un ciclo de vida bien definido que debe gestionarse a lo largo del tiempo. Entender este ciclo de vida es fundamental para implementar correctamente el dominio.

### Fases del Ciclo de Vida

1. **Creación**: Cuando una entidad se instancia por primera vez. En este momento debe asignarse su identidad.
2. **Reconstitución**: Cuando una entidad se recupera desde el almacenamiento (base de datos).
3. **Modificación**: Cuando se aplican cambios al estado de la entidad.
4. **Persistencia**: Cuando la entidad se guarda en almacenamiento.
5. **Archivado/Eliminación**: Cuando la entidad llega al final de su vida útil.

### Patrones para Gestionar el Ciclo de Vida

Para gestionar adecuadamente el ciclo de vida de las entidades, DDD utiliza tres patrones principales:

#### 1. Factories (Fábricas)

Las fábricas encapsulan la lógica de creación de entidades y agregados complejos, garantizando que se creen en un estado válido y consistente.

```python
class WalletFactory:
    @staticmethod
    def create_wallet(user_id: UUID, organization_id: UUID) -> Wallet:
        # Validaciones de negocio antes de crear la wallet
        # ...
        
        # Crear la wallet con un nuevo ID
        wallet_id = uuid4()
        return Wallet(
            id=wallet_id,
            user_id=user_id,
            organization_id=organization_id,
            status='ACTIVE'
        )
        
    @staticmethod
    def create_frozen_wallet(user_id: UUID, organization_id: UUID) -> Wallet:
        wallet = WalletFactory.create_wallet(user_id, organization_id)
        wallet.status = 'FROZEN'
        return wallet
```

#### 2. Repositories (Repositorios)

Los repositorios abstraen la lógica de persistencia y recuperación de entidades, permitiendo trabajar con ellas sin conocer los detalles de almacenamiento.

```python
class WalletRepository:
    def save(self, wallet: Wallet) -> None:
        """Persiste una wallet en la base de datos"""
        pass
        
    def find_by_id(self, wallet_id: UUID) -> Wallet:
        """Recupera una wallet por su ID"""
        pass
        
    def find_by_user_id(self, user_id: UUID) -> list[Wallet]:
        """Encuentra todas las wallets de un usuario"""
        pass
```

#### 3. Aggregates (Agregados)

Los agregados definen límites de consistencia y transaccionalidad alrededor de entidades relacionadas, tratándolas como una unidad. En nuestro ejemplo, `Wallet` sería la raíz de un agregado que contiene múltiples `Balance`.

### Ejemplo de Ciclo de Vida Completo

```python
# 1. Creación - Usando una Factory
wallet = WalletFactory.create_wallet(user_id, organization_id)

# 2. Modificación - Aplicando operaciones de dominio
wallet.add_balance('USD', Decimal('100.00'))
wallet.status = 'FROZEN'  # Congelar la wallet

# 3. Persistencia - Usando un Repository
wallet_repository.save(wallet)

# 4. Reconstitución - Recuperando de almacenamiento
recovered_wallet = wallet_repository.find_by_id(wallet.id)

# 5. Eliminación lógica
recovered_wallet.status = 'CLOSED'
wallet_repository.save(recovered_wallet)
```

### Consideraciones sobre el Ciclo de Vida

- **Inmutabilidad de la identidad**: Aunque el estado de una entidad cambie, su identidad debe permanecer constante.
- **Validación de invariantes**: En cada cambio de estado debe garantizarse que las reglas de negocio se cumplan.
- **Transacciones**: Los cambios en un agregado deben ser atómicos para mantener la consistencia.
- **Eventos de dominio**: Pueden utilizarse para notificar cambios importantes en el ciclo de vida.

## Relaciones
- **Organization** tiene muchos **User**
- **User** tiene muchas **Wallet**
- **Wallet** tiene muchos **Balance** (uno por moneda)

## Resumen
Este modelo permite gestionar múltiples wallets por usuario, con soporte multimoneda y control de estados, aplicando los principios de DDD para separar claramente entidades y objetos de valor. 