# Servicios de Aplicación

Los servicios de aplicación actúan como una capa delgada que coordina la ejecución de operaciones de dominio y orquesta la infraestructura necesaria. Son el punto de entrada principal a la lógica de dominio desde interfaces externas.

## Propósito

Los servicios de aplicación tienen como objetivo:

- Proporcionar una API clara y consistente para el mundo exterior.
- Coordinar las operaciones de dominio sin contener lógica de negocio.
- Traducir DTO (Objetos de Transferencia de Datos) a objetos de dominio y viceversa.
- Gestionar transacciones, seguridad y otras preocupaciones técnicas.

## Características Principales

- **Orquestación**: Coordinan la ejecución de casos de uso sin implementar reglas de negocio.
- **Punto de entrada**: Actúan como fachadas para la lógica de dominio.
- **Administración técnica**: Gestionan preocupaciones técnicas como transacciones y seguridad.
- **Mapeo**: Convierten entre objetos de dominio y DTOs para interfaces externas.

## Implementación en Python

```python
from typing import List, Dict, Any, Optional
from uuid import UUID
import logging
from datetime import datetime

from domain.customer import Customer, CustomerStatus
from domain.repositories.customer_repository import CustomerRepository
from domain.services.customer_validation_service import CustomerValidationService

class CustomerApplicationService:
    """Servicio de aplicación para la gestión de clientes."""
    
    def __init__(
        self, 
        customer_repository: CustomerRepository,
        customer_validation_service: CustomerValidationService,
        unit_of_work
    ):
        self.customer_repository = customer_repository
        self.customer_validation_service = customer_validation_service
        self.unit_of_work = unit_of_work
        self.logger = logging.getLogger(__name__)
        
    def get_customer(self, customer_id: UUID) -> Optional[Dict[str, Any]]:
        """
        Recupera un cliente por su ID.
        Retorna un DTO con la información del cliente o None si no existe.
        """
        customer = self.customer_repository.find_by_id(customer_id)
        
        if not customer:
            self.logger.info(f"Cliente con ID {customer_id} no encontrado")
            return None
            
        return self._to_dto(customer)
    
    def get_all_customers(self) -> List[Dict[str, Any]]:
        """Recupera todos los clientes activos."""
        customers = self.customer_repository.find_all()
        return [self._to_dto(customer) for customer in customers]
    
    def create_customer(self, customer_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Crea un nuevo cliente.
        Retorna un DTO del cliente creado.
        """
        try:
            with self.unit_of_work:
                # Validar datos del cliente
                validation_result = self.customer_validation_service.validate_new_customer(
                    name=customer_data.get('name', ''),
                    email=customer_data.get('email', ''),
                    contact_info=customer_data.get('contact_info', {})
                )
                
                if not validation_result.is_valid:
                    self.logger.warning(f"Datos de cliente inválidos: {validation_result.errors}")
                    raise ValueError(f"Datos de cliente inválidos: {validation_result.errors}")
                
                # Crear entidad de dominio
                customer = Customer(
                    name=customer_data['name'],
                    email=customer_data['email'],
                    status=CustomerStatus.ACTIVE,
                    contact_info=customer_data.get('contact_info', {})
                )
                
                # Persistir en el repositorio
                self.customer_repository.save(customer)
                
                self.logger.info(f"Cliente creado con ID: {customer.id}")
                
                # Retornar DTO
                return self._to_dto(customer)
        except Exception as e:
            self.logger.error(f"Error al crear cliente: {str(e)}")
            raise
    
    def update_customer(self, customer_id: UUID, customer_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Actualiza un cliente existente.
        Retorna un DTO del cliente actualizado o None si no existe.
        """
        try:
            with self.unit_of_work:
                # Obtener cliente existente
                customer = self.customer_repository.find_by_id(customer_id)
                
                if not customer:
                    self.logger.warning(f"Cliente con ID {customer_id} no encontrado para actualización")
                    return None
                
                # Actualizar propiedades
                if 'name' in customer_data:
                    customer.update_name(customer_data['name'])
                    
                if 'email' in customer_data:
                    customer.update_email(customer_data['email'])
                    
                if 'status' in customer_data:
                    customer.update_status(CustomerStatus(customer_data['status']))
                    
                if 'contact_info' in customer_data:
                    customer.update_contact_info(customer_data['contact_info'])
                
                # Persistir cambios
                self.customer_repository.save(customer)
                
                self.logger.info(f"Cliente con ID {customer_id} actualizado")
                
                # Retornar DTO
                return self._to_dto(customer)
        except Exception as e:
            self.logger.error(f"Error al actualizar cliente {customer_id}: {str(e)}")
            raise
    
    def delete_customer(self, customer_id: UUID) -> bool:
        """
        Elimina lógicamente un cliente.
        Retorna True si el cliente fue eliminado, False si no existe.
        """
        try:
            with self.unit_of_work:
                customer = self.customer_repository.find_by_id(customer_id)
                
                if not customer:
                    self.logger.warning(f"Cliente con ID {customer_id} no encontrado para eliminación")
                    return False
                
                # Marcar como inactivo en lugar de eliminar físicamente
                customer.deactivate()
                self.customer_repository.save(customer)
                
                self.logger.info(f"Cliente con ID {customer_id} desactivado")
                return True
        except Exception as e:
            self.logger.error(f"Error al eliminar cliente {customer_id}: {str(e)}")
            raise
    
    def _to_dto(self, customer: Customer) -> Dict[str, Any]:
        """Convierte una entidad Cliente a un DTO."""
        return {
            'id': str(customer.id),
            'name': customer.name,
            'email': customer.email,
            'status': customer.status.value,
            'contact_info': customer.contact_info,
            'created_at': customer.created_at.isoformat() if customer.created_at else None,
            'updated_at': customer.updated_at.isoformat() if customer.updated_at else None
        }
```

## Implementación en TypeScript

```typescript
import { Injectable } from '@nestjs/common';
import { Logger } from '@nestjs/common';
import { CustomerRepository } from '../repositories/customer-repository';
import { CustomerValidationService } from '../domain/services/customer-validation-service';
import { Customer, CustomerStatus } from '../domain/customer';
import { UnitOfWork } from '../infrastructure/unit-of-work';
import { CustomerDto, CreateCustomerDto, UpdateCustomerDto } from '../dtos/customer-dto';

@Injectable()
export class CustomerApplicationService {
  private readonly logger = new Logger(CustomerApplicationService.name);

  constructor(
    private readonly customerRepository: CustomerRepository,
    private readonly customerValidationService: CustomerValidationService,
    private readonly unitOfWork: UnitOfWork
  ) {}

  async getCustomer(customerId: string): Promise<CustomerDto | null> {
    const customer = await this.customerRepository.findById(customerId);
    
    if (!customer) {
      this.logger.log(`Cliente con ID ${customerId} no encontrado`);
      return null;
    }
    
    return this.toDto(customer);
  }

  async getAllCustomers(): Promise<CustomerDto[]> {
    const customers = await this.customerRepository.findAll();
    return customers.map(customer => this.toDto(customer));
  }

  async createCustomer(customerData: CreateCustomerDto): Promise<CustomerDto> {
    try {
      return await this.unitOfWork.execute(async () => {
        // Validar datos del cliente
        const validationResult = this.customerValidationService.validateNewCustomer({
          name: customerData.name,
          email: customerData.email,
          contactInfo: customerData.contactInfo || {}
        });
        
        if (!validationResult.isValid) {
          this.logger.warn(`Datos de cliente inválidos: ${validationResult.errors}`);
          throw new Error(`Datos de cliente inválidos: ${validationResult.errors}`);
        }
        
        // Crear entidad de dominio
        const customer = new Customer({
          name: customerData.name,
          email: customerData.email,
          status: CustomerStatus.ACTIVE,
          contactInfo: customerData.contactInfo || {}
        });
        
        // Persistir en el repositorio
        await this.customerRepository.save(customer);
        
        this.logger.log(`Cliente creado con ID: ${customer.id}`);
        
        // Retornar DTO
        return this.toDto(customer);
      });
    } catch (error) {
      this.logger.error(`Error al crear cliente: ${error.message}`);
      throw error;
    }
  }

  async updateCustomer(customerId: string, customerData: UpdateCustomerDto): Promise<CustomerDto | null> {
    try {
      return await this.unitOfWork.execute(async () => {
        // Obtener cliente existente
        const customer = await this.customerRepository.findById(customerId);
        
        if (!customer) {
          this.logger.warn(`Cliente con ID ${customerId} no encontrado para actualización`);
          return null;
        }
        
        // Actualizar propiedades
        if (customerData.name !== undefined) {
          customer.updateName(customerData.name);
        }
        
        if (customerData.email !== undefined) {
          customer.updateEmail(customerData.email);
        }
        
        if (customerData.status !== undefined) {
          customer.updateStatus(customerData.status);
        }
        
        if (customerData.contactInfo !== undefined) {
          customer.updateContactInfo(customerData.contactInfo);
        }
        
        // Persistir cambios
        await this.customerRepository.save(customer);
        
        this.logger.log(`Cliente con ID ${customerId} actualizado`);
        
        // Retornar DTO
        return this.toDto(customer);
      });
    } catch (error) {
      this.logger.error(`Error al actualizar cliente ${customerId}: ${error.message}`);
      throw error;
    }
  }

  async deleteCustomer(customerId: string): Promise<boolean> {
    try {
      return await this.unitOfWork.execute(async () => {
        const customer = await this.customerRepository.findById(customerId);
        
        if (!customer) {
          this.logger.warn(`Cliente con ID ${customerId} no encontrado para eliminación`);
          return false;
        }
        
        // Marcar como inactivo en lugar de eliminar físicamente
        customer.deactivate();
        await this.customerRepository.save(customer);
        
        this.logger.log(`Cliente con ID ${customerId} desactivado`);
        return true;
      });
    } catch (error) {
      this.logger.error(`Error al eliminar cliente ${customerId}: ${error.message}`);
      throw error;
    }
  }

  private toDto(customer: Customer): CustomerDto {
    return {
      id: customer.id,
      name: customer.name,
      email: customer.email,
      status: customer.status,
      contactInfo: customer.contactInfo,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt
    };
  }
}
```

## Responsabilidades vs. Servicios de Dominio

| Servicios de Aplicación | Servicios de Dominio |
|------------------------|----------------------|
| Preocupaciones técnicas (transacciones, seguridad) | Lógica de negocio pura |
| Conversión DTO - entidades de dominio | Operaciones entre agregados |
| Manejo de excepciones y logs | Sin conocimiento de infraestructura |
| Coordinación entre repositorios y servicios | Sin manejo de aspectos técnicos |
| Validación de entrada | Validación de reglas de negocio |

## Patrones Comunes

1. **Patrón Comando/Consulta (CQRS)**: Separar operaciones de lectura y escritura en diferentes servicios de aplicación.
2. **Transformación DTO**: Convertir DTOs de entrada a objetos de dominio y viceversa para resultados.
3. **Patrón Unidad de Trabajo**: Coordinar transacciones entre múltiples operaciones de repositorio.
4. **Supervisión y Observabilidad**: Implementar registro de actividades, métricas y seguimiento.

## Mejores Prácticas

1. **Delgado pero Completo**: Mantener los servicios de aplicación enfocados en la orquestación, pero asegurarse de que cubran todas las preocupaciones técnicas necesarias.
2. **Independencia de Tecnología UI**: Diseñar servicios de aplicación independientes de tecnologías de interfaz específicas.
3. **Límites Claros**: Establecer límites claros entre infraestructura, aplicación y dominio.
4. **Manejo de Errores**: Implementar estrategias consistentes de manejo de errores y excepciones.
5. **Inyección de Dependencias**: Utilizar inyección para servicios y repositorios de dominio.
6. **Validación Temprana**: Validar entradas antes de invocar lógica de dominio para evitar corrupciones.

# Servicios de Aplicación: Ejemplo de Wallets

Los **servicios de aplicación** orquestan casos de uso, coordinando entidades, servicios de dominio y repositorios. No contienen lógica de negocio compleja, sino que gestionan flujos y validaciones de alto nivel.

## DTOs para Wallets

```python
from pydantic import BaseModel
from uuid import UUID
from decimal import Decimal

class CreateWalletDTO(BaseModel):
    user_id: UUID
    organization_id: UUID

class TransferFundsDTO(BaseModel):
    from_wallet_id: UUID
    to_wallet_id: UUID
    amount: Decimal
    currency_code: str

class TopUpDTO(BaseModel):
    wallet_id: UUID
    amount: Decimal
    currency_code: str
```

## Servicio de Aplicación para Wallets

```python
class WalletApplicationService:
    def __init__(self, wallet_repository, transfer_service):
        self.wallet_repository = wallet_repository
        self.transfer_service = transfer_service

    def create_wallet(self, dto: CreateWalletDTO):
        # Validar que el usuario pertenece a la organización
        wallet = Wallet(
            id=uuid4(),
            user_id=dto.user_id,
            organization_id=dto.organization_id,
            status='ACTIVE',
            balances={}
        )
        self.wallet_repository.save(wallet)
        return wallet

    def transfer_funds(self, dto: TransferFundsDTO):
        self.transfer_service.transfer(
            dto.from_wallet_id,
            dto.to_wallet_id,
            dto.amount,
            dto.currency_code
        )

    def top_up_wallet(self, dto: TopUpDTO):
        wallet = self.wallet_repository.find_by_id(dto.wallet_id)
        if not wallet:
            raise ValueError('Wallet not found')
        wallet.add_balance(dto.currency_code, dto.amount)
        self.wallet_repository.save(wallet)
```

## Resumen
Los servicios de aplicación coordinan los casos de uso del dominio, asegurando validaciones y orquestando la lógica de negocio sin mezclar detalles de infraestructura. 