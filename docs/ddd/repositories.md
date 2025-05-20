# Repositorios

Los repositorios son una abstracción que proporciona una interfaz entre el dominio y las capas de infraestructura para acceder a los datos de los agregados.

## Propósito

Un repositorio encapsula la lógica necesaria para obtener objetos de dominio. Proporciona una colección de interfaces similares para acceder a los objetos de dominio y gestionar su ciclo de vida.

## Características Principales

- **Abstracción de Persistencia**: Oculta los detalles de la persistencia de datos del código de dominio.
- **Orientado a Colecciones**: Actúa como una colección en memoria, permitiendo agregar, eliminar y buscar objetos.
- **Enfoque en Agregados**: Cada repositorio se enfoca en un único tipo de agregado.
- **Desacoplamiento**: Permite cambiar las tecnologías de persistencia sin afectar la lógica de negocio.

## Implementación en Python

```python
from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID

from domain.customer import Customer

class CustomerRepository(ABC):
    """Interfaz de repositorio para el agregado Customer."""
    
    @abstractmethod
    def find_by_id(self, customer_id: UUID) -> Optional[Customer]:
        """Busca un cliente por su ID."""
        pass
    
    @abstractmethod
    def find_all(self) -> List[Customer]:
        """Recupera todos los clientes."""
        pass
    
    @abstractmethod
    def save(self, customer: Customer) -> None:
        """Guarda un cliente (crea o actualiza)."""
        pass
    
    @abstractmethod
    def delete(self, customer_id: UUID) -> None:
        """Elimina un cliente por su ID."""
        pass


# Implementación concreta usando PostgreSQL
class PostgresCustomerRepository(CustomerRepository):
    def __init__(self, db_session):
        self.db_session = db_session
    
    def find_by_id(self, customer_id: UUID) -> Optional[Customer]:
        # Implementación específica para PostgreSQL
        customer_data = self.db_session.execute(
            "SELECT * FROM customers WHERE id = %s", (str(customer_id),)
        ).fetchone()
        
        if not customer_data:
            return None
            
        return Customer.from_dict(dict(customer_data))
    
    def find_all(self) -> List[Customer]:
        customers = []
        customer_rows = self.db_session.execute("SELECT * FROM customers").fetchall()
        
        for row in customer_rows:
            customers.append(Customer.from_dict(dict(row)))
            
        return customers
    
    def save(self, customer: Customer) -> None:
        # Lógica para insertar o actualizar
        existing = self.find_by_id(customer.id)
        
        if existing:
            # Actualizar
            self.db_session.execute(
                """
                UPDATE customers 
                SET name = %s, email = %s, status = %s, updated_at = NOW()
                WHERE id = %s
                """,
                (customer.name, customer.email, customer.status, str(customer.id))
            )
        else:
            # Insertar
            self.db_session.execute(
                """
                INSERT INTO customers (id, name, email, status, created_at, updated_at)
                VALUES (%s, %s, %s, %s, NOW(), NOW())
                """,
                (str(customer.id), customer.name, customer.email, customer.status)
            )
        
        self.db_session.commit()
    
    def delete(self, customer_id: UUID) -> None:
        self.db_session.execute(
            "DELETE FROM customers WHERE id = %s",
            (str(customer_id),)
        )
        self.db_session.commit()
```

## Implementación en TypeScript

```typescript
import { Customer, CustomerStatus } from '../domain/customer';

export interface CustomerRepository {
  findById(id: string): Promise<Customer | null>;
  findAll(): Promise<Customer[]>;
  save(customer: Customer): Promise<void>;
  delete(id: string): Promise<void>;
}

// Implementación usando PostgreSQL con TypeORM
export class PostgresCustomerRepository implements CustomerRepository {
  constructor(private readonly connection: any) {}

  async findById(id: string): Promise<Customer | null> {
    const customerData = await this.connection.query(
      'SELECT * FROM customers WHERE id = $1',
      [id]
    );

    if (!customerData || customerData.length === 0) {
      return null;
    }

    return this.mapToCustomer(customerData[0]);
  }

  async findAll(): Promise<Customer[]> {
    const customersData = await this.connection.query('SELECT * FROM customers');
    return customersData.map(this.mapToCustomer);
  }

  async save(customer: Customer): Promise<void> {
    const existing = await this.findById(customer.id);

    if (existing) {
      // Actualizar
      await this.connection.query(
        `UPDATE customers 
         SET name = $1, email = $2, status = $3, updated_at = NOW()
         WHERE id = $4`,
        [customer.name, customer.email, customer.status, customer.id]
      );
    } else {
      // Insertar
      await this.connection.query(
        `INSERT INTO customers (id, name, email, status, created_at, updated_at)
         VALUES ($1, $2, $3, $4, NOW(), NOW())`,
        [customer.id, customer.name, customer.email, customer.status]
      );
    }
  }

  async delete(id: string): Promise<void> {
    await this.connection.query('DELETE FROM customers WHERE id = $1', [id]);
  }

  private mapToCustomer(data: any): Customer {
    return new Customer({
      id: data.id,
      name: data.name,
      email: data.email,
      status: data.status as CustomerStatus,
      createdAt: data.created_at,
      updatedAt: data.updated_at
    });
  }
}
```

## Mejores Prácticas

1. **Respetar los límites de los agregados**: Un repositorio debe trabajar con un único tipo de agregado.
2. **Transaccionalidad**: Garantizar consistencia en operaciones que afectan a múltiples agregados.
3. **Minimizar la exposición**: No exponer detalles de implementación de persistencia.
4. **Inyección de dependencias**: Utilizar inyección para facilitar pruebas y cambios de implementación.
5. **Devolver objetos de dominio**: El repositorio siempre debe devolver entidades o agregados completos, no DTOs o estructuras de datos simples.

## Patrón Unit of Work (Unidad de Trabajo)

El patrón Unit of Work complementa al patrón Repository proporcionando un mecanismo para coordinar transacciones entre múltiples repositorios, garantizando la consistencia de los datos cuando se modifican varios agregados.

### Propósito

- **Mantener consistencia transaccional**: Asegurar que múltiples operaciones de persistencia se realicen dentro de una única transacción.
- **Gestionar cambios en conjunto**: Agrupar operaciones relacionadas que deben ejecutarse como una unidad atómica.
- **Sincronizar cambios**: Controlar cuándo los cambios se confirman en la base de datos subyacente.

### Implementación en Python

```python
from abc import ABC, abstractmethod
from sqlalchemy.orm import Session

class UnitOfWork(ABC):
    """Interfaz para el patrón Unit of Work."""
    
    @abstractmethod
    def __enter__(self):
        """Inicia una nueva transacción."""
        pass
        
    @abstractmethod
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Finaliza la transacción actual (commit o rollback)."""
        pass
        
    @abstractmethod
    def commit(self):
        """Confirma los cambios actuales."""
        pass
        
    @abstractmethod
    def rollback(self):
        """Revierte los cambios actuales."""
        pass


class SqlAlchemyUnitOfWork(UnitOfWork):
    """Implementación de Unit of Work usando SQLAlchemy."""
    
    def __init__(self, session_factory):
        self.session_factory = session_factory
        self.session = None
        
    def __enter__(self):
        self.session = self.session_factory()
        # Crear los repositorios con la sesión actual
        self.customers = PostgresCustomerRepository(self.session)
        self.orders = PostgresOrderRepository(self.session)
        return self
        
    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type:
            self.rollback()
        self.session.close()
        
    def commit(self):
        self.session.commit()
        
    def rollback(self):
        self.session.rollback()


# Uso del Unit of Work
def transfer_money(from_id, to_id, amount, uow_factory):
    with uow_factory() as uow:
        try:
            # Obtener las cuentas
            from_account = uow.accounts.find_by_id(from_id)
            to_account = uow.accounts.find_by_id(to_id)
            
            # Realizar la transferencia
            from_account.withdraw(amount)
            to_account.deposit(amount)
            
            # Guardar los cambios
            uow.accounts.save(from_account)
            uow.accounts.save(to_account)
            
            # Confirmar todos los cambios en una transacción
            uow.commit()
            
        except Exception as e:
            # En caso de error, automáticamente se hace rollback
            # gracias al bloque __exit__ del with
            print(f"Error durante la transferencia: {e}")
            raise
```

### Implementación en TypeScript

```typescript
interface UnitOfWork {
  begin(): Promise<void>;
  commit(): Promise<void>;
  rollback(): Promise<void>;
  getCustomerRepository(): CustomerRepository;
  getOrderRepository(): OrderRepository;
}

class PostgresUnitOfWork implements UnitOfWork {
  private connection: any;
  private customerRepository: CustomerRepository | null = null;
  private orderRepository: OrderRepository | null = null;

  constructor(private readonly connectionFactory: () => Promise<any>) {}

  async begin(): Promise<void> {
    this.connection = await this.connectionFactory();
    await this.connection.query('BEGIN');
  }

  async commit(): Promise<void> {
    await this.connection.query('COMMIT');
    await this.close();
  }

  async rollback(): Promise<void> {
    try {
      await this.connection.query('ROLLBACK');
    } finally {
      await this.close();
    }
  }

  getCustomerRepository(): CustomerRepository {
    if (!this.customerRepository) {
      this.customerRepository = new PostgresCustomerRepository(this.connection);
    }
    return this.customerRepository;
  }

  getOrderRepository(): OrderRepository {
    if (!this.orderRepository) {
      this.orderRepository = new PostgresOrderRepository(this.connection);
    }
    return this.orderRepository;
  }

  private async close(): Promise<void> {
    if (this.connection) {
      await this.connection.release();
      this.connection = null;
    }
  }
}

// Uso del Unit of Work
async function transferMoney(fromId: string, toId: string, amount: number): Promise<void> {
  const uow = new PostgresUnitOfWork(getConnectionFactory());
  
  try {
    await uow.begin();
    
    const accountRepo = uow.getAccountRepository();
    const fromAccount = await accountRepo.findById(fromId);
    const toAccount = await accountRepo.findById(toId);
    
    if (!fromAccount || !toAccount) {
      throw new Error('Una o ambas cuentas no existen');
    }
    
    fromAccount.withdraw(amount);
    toAccount.deposit(amount);
    
    await accountRepo.save(fromAccount);
    await accountRepo.save(toAccount);
    
    await uow.commit();
  } catch (error) {
    await uow.rollback();
    throw error;
  }
}
```

### Beneficios del Unit of Work

1. **Integridad de datos**: Garantiza que las operaciones relacionadas se realicen completamente o se reviertan completamente.
2. **Simplificación del código**: Centraliza la lógica de gestión de transacciones.
3. **Desacoplamiento**: Separa la gestión transaccional de la lógica de negocio.
4. **Mejora la testabilidad**: Facilita la simulación (mocking) de la persistencia en pruebas unitarias.

## Antipatrones

- **Repositorios genéricos**: Usar un único repositorio genérico para todos los tipos de entidades va en contra del principio de diseño específico del dominio.
- **Dependencia directa de ORM**: Inyectar directamente frameworks ORM en el código de dominio rompe el principio de inversión de dependencias.
- **Repositorio como servicio**: Usar repositorios para implementar lógica de negocio en lugar de solo acceso a datos.

## Consideraciones de Rendimiento

- **Caching**: Implementar estrategias de caché para repositorios de acceso frecuente.
- **Carga diferida vs. Carga ansiosa**: Elegir estrategias apropiadas según el contexto de uso.
- **Optimización de consultas**: Asegurar que las consultas a la base de datos estén optimizadas.

# Repositorios: Ejemplo de WalletRepository

Los **repositorios** abstraen el acceso a los agregados, permitiendo recuperar y persistir entidades del dominio sin exponer detalles de infraestructura.

## Interfaz de WalletRepository

```python
from abc import ABC, abstractmethod
from typing import Optional
from uuid import UUID
from .entities import Wallet

class WalletRepository(ABC):
    @abstractmethod
    def find_by_id(self, wallet_id: UUID) -> Optional[Wallet]:
        pass

    @abstractmethod
    def save(self, wallet: Wallet) -> None:
        pass
```

## Implementación Básica (ejemplo con SQLAlchemy)

```python
class SqlAlchemyWalletRepository(WalletRepository):
    def __init__(self, session):
        self.session = session

    def find_by_id(self, wallet_id: UUID) -> Optional[Wallet]:
        # Buscar en la base de datos y mapear a entidad Wallet
        ...

    def save(self, wallet: Wallet) -> None:
        # Insertar o actualizar la wallet en la base de datos
        ...
```

## Uso con Unit of Work

El patrón Unit of Work coordina transacciones entre múltiples repositorios:

```python
def transfer_funds(from_wallet_id, to_wallet_id, amount, currency_code, uow_factory):
    with uow_factory() as uow:
        from_wallet = uow.wallets.find_by_id(from_wallet_id)
        to_wallet = uow.wallets.find_by_id(to_wallet_id)
        from_wallet.transfer(to_wallet, amount, currency_code)
        uow.wallets.save(from_wallet)
        uow.wallets.save(to_wallet)
        uow.commit()
```

## Mejores Prácticas
- Un repositorio por agregado
- No exponer detalles de infraestructura
- Devolver entidades completas
- Integrar con Unit of Work para consistencia transaccional 