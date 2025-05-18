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

## Antipatrones

- **Repositorios genéricos**: Usar un único repositorio genérico para todos los tipos de entidades va en contra del principio de diseño específico del dominio.
- **Dependencia directa de ORM**: Inyectar directamente frameworks ORM en el código de dominio rompe el principio de inversión de dependencias.
- **Repositorio como servicio**: Usar repositorios para implementar lógica de negocio en lugar de solo acceso a datos.

## Consideraciones de Rendimiento

- **Caching**: Implementar estrategias de caché para repositorios de acceso frecuente.
- **Carga diferida vs. Carga ansiosa**: Elegir estrategias apropiadas según el contexto de uso.
- **Optimización de consultas**: Asegurar que las consultas a la base de datos estén optimizadas. 