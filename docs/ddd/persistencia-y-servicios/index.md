# Persistencia y Servicios

Esta sección aborda cómo interactuar con los modelos de dominio y cómo expresar operaciones complejas que no encajan naturalmente en entidades específicas.

## ¿Qué aprenderás en esta sección?

En esta sección exploraremos:

1. [**Repositorios**](repositories.md): Abstracciones para el acceso y persistencia de entidades y agregados
2. [**Servicios de Dominio**](domain-services.md): Operaciones de dominio que no pertenecen a una entidad específica

## ¿Por qué es importante?

Estos conceptos son cruciales porque:

- **Separan preocupaciones**: Aíslan el modelo de dominio de los detalles de infraestructura
- **Expresan operaciones complejas**: Permiten modelar procesos que involucran múltiples entidades
- **Facilitan pruebas**: Hacen que el código sea más testeable mediante abstracciones
- **Mejoran la mantenibilidad**: Centralizan la lógica de acceso a datos y operaciones entre entidades

## Relación con otros conceptos

La persistencia y los servicios establecen conexiones esenciales:

- Se basan en el [**Modelado del Dominio**](../modelado-del-dominio/index.md) para manipular entidades y agregados
- Preparan el terreno para las [**Capas de Aplicación**](../capas-de-aplicacion/index.md) que orquestan casos de uso
- Contribuyen a la [**Organización y Escalado**](../organizacion-y-escalado/index.md) de sistemas complejos

## Ejemplo Práctico

En nuestro sistema financiero, vemos estos conceptos en acción:

```python
# Repositorio (abstracción)
class WalletRepository(ABC):
    @abstractmethod
    def find_by_id(self, wallet_id: UUID) -> Optional[Wallet]:
        pass
    
    @abstractmethod
    def save(self, wallet: Wallet) -> None:
        pass

# Servicio de Dominio
class TransferService:
    def validate_and_process_transfer(self, from_wallet: Wallet, 
                                      to_wallet: Wallet, 
                                      amount: Decimal,
                                      currency_code: str) -> None:
        # Lógica que no pertenece naturalmente a una sola Wallet
        if from_wallet.organization_id != to_wallet.organization_id:
            raise DomainError("Transferencias entre organizaciones no permitidas")
            
        # Más reglas de validación...
        
        # Ejecución de la transferencia utilizando métodos de las entidades
        from_wallet.deduct_funds(amount, currency_code)
        to_wallet.add_funds(amount, currency_code)
```

Este código muestra cómo:
- Los repositorios proporcionan una interfaz clara para acceder a los agregados
- Los servicios de dominio encapsulan lógica que involucra múltiples entidades
- Se mantiene la integridad del modelo sin exponer detalles de implementación

## Próximos Pasos

Una vez comprendidos estos conceptos, te recomendamos explorar las [Capas de Aplicación](../capas-de-aplicacion/index.md), donde aprenderás a orquestar operaciones completas del sistema y comunicarte con el mundo exterior. 