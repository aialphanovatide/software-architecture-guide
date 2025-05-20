# Capas de Aplicación

Las capas de aplicación constituyen el puente entre el núcleo del dominio y los sistemas externos, orquestando los casos de uso del sistema y proporcionando interfaces bien definidas.

## ¿Qué aprenderás en esta sección?

En esta sección cubriremos:

1. [**Data Transfer Objects (DTOs)**](data-transfer-objects.md): Objetos dedicados a la transferencia de datos entre capas
2. [**Servicios de Aplicación**](application-services.md): Orquestadores de los casos de uso que conectan el dominio con el exterior

## ¿Por qué es importante?

Las capas de aplicación son fundamentales porque:

- **Protegen el dominio**: Evitan que las preocupaciones externas contaminen la lógica de negocio
- **Simplifican interfaces**: Presentan APIs coherentes y enfocadas en casos de uso
- **Mejoran testabilidad**: Permiten probar la lógica de orquestación independientemente
- **Centralizan responsabilidades transversales**: Como autorización, validación y transacciones

## Relación con otros conceptos

Las capas de aplicación conectan varios componentes:

- Utilizan los modelos del [**Modelado del Dominio**](../modelado-del-dominio/index.md) como base de la lógica
- Consumen [**Persistencia y Servicios**](../persistencia-y-servicios/index.md) para manipular datos
- Contribuyen a la [**Organización y Escalado**](../organizacion-y-escalado/index.md) definiendo límites claros

## Ejemplo Práctico

Veamos cómo funcionan las capas de aplicación en nuestro sistema financiero:

```python
# DTO para entrada de datos
@dataclass
class TransferFundsDTO:
    from_wallet_id: UUID
    to_wallet_id: UUID
    amount: Decimal
    currency_code: str
    user_id: UUID  # Para autorización

# Servicio de Aplicación
class WalletApplicationService:
    def __init__(self, wallet_repository, transfer_service, authorization_service):
        self.wallet_repository = wallet_repository
        self.transfer_service = transfer_service
        self.authorization_service = authorization_service
    
    def transfer_funds(self, dto: TransferFundsDTO) -> None:
        # Autorización (preocupación de aplicación)
        self.authorization_service.ensure_can_manage_wallet(dto.user_id, dto.from_wallet_id)
        
        # Recuperación de agregados mediante repositorios
        from_wallet = self.wallet_repository.find_by_id(dto.from_wallet_id)
        to_wallet = self.wallet_repository.find_by_id(dto.to_wallet_id)
        
        # Uso del servicio de dominio para la lógica de negocio
        self.transfer_service.validate_and_process_transfer(
            from_wallet, to_wallet, dto.amount, dto.currency_code
        )
        
        # Persistencia de cambios
        self.wallet_repository.save(from_wallet)
        self.wallet_repository.save(to_wallet)
```

Este código muestra:
- Cómo los DTOs empaquetan datos de entrada y salida
- Cómo los servicios de aplicación orquestan el flujo completo
- Cómo se separan las preocupaciones de aplicación (autorización, transacciones) de la lógica de dominio

## Próximos Pasos

Después de entender las capas de aplicación, recomendamos explorar la [Organización y Escalado](../organizacion-y-escalado/index.md) para aprender a estructurar sistemas más grandes con múltiples subsistemas. 