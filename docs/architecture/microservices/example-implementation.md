# Ejemplo Práctico de Implementación de Microservicios

Para ilustrar los conceptos discutidos en las secciones anteriores, a continuación se presenta un ejemplo práctico de implementación de microservicios utilizando Python con FastAPI y TypeScript con Express. Este ejemplo muestra cómo organizar el código, configurar la comunicación entre servicios y aplicar patrones de diseño recomendados.

## Caso de Estudio: Sistema de E-commerce

Nuestro ejemplo se basa en un sistema de e-commerce con los siguientes microservicios:

1. **Servicio de Usuarios** - Gestión de cuentas de usuario
2. **Servicio de Productos** - Catálogo de productos
3. **Servicio de Pedidos** - Gestión de pedidos
4. **Servicio de Pagos** - Procesamiento de pagos

## Servicio de Usuarios (Python/FastAPI)

A continuación se muestra una implementación simplificada del Servicio de Usuarios.

### Estructura de Directorios

```
user-service/
├── src/
│   ├── api/
│   │   ├── __init__.py
│   │   ├── routes/
│   │   │   ├── __init__.py
│   │   │   └── user_routes.py
│   │   ├── middlewares/
│   │   │   ├── __init__.py
│   │   │   └── auth_middleware.py
│   │   └── schemas/
│   │       ├── __init__.py
│   │       └── user_schema.py
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py
│   │   └── exceptions.py
│   ├── domain/
│   │   ├── __init__.py
│   │   ├── models/
│   │   │   ├── __init__.py
│   │   │   └── user.py
│   │   └── interfaces/
│   │       ├── __init__.py
│   │       └── repositories.py
│   ├── application/
│   │   ├── __init__.py
│   │   ├── commands/
│   │   │   ├── __init__.py
│   │   │   └── create_user.py
│   │   └── queries/
│   │       ├── __init__.py
│   │       └── get_user.py
│   ├── infrastructure/
│   │   ├── __init__.py
│   │   ├── database/
│   │   │   ├── __init__.py
│   │   │   ├── connection.py
│   │   │   └── models.py
│   │   └── repositories/
│   │       ├── __init__.py
│   │       └── user_repository.py
│   └── main.py
├── tests/
│   └── [...]
├── Dockerfile
├── requirements.txt
└── docker-compose.yml
```

### Modelo de Dominio

```python
# src/domain/models/user.py
from datetime import datetime
from typing import Optional
from pydantic import EmailStr

class User:
    def __init__(
        self,
        name: str,
        email: str,
        password_hash: str,
        id: Optional[int] = None,
        active: bool = True,
        created_at: Optional[datetime] = None
    ):
        self.id = id
        self.name = name
        self.email = email
        self.password_hash = password_hash
        self.active = active
        self.created_at = created_at or datetime.now()

    def activate(self):
        self.active = True
        
    def deactivate(self):
        self.active = False
        
    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "email": self.email,
            "active": self.active,
            "created_at": self.created_at
        }
```

### Interfaces de Repositorio

```python
# src/domain/interfaces/repositories.py
from abc import ABC, abstractmethod
from typing import List, Optional
from ..models.user import User

class UserRepository(ABC):
    @abstractmethod
    async def get_by_id(self, user_id: int) -> Optional[User]:
        pass
        
    @abstractmethod
    async def get_by_email(self, email: str) -> Optional[User]:
        pass
        
    @abstractmethod
    async def create(self, user: User) -> User:
        pass
        
    @abstractmethod
    async def update(self, user: User) -> User:
        pass
        
    @abstractmethod
    async def list_all(self) -> List[User]:
        pass
```

### Implementación del Repositorio

```python
# src/infrastructure/repositories/user_repository.py
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.exc import IntegrityError

from src.domain.models.user import User
from src.domain.interfaces.repositories import UserRepository
from src.infrastructure.database.models import UserModel
from src.core.exceptions import UserAlreadyExistsError

class SQLAlchemyUserRepository(UserRepository):
    def __init__(self, session: AsyncSession):
        self.session = session
        
    async def get_by_id(self, user_id: int) -> Optional[User]:
        result = await self.session.execute(
            select(UserModel).where(UserModel.id == user_id)
        )
        user_model = result.scalar_one_or_none()
        
        if not user_model:
            return None
            
        return self._to_domain(user_model)
        
    async def get_by_email(self, email: str) -> Optional[User]:
        result = await self.session.execute(
            select(UserModel).where(UserModel.email == email)
        )
        user_model = result.scalar_one_or_none()
        
        if not user_model:
            return None
            
        return self._to_domain(user_model)
        
    async def create(self, user: User) -> User:
        user_model = UserModel(
            name=user.name,
            email=user.email,
            password_hash=user.password_hash,
            active=user.active,
            created_at=user.created_at
        )
        
        try:
            self.session.add(user_model)
            await self.session.commit()
            await self.session.refresh(user_model)
            return self._to_domain(user_model)
        except IntegrityError:
            await self.session.rollback()
            raise UserAlreadyExistsError(f"User with email {user.email} already exists")
        
    async def update(self, user: User) -> User:
        if not user.id:
            raise ValueError("Cannot update user without ID")
            
        result = await self.session.execute(
            select(UserModel).where(UserModel.id == user.id)
        )
        user_model = result.scalar_one_or_none()
        
        if not user_model:
            raise ValueError(f"User with ID {user.id} not found")
            
        user_model.name = user.name
        user_model.email = user.email
        user_model.active = user.active
        
        await self.session.commit()
        await self.session.refresh(user_model)
        return self._to_domain(user_model)
        
    async def list_all(self) -> List[User]:
        result = await self.session.execute(select(UserModel))
        user_models = result.scalars().all()
        return [self._to_domain(model) for model in user_models]
        
    def _to_domain(self, user_model: UserModel) -> User:
        return User(
            id=user_model.id,
            name=user_model.name,
            email=user_model.email,
            password_hash=user_model.password_hash,
            active=user_model.active,
            created_at=user_model.created_at
        )
```

### Caso de Uso de Aplicación

```python
# src/application/commands/create_user.py
from typing import Optional
from passlib.context import CryptContext

from src.domain.models.user import User
from src.infrastructure.repositories.user_repository import SQLAlchemyUserRepository
from src.api.schemas.user_schema import UserCreate
from src.core.exceptions import UserAlreadyExistsError

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

async def create_user(user_data: UserCreate, repository: SQLAlchemyUserRepository) -> User:
    # Verificar si el usuario ya existe
    existing_user = await repository.get_by_email(user_data.email)
    if existing_user:
        raise UserAlreadyExistsError(f"User with email {user_data.email} already exists")
    
    # Crear el usuario con contraseña hasheada
    user = User(
        name=user_data.name,
        email=user_data.email,
        password_hash=pwd_context.hash(user_data.password)
    )
    
    # Persistir el usuario
    return await repository.create(user)
```

### Esquemas de API

```python
# src/api/schemas/user_schema.py
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=50)
    email: EmailStr

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=50)
    email: Optional[EmailStr] = None
    active: Optional[bool] = None

class UserResponse(UserBase):
    id: int
    active: bool
    created_at: datetime

    class Config:
        orm_mode = True
```

### Rutas de API

```python
# src/api/routes/user_routes.py
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.schemas.user_schema import UserCreate, UserResponse, UserUpdate
from src.application.commands.create_user import create_user
from src.application.queries.get_user import get_user_by_id, list_users
from src.core.exceptions import UserAlreadyExistsError, UserNotFoundError
from src.infrastructure.database.connection import get_session
from src.infrastructure.repositories.user_repository import SQLAlchemyUserRepository

router = APIRouter()

@router.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user_route(
    user_data: UserCreate,
    session: AsyncSession = Depends(get_session)
):
    try:
        repository = SQLAlchemyUserRepository(session)
        user = await create_user(user_data, repository)
        return UserResponse.from_orm(user)
    except UserAlreadyExistsError as e:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(e)
        )

@router.get("/users", response_model=List[UserResponse])
async def get_users_route(
    session: AsyncSession = Depends(get_session)
):
    repository = SQLAlchemyUserRepository(session)
    users = await list_users(repository)
    return [UserResponse.from_orm(user) for user in users]

@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user_route(
    user_id: int,
    session: AsyncSession = Depends(get_session)
):
    try:
        repository = SQLAlchemyUserRepository(session)
        user = await get_user_by_id(user_id, repository)
        return UserResponse.from_orm(user)
    except UserNotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
```

### Aplicación Principal

```python
# src/main.py
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.api.routes.user_routes import router as user_router
from src.core.config import settings
from src.infrastructure.database.connection import create_tables

app = FastAPI(
    title="User Service",
    description="Microservicio para gestión de usuarios",
    version="1.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir rutas
app.include_router(user_router, prefix="/api/v1", tags=["users"])

@app.on_event("startup")
async def startup():
    # Crear tablas en la base de datos
    await create_tables()

@app.get("/health")
async def health_check():
    return {"status": "ok"}

if __name__ == "__main__":
    uvicorn.run("src.main:app", host="0.0.0.0", port=8000, reload=True)
```

## Servicio de Pedidos (TypeScript/Express)

A continuación se muestra un ejemplo simplificado del Servicio de Pedidos implementado con TypeScript y Express.

### Estructura de Directorios

```
order-service/
├── src/
│   ├── api/
│   │   ├── controllers/
│   │   │   └── orderController.ts
│   │   ├── routes/
│   │   │   └── orderRoutes.ts
│   │   ├── middlewares/
│   │   │   └── authMiddleware.ts
│   │   └── dtos/
│   │       └── orderDtos.ts
│   ├── core/
│   │   ├── config.ts
│   │   └── exceptions.ts
│   ├── domain/
│   │   ├── models/
│   │   │   └── Order.ts
│   │   └── interfaces/
│   │       └── IOrderRepository.ts
│   ├── application/
│   │   ├── commands/
│   │   │   └── createOrder.ts
│   │   └── queries/
│   │       └── getOrders.ts
│   ├── infrastructure/
│   │   ├── database/
│   │   │   ├── connection.ts
│   │   │   └── models.ts
│   │   ├── repositories/
│   │   │   └── OrderRepository.ts
│   │   └── clients/
│   │       ├── UserServiceClient.ts
│   │       └── ProductServiceClient.ts
│   └── app.ts
├── tests/
│   └── [...]
├── Dockerfile
├── package.json
└── tsconfig.json
```

### Modelo de Dominio

```typescript
// src/domain/models/Order.ts
export enum OrderStatus {
  PENDING = 'pending',
  PAID = 'paid',
  SHIPPED = 'shipped',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled'
}

export interface OrderItem {
  productId: number;
  quantity: number;
  price: number;
}

export class Order {
  constructor(
    public readonly id: number | null,
    public readonly userId: number,
    public items: OrderItem[],
    public status: OrderStatus = OrderStatus.PENDING,
    public readonly createdAt: Date = new Date(),
    public updatedAt: Date = new Date()
  ) {}

  get totalAmount(): number {
    return this.items.reduce((total, item) => total + (item.price * item.quantity), 0);
  }

  addItem(item: OrderItem): void {
    const existingItem = this.items.find(i => i.productId === item.productId);
    if (existingItem) {
      existingItem.quantity += item.quantity;
    } else {
      this.items.push(item);
    }
    this.updatedAt = new Date();
  }

  updateStatus(newStatus: OrderStatus): void {
    this.status = newStatus;
    this.updatedAt = new Date();
  }

  canBeCancelled(): boolean {
    return this.status === OrderStatus.PENDING || this.status === OrderStatus.PAID;
  }

  cancel(): void {
    if (!this.canBeCancelled()) {
      throw new Error(`Cannot cancel order in ${this.status} status`);
    }
    this.status = OrderStatus.CANCELLED;
    this.updatedAt = new Date();
  }
}
```

### Interfaces de Repositorio

```typescript
// src/domain/interfaces/IOrderRepository.ts
import { Order } from '../models/Order';

export interface IOrderRepository {
  findById(id: number): Promise<Order | null>;
  findByUserId(userId: number): Promise<Order[]>;
  create(order: Order): Promise<Order>;
  update(order: Order): Promise<Order>;
  delete(id: number): Promise<boolean>;
}
```

### Comunicación entre Servicios

```typescript
// src/infrastructure/clients/UserServiceClient.ts
import axios from 'axios';
import { config } from '../../core/config';

interface User {
  id: number;
  name: string;
  email: string;
  active: boolean;
}

export class UserServiceClient {
  private baseUrl: string;

  constructor() {
    this.baseUrl = config.services.userService.url;
  }

  async getUser(userId: number): Promise<User | null> {
    try {
      const response = await axios.get(`${this.baseUrl}/api/v1/users/${userId}`);
      return response.data;
    } catch (error) {
      if (axios.isAxiosError(error) && error.response?.status === 404) {
        return null;
      }
      throw error;
    }
  }

  async validateUser(userId: number): Promise<boolean> {
    const user = await this.getUser(userId);
    return user !== null && user.active;
  }
}
```

### Caso de Uso de Aplicación

```typescript
// src/application/commands/createOrder.ts
import { Order, OrderItem } from '../../domain/models/Order';
import { IOrderRepository } from '../../domain/interfaces/IOrderRepository';
import { UserServiceClient } from '../../infrastructure/clients/UserServiceClient';
import { ProductServiceClient } from '../../infrastructure/clients/ProductServiceClient';
import { CreateOrderDto } from '../../api/dtos/orderDtos';

export class OrderCreationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'OrderCreationError';
  }
}

export async function createOrder(
  dto: CreateOrderDto,
  orderRepository: IOrderRepository,
  userClient: UserServiceClient,
  productClient: ProductServiceClient
): Promise<Order> {
  // Validar que el usuario existe y está activo
  const userValid = await userClient.validateUser(dto.userId);
  if (!userValid) {
    throw new OrderCreationError(`User ${dto.userId} not found or inactive`);
  }

  // Validar que todos los productos existen y tienen stock
  const orderItems: OrderItem[] = [];
  for (const item of dto.items) {
    const product = await productClient.getProduct(item.productId);
    if (!product) {
      throw new OrderCreationError(`Product ${item.productId} not found`);
    }
    if (product.stock < item.quantity) {
      throw new OrderCreationError(`Not enough stock for product ${item.productId}`);
    }
    orderItems.push({
      productId: item.productId,
      quantity: item.quantity,
      price: product.price
    });
  }

  // Crear la orden
  const order = new Order(null, dto.userId, orderItems);
  
  // Persistir la orden
  const savedOrder = await orderRepository.create(order);
  
  // Actualizar el stock de productos (esto podría hacerse de forma asíncrona)
  for (const item of orderItems) {
    await productClient.decreaseStock(item.productId, item.quantity);
  }
  
  return savedOrder;
}
```

## Comunicación entre Microservicios

Este ejemplo muestra diferentes patrones de comunicación entre microservicios:

1. **Comunicación sincrónica (REST)** - El servicio de pedidos llama directamente a los servicios de usuarios y productos.

2. **Comunicación asincrónica (eventos)** - Se podría implementar para notificar al servicio de pagos que un pedido ha sido creado:

```typescript
// src/infrastructure/messaging/EventPublisher.ts
import { Producer } from 'kafkajs';
import { Order } from '../../domain/models/Order';

export class EventPublisher {
  constructor(private producer: Producer) {}

  async publishOrderCreated(order: Order): Promise<void> {
    await this.producer.send({
      topic: 'order-events',
      messages: [
        {
          key: `order-${order.id}`,
          value: JSON.stringify({
            type: 'ORDER_CREATED',
            data: {
              orderId: order.id,
              userId: order.userId,
              totalAmount: order.totalAmount,
              items: order.items,
              createdAt: order.createdAt
            }
          })
        }
      ]
    });
  }
}
```

## Configuración de la Aplicación

```typescript
// src/core/config.ts
import dotenv from 'dotenv';

dotenv.config();

interface ServiceConfig {
  url: string;
}

interface ServicesConfig {
  userService: ServiceConfig;
  productService: ServiceConfig;
  paymentService: ServiceConfig;
}

interface DatabaseConfig {
  host: string;
  port: number;
  user: string;
  password: string;
  database: string;
}

interface KafkaConfig {
  brokers: string[];
  clientId: string;
}

interface AppConfig {
  port: number;
  environment: string;
  services: ServicesConfig;
  database: DatabaseConfig;
  kafka: KafkaConfig;
  corsOrigins: string[];
}

export const config: AppConfig = {
  port: parseInt(process.env.PORT || '8001', 10),
  environment: process.env.NODE_ENV || 'development',
  services: {
    userService: {
      url: process.env.USER_SERVICE_URL || 'http://localhost:8000'
    },
    productService: {
      url: process.env.PRODUCT_SERVICE_URL || 'http://localhost:8002'
    },
    paymentService: {
      url: process.env.PAYMENT_SERVICE_URL || 'http://localhost:8003'
    }
  },
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'orders_db'
  },
  kafka: {
    brokers: (process.env.KAFKA_BROKERS || 'localhost:9092').split(','),
    clientId: process.env.KAFKA_CLIENT_ID || 'order-service'
  },
  corsOrigins: (process.env.CORS_ORIGINS || 'http://localhost:3000').split(',')
};
```

## Configuración de Docker

```Dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

EXPOSE 8001

CMD ["npm", "start"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  order-service:
    build: .
    ports:
      - "8001:8001"
    environment:
      - NODE_ENV=development
      - PORT=8001
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=postgres
      - DB_NAME=orders_db
      - USER_SERVICE_URL=http://user-service:8000
      - PRODUCT_SERVICE_URL=http://product-service:8002
      - PAYMENT_SERVICE_URL=http://payment-service:8003
      - KAFKA_BROKERS=kafka:9092
    depends_on:
      - postgres
      - kafka
    networks:
      - microservices-network

  postgres:
    image: postgres:14-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=orders_db
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - microservices-network

  kafka:
    image: confluentinc/cp-kafka:7.0.0
    ports:
      - "9092:9092"
    environment:
      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092
      - KAFKA_BROKER_ID=1
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
    depends_on:
      - zookeeper
    networks:
      - microservices-network

  zookeeper:
    image: confluentinc/cp-zookeeper:7.0.0
    environment:
      - ZOOKEEPER_CLIENT_PORT=2181
    ports:
      - "2181:2181"
    networks:
      - microservices-network

networks:
  microservices-network:

volumes:
  postgres-data:
```

## Conclusión

Este ejemplo muestra cómo implementar microservicios en diferentes lenguajes de programación siguiendo buenas prácticas de arquitectura:

1. **Separación de responsabilidades** - Cada servicio tiene una responsabilidad clara.
2. **Independencia** - Los servicios pueden desplegarse y escalarse de forma independiente.
3. **Aislamiento de datos** - Cada servicio gestiona su propia base de datos.
4. **Comunicación a través de interfaces** - Los servicios se comunican a través de APIs bien definidas.
5. **Estructura interna coherente** - Cada servicio sigue una arquitectura en capas internamente.

Este enfoque facilita el desarrollo, despliegue y mantenimiento de sistemas complejos, permitiendo que diferentes equipos trabajen en diferentes servicios de forma independiente.
``` 