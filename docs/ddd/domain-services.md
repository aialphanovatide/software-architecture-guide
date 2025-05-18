# Servicios de Dominio

Los servicios de dominio encapsulan la lógica de negocio que no pertenece naturalmente a entidades o objetos de valor específicos. Representan operaciones, procesos o transformaciones importantes en el dominio.

## Propósito

Los servicios de dominio se utilizan cuando:

- Una operación involucra múltiples entidades o agregados.
- Un proceso no es responsabilidad natural de una sola entidad.
- Se necesita coordinar la interacción entre varios objetos de dominio.

## Características Principales

- **Sin Estado**: Los servicios de dominio no mantienen estado.
- **Orientados a Comportamiento**: Representan acciones, no cosas.
- **Lenguaje Explícito**: Expresan directamente conceptos del dominio.
- **Pureza del Dominio**: No contienen lógica técnica o de infraestructura.

## Implementación en Python

```python
from typing import List, Optional
from uuid import UUID
from datetime import datetime

from domain.order import Order, OrderStatus
from domain.payment import Payment, PaymentMethod, PaymentStatus
from domain.customer import Customer
from domain.inventory import InventoryItem

class OrderProcessingService:
    """Servicio de dominio para procesar órdenes."""
    
    def __init__(
        self, 
        inventory_repository, 
        payment_service, 
        notification_service
    ):
        self.inventory_repository = inventory_repository
        self.payment_service = payment_service
        self.notification_service = notification_service
    
    def process_order(self, order: Order, payment_method: PaymentMethod) -> bool:
        """
        Procesa una orden completa, verificando inventario y realizando el pago.
        Retorna True si la orden fue procesada exitosamente.
        """
        # Verificar disponibilidad de inventario
        if not self._check_inventory_availability(order):
            order.update_status(OrderStatus.REJECTED, "Inventario insuficiente")
            return False
            
        # Procesar pago
        payment_result = self._process_payment(order, payment_method)
        if not payment_result.is_successful:
            order.update_status(
                OrderStatus.PAYMENT_FAILED, 
                f"Fallo en el pago: {payment_result.error_message}"
            )
            return False
            
        # Reservar inventario
        self._reserve_inventory(order)
        
        # Actualizar estado de la orden
        order.update_status(OrderStatus.CONFIRMED)
        order.set_payment_id(payment_result.payment_id)
        
        # Notificar al cliente
        self._notify_customer(order)
        
        return True
    
    def _check_inventory_availability(self, order: Order) -> bool:
        """Verifica si hay suficiente inventario para todos los items de la orden."""
        for item in order.items:
            inventory_item = self.inventory_repository.find_by_product_id(item.product_id)
            if not inventory_item or inventory_item.available_quantity < item.quantity:
                return False
        return True
    
    def _process_payment(self, order: Order, payment_method: PaymentMethod) -> Payment:
        """Procesa el pago de la orden utilizando el método de pago especificado."""
        return self.payment_service.process_payment(
            amount=order.total_amount,
            currency=order.currency,
            payment_method=payment_method,
            order_reference=order.id
        )
    
    def _reserve_inventory(self, order: Order) -> None:
        """Reserva el inventario para los items de la orden."""
        for item in order.items:
            inventory_item = self.inventory_repository.find_by_product_id(item.product_id)
            inventory_item.reserve(item.quantity)
            self.inventory_repository.save(inventory_item)
    
    def _notify_customer(self, order: Order) -> None:
        """Notifica al cliente sobre el estado de su orden."""
        self.notification_service.send_order_confirmation(
            customer_id=order.customer_id,
            order_id=order.id,
            total_amount=order.total_amount,
            estimated_delivery=order.estimated_delivery_date
        )
```

## Implementación en TypeScript

```typescript
import { Order, OrderStatus, OrderItem } from '../domain/order';
import { Payment, PaymentMethod, PaymentResult } from '../domain/payment';
import { InventoryRepository } from '../repositories/inventory-repository';
import { PaymentService } from './payment-service';
import { NotificationService } from './notification-service';

export class OrderProcessingService {
  constructor(
    private readonly inventoryRepository: InventoryRepository,
    private readonly paymentService: PaymentService,
    private readonly notificationService: NotificationService
  ) {}

  async processOrder(order: Order, paymentMethod: PaymentMethod): Promise<boolean> {
    // Verificar disponibilidad de inventario
    const inventoryAvailable = await this.checkInventoryAvailability(order);
    if (!inventoryAvailable) {
      order.updateStatus(OrderStatus.REJECTED, "Inventario insuficiente");
      return false;
    }

    // Procesar pago
    const paymentResult = await this.processPayment(order, paymentMethod);
    if (!paymentResult.isSuccessful) {
      order.updateStatus(
        OrderStatus.PAYMENT_FAILED,
        `Fallo en el pago: ${paymentResult.errorMessage}`
      );
      return false;
    }

    // Reservar inventario
    await this.reserveInventory(order);

    // Actualizar estado de la orden
    order.updateStatus(OrderStatus.CONFIRMED);
    order.setPaymentId(paymentResult.paymentId);

    // Notificar al cliente
    await this.notifyCustomer(order);

    return true;
  }

  private async checkInventoryAvailability(order: Order): Promise<boolean> {
    for (const item of order.items) {
      const inventoryItem = await this.inventoryRepository.findByProductId(item.productId);
      if (!inventoryItem || inventoryItem.availableQuantity < item.quantity) {
        return false;
      }
    }
    return true;
  }

  private async processPayment(order: Order, paymentMethod: PaymentMethod): Promise<PaymentResult> {
    return this.paymentService.processPayment({
      amount: order.totalAmount,
      currency: order.currency,
      paymentMethod,
      orderReference: order.id
    });
  }

  private async reserveInventory(order: Order): Promise<void> {
    for (const item of order.items) {
      const inventoryItem = await this.inventoryRepository.findByProductId(item.productId);
      inventoryItem.reserve(item.quantity);
      await this.inventoryRepository.save(inventoryItem);
    }
  }

  private async notifyCustomer(order: Order): Promise<void> {
    await this.notificationService.sendOrderConfirmation({
      customerId: order.customerId,
      orderId: order.id,
      totalAmount: order.totalAmount,
      estimatedDelivery: order.estimatedDeliveryDate
    });
  }
}
```

## Tipos de Servicios de Dominio

1. **Servicios de Transformación**: Transforman una entrada en una salida sin efectos secundarios (ej. cálculo de tarifas).
2. **Servicios de Proceso**: Ejecutan un flujo de trabajo que involucra varios agregados (ej. procesamiento de órdenes).
3. **Servicios de Coordinación**: Orquestan la interacción entre múltiples agregados (ej. transferencia entre cuentas).
4. **Servicios de Validación**: Aplican reglas de negocio complejas que involucran múltiples entidades (ej. validación de límites de crédito).

## Principios de Diseño

1. **Enfoque en el Lenguaje Ubícuo**: Los nombres de servicios deben ser coherentes con el lenguaje del dominio.
2. **Límites Contextuales**: Los servicios no deben atravesar contextos delimitados.
3. **Inmutabilidad**: Implementar servicios como objetos inmutables cuando sea posible.
4. **Evitar Servicios Anémicos**: Los servicios deben contener lógica de dominio significativa, no solo coordinar llamadas.

## Mejores Prácticas

1. **Conciso y Enfocado**: Cada servicio de dominio debe tener una responsabilidad clara y concisa.
2. **Sin Estado**: Los servicios no deben almacenar estado entre llamadas.
3. **Independencia de Infraestructura**: No mezclar lógica de dominio con preocupaciones de infraestructura.
4. **Testabilidad**: Facilitar pruebas unitarias aislando la lógica de dominio.
5. **Inyección de Dependencias**: Inyectar repositorios y otros servicios para facilitar pruebas y flexibilidad. 