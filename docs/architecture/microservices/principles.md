# Principios de Diseño de Microservicios

## ¿Qué son los principios de diseño de microservicios?

Los principios de diseño son como las "reglas de oro" que te guían para crear microservicios efectivos. Son la diferencia entre un sistema distribuido exitoso y uno problemático.

## ¿Qué problemas resuelven estos principios?

Estos principios solucionan problemas comunes en arquitecturas distribuidas como:
- Servicios demasiado acoplados que fallan juntos
- Sistemas inconsistentes difíciles de mantener
- Aplicaciones que no escalan ni son resilientes

## Principios Fundamentales Explicados

### 1. Responsabilidad Única

**¿Qué significa?** Cada microservicio debe hacer una sola cosa bien.

**¿Cómo aplicarlo?**
- Pregúntate: "¿Puedo explicar lo que hace este servicio en una frase sencilla?"
- Si el servicio maneja muchos conceptos no relacionados, considéralo una señal de alarma

**Ejemplo práctico:**
```python
# ✅ BIEN: Un servicio de notificaciones enfocado
class NotificationService:
    def send_email(self, to, subject, body):
        # Lógica para enviar email
        pass
        
    def send_sms(self, phone, message):
        # Lógica para enviar SMS
        pass

# ❌ MAL: Un servicio que hace demasiadas cosas
class UserNotificationPaymentService:
    def create_user(self, data):
        # Lógica para crear usuario
        pass
        
    def send_notification(self, user_id, message):
        # Lógica para notificar
        pass
        
    def process_payment(self, user_id, amount):
        # Lógica para procesar pago
        pass
```

### 2. Autonomía

**¿Qué significa?** Los servicios deben poder trabajar, desplegarse y escalar de forma independiente.

**¿Cómo aplicarlo?**
- Evita las dependencias en tiempo de ejecución cuando sea posible
- Asegúrate de que cada servicio tiene su propio ciclo de vida
- Utiliza comunicación asíncrona cuando sea apropiado

**Ejemplo práctico:**

```yaml
# docker-compose.yml - Cada servicio tiene su propio despliegue
version: '3'
services:
  auth-service:
    build: ./auth-service
    ports:
      - "8001:8000"
    environment:
      - DATABASE_URL=postgres://user:pass@auth-db/auth
      
  product-service:
    build: ./product-service
    ports:
      - "8002:8000"
    environment:
      - DATABASE_URL=postgres://user:pass@product-db/product
```

### 3. Soberanía de Datos

**¿Qué significa?** Cada servicio es responsable de sus propios datos y solo expone esos datos a través de APIs.

**¿Cómo aplicarlo?**
- Cada servicio debe tener su propia base de datos (o esquema)
- Ningún servicio accede directamente a la base de datos de otro
- Los datos compartidos se acceden a través de APIs

**Ejemplo práctico:**

```python
# ✅ BIEN: Obtener datos de otro servicio usando su API
async def get_product_details(product_id):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"http://product-service/products/{product_id}")
    return response.json()

# ❌ MAL: Acceder directamente a la base de datos de otro servicio
def get_product_details(product_id):
    # Esto rompe la soberanía de datos
    return db.query("SELECT * FROM product_service.products WHERE id = %s", [product_id])
```

### 4. Diseñar para el Fallo

**¿Qué significa?** Los sistemas distribuidos fallan de formas diferentes a los monolitos; debes diseñar teniendo eso en cuenta.

**¿Cómo aplicarlo?**
- Implementa timeouts para evitar bloqueos
- Usa patrones [Circuit Breaker](resilience-patterns/circuit-breaker.md) para manejar fallos temporales
- Diseña comportamientos degradados (fallbacks) cuando un servicio dependiente falla

**Ejemplo práctico:**

```python
from functools import wraps
import time
import httpx
from fastapi import HTTPException

# Implementación simple de Circuit Breaker
class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=30):
        self.failure_count = 0
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.open_since = None
        
    def can_execute(self):
        if self.open_since is None:
            return True
            
        if (time.time() - self.open_since) > self.recovery_timeout:
            self.reset()
            return True
            
        return False
        
    def record_success(self):
        self.reset()
        
    def record_failure(self):
        self.failure_count += 1
        if self.failure_count >= self.failure_threshold:
            self.open_since = time.time()
            
    def reset(self):
        self.failure_count = 0
        self.open_since = None
        
# Uso del Circuit Breaker        
product_service_breaker = CircuitBreaker()

async def get_product_with_resilience(product_id):
    if not product_service_breaker.can_execute():
        # Circuito abierto, devolver datos en caché o respuesta degradada
        return {"id": product_id, "name": "Producto Temporal", "note": "Datos limitados disponibles"}
        
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"http://product-service/products/{product_id}", 
                timeout=1.0  # Timeout de 1 segundo
            )
        response.raise_for_status()
        product_service_breaker.record_success()
        return response.json()
    except (httpx.HTTPError, httpx.TimeoutException) as error:
        product_service_breaker.record_failure()
        # Respuesta degradada
        return {"id": product_id, "name": "Producto No Disponible", "error": str(error)}
```

Para una implementación completa y detallada del patrón Circuit Breaker, consulta nuestra [guía específica sobre Circuit Breaker](resilience-patterns/circuit-breaker.md).

### 5. API Primero

**¿Qué significa?** Diseñar la API antes que la implementación, considerando cómo será usada.

**¿Cómo aplicarlo?**
- Define contratos claros con OpenAPI/Swagger
- Implementa versionado adecuado (por ejemplo, `/v1/users`)
- Documenta todas las APIs extensivamente

**Ejemplo práctico:**

```python
from fastapi import FastAPI, APIRouter, Path
from pydantic import BaseModel, Field

# Modelo de datos bien definido
class UserCreate(BaseModel):
    name: str = Field(..., min_length=2, example="Ana García")
    email: str = Field(..., example="ana@ejemplo.com")
    
    class Config:
        schema_extra = {
            "example": {
                "name": "Juan Pérez",
                "email": "juan@ejemplo.com"
            }
        }

# Router versionado
router = APIRouter(prefix="/v1")

@router.post("/users", response_model=dict, tags=["users"])
async def create_user(user: UserCreate):
    """
    Crea un nuevo usuario.
    
    Recibe la información básica del usuario y retorna el usuario creado con su ID.
    
    - **name**: Nombre completo del usuario (2+ caracteres)
    - **email**: Dirección de correo electrónico válida
    """
    # Implementación...
    return {"id": 123, **user.dict()}
```

## Límites de Servicio: La Decisión Más Importante

La parte más difícil de los microservicios es decidir dónde poner los límites entre servicios. Aquí es donde el Diseño Dirigido por el Dominio (DDD) puede ayudar.

### ¿Cómo identificar buenos límites de servicio?

1. **Agrupa por capacidad de negocio, no por capa técnica**

   ```
   ❌ MAL:                       ✅ BIEN:
   ┌───────────────┐            ┌───────────────┐
   │ Servicio UI   │            │ Servicio de   │
   └───────────────┘            │  Usuarios     │
   ┌───────────────┐            └───────────────┘
   │ Servicio API  │            ┌───────────────┐
   └───────────────┘            │ Servicio de   │
   ┌───────────────┐            │  Productos    │
   │Servicio Base  │            └───────────────┘
   │ de Datos      │            ┌───────────────┐
   └───────────────┘            │ Servicio de   │
                                │  Pedidos      │
                                └───────────────┘
   ```

2. **Usa Contextos Delimitados de DDD**
   - Un Contexto Delimitado es un límite alrededor de un modelo de dominio donde términos y reglas específicas se aplican
   - Por ejemplo, un "Cliente" en el módulo de Ventas puede tener información diferente que un "Cliente" en el módulo de Soporte

3. **Busca cambios que ocurren juntos**
   - El código que cambia por la misma razón debería estar junto
   - El código que cambia por razones diferentes debería estar separado

### Ejemplo práctico: E-commerce

```
┌─────────────────────┐     ┌─────────────────────┐
│ Servicio de Catálogo│     │ Servicio de Pedidos │
│                     │◄────┤                     │
│ - Gestión productos │     │ - Crear pedido      │
│ - Categorías        │     │ - Estado del pedido │
│ - Búsqueda          │     │ - Historial         │
└─────────────────────┘     └─────────────────────┘
                                    ▲
┌─────────────────────┐             │
│ Servicio de Usuarios│             │
│                     │◄────────────┘
│ - Autenticación     │     ┌─────────────────────┐
│ - Perfiles          │     │ Servicio de Pagos   │
│ - Preferencias      │◄────┤                     │
└─────────────────────┘     │ - Procesar pago     │
                            │ - Reembolsos        │
                            └─────────────────────┘
```

## Preguntas de Reflexión

1. En un proyecto actual o reciente, ¿podrías identificar áreas donde el principio de responsabilidad única se está violando?

2. ¿Qué estrategias usarías para manejar datos que necesitan ser compartidos entre múltiples servicios?

3. Piensa en un sistema que hayas desarrollado: ¿cómo cambiaría su arquitectura si aplicaras estos principios? 