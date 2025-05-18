# Estrategias de Pruebas

Las pruebas automatizadas son un componente crítico del desarrollo de software profesional. Esta sección describe las mejores prácticas y estrategias para implementar pruebas efectivas en arquitecturas modernas como microservicios y aplicaciones basadas en DDD.

## Principios Fundamentales de Pruebas

### 1. Pirámide de Pruebas

La pirámide de pruebas establece una proporción equilibrada entre diferentes tipos de pruebas:

- **Base: Pruebas Unitarias** (mayor cantidad)
  - Rápidas, aisladas, prueban una única unidad de código
  - Mayor cobertura de código

- **Centro: Pruebas de Integración** (cantidad moderada)
  - Verifican la interacción entre componentes
  - Comprueban la integración con servicios externos, bases de datos, etc.

- **Cima: Pruebas End-to-End** (menor cantidad)
  - Prueban el sistema completo
  - Más lentas y frágiles, pero validan flujos completos

### 2. Características de Buenas Pruebas

Las pruebas efectivas deben ser:

- **Rápidas**: Ejecución veloz para feedback inmediato
- **Independientes**: Sin dependencias entre pruebas
- **Repetibles**: Mismo resultado en cualquier momento/ambiente
- **Auto-validantes**: Sin intervención manual para verificar resultados
- **Oportunas**: Escritas antes o junto con el código

## Tipos de Pruebas

### Pruebas Unitarias

Las pruebas unitarias verifican unidades aisladas de código, generalmente clases o funciones individuales.

**Ejemplo en Python con pytest:**

```python
# src/domain/model/usuario.py
class Usuario:
    def __init__(self, nombre, email):
        self.nombre = nombre
        self.email = email
        self.activo = True
    
    def desactivar(self):
        self.activo = False
        return True

# tests/unit/domain/model/test_usuario.py
def test_usuario_desactivar():
    # Arrange
    usuario = Usuario("Ana", "ana@ejemplo.com")
    
    # Act
    resultado = usuario.desactivar()
    
    # Assert
    assert resultado is True
    assert usuario.activo is False
```

**Características clave:**
- Aislamiento mediante mocks/stubs para dependencias externas
- Enfoque en comportamiento, no en implementación
- Verificación de casos límite y manejo de excepciones

### Pruebas de Integración

Las pruebas de integración verifican la interacción entre diferentes componentes o sistemas.

**Ejemplo con SQLAlchemy y pytest:**

```python
# tests/integration/infrastructure/repository/test_usuario_repository.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from src.domain.model.usuario import Usuario
from src.infrastructure.repository.usuario_repository import SQLUsuarioRepository
from src.infrastructure.database.models import Base, UsuarioModel

@pytest.fixture
def db_session():
    # Configurar base de datos en memoria para pruebas
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    
    yield session
    
    session.close()

def test_guardar_y_recuperar_usuario(db_session):
    # Arrange
    repo = SQLUsuarioRepository(db_session)
    usuario = Usuario("María", "maria@ejemplo.com")
    
    # Act
    usuario_guardado = repo.guardar(usuario)
    usuario_recuperado = repo.buscar_por_id(usuario_guardado.id)
    
    # Assert
    assert usuario_recuperado is not None
    assert usuario_recuperado.nombre == "María"
    assert usuario_recuperado.email == "maria@ejemplo.com"
```

**Características clave:**
- Uso de bases de datos reales (o contenedores para pruebas)
- Verificación de flujos completos que involucran múltiples componentes
- Validación de interacción con sistemas externos

### Pruebas End-to-End (E2E)

Las pruebas E2E verifican el sistema completo, simulando interacciones reales de usuarios.

**Ejemplo con FastAPI y pytest:**

```python
# tests/e2e/api/test_usuario_api.py
import pytest
from fastapi.testclient import TestClient

from src.main import app

@pytest.fixture
def client():
    return TestClient(app)

def test_crear_usuario(client):
    # Act
    response = client.post(
        "/api/v1/usuarios",
        json={"nombre": "Carlos", "email": "carlos@ejemplo.com"}
    )
    
    # Assert
    assert response.status_code == 201
    data = response.json()
    assert data["nombre"] == "Carlos"
    assert data["email"] == "carlos@ejemplo.com"
    assert "id" in data

def test_obtener_usuario_no_existente(client):
    # Act
    response = client.get("/api/v1/usuarios/9999")
    
    # Assert
    assert response.status_code == 404
```

**Características clave:**
- Prueba el sistema como lo haría un usuario real
- Valida la integración completa de todos los componentes
- Requiere un entorno similar al de producción

## Pruebas en Microservicios

### Desafíos Específicos

Los microservicios presentan desafíos particulares para las pruebas:

- Dependencias distribuidas entre servicios
- Estado compartido y consistencia de datos
- Comunicación asíncrona
- Despliegue independiente de servicios

### Estrategias para Pruebas de Microservicios

#### 1. Pruebas de Contrato (Contract Testing)

Verifican que los servicios cumplen con los contratos de comunicación establecidos.

**Ejemplo con Pact:**

```python
# tests/contract/consumer/test_servicio_notificaciones.py
import pytest
from pact import Consumer, Provider

from src.infrastructure.clients.notificaciones_client import NotificacionesClient

@pytest.fixture
def notificaciones_client():
    pact = Consumer('servicio-usuarios').has_pact_with(Provider('servicio-notificaciones'))
    pact.start_service()
    
    # Definir la expectativa del contrato
    pact.given(
        'un usuario válido existe'
    ).upon_receiving(
        'una solicitud para enviar notificación'
    ).with_request(
        'POST', '/api/v1/notificaciones',
        body={'usuario_id': '123', 'mensaje': 'Bienvenido'}
    ).will_respond_with(
        200,
        body={'id': '456', 'estado': 'enviado'}
    )
    
    client = NotificacionesClient(pact.uri)
    
    yield client
    
    pact.stop_service()

def test_enviar_notificacion(notificaciones_client):
    # Act
    resultado = notificaciones_client.enviar_notificacion('123', 'Bienvenido')
    
    # Assert
    assert resultado['estado'] == 'enviado'
```

#### 2. Pruebas con Dobles de Servicio

Simula los servicios dependientes para pruebas aisladas.

```python
# tests/integration/api/test_usuario_api_with_mocks.py
import pytest
from unittest.mock import patch
from fastapi.testclient import TestClient

from src.main import app

@pytest.fixture
def client():
    return TestClient(app)

@patch('src.infrastructure.clients.notificaciones_client.NotificacionesClient')
def test_crear_usuario_notifica(mock_notificaciones, client):
    # Configurar mock
    mock_client_instance = mock_notificaciones.return_value
    mock_client_instance.enviar_notificacion.return_value = {'id': '123', 'estado': 'enviado'}
    
    # Act
    response = client.post(
        "/api/v1/usuarios",
        json={"nombre": "Laura", "email": "laura@ejemplo.com"}
    )
    
    # Assert
    assert response.status_code == 201
    
    # Verificar que se llamó al servicio de notificaciones
    mock_client_instance.enviar_notificacion.assert_called_once()
    # Verificar los argumentos
    args = mock_client_instance.enviar_notificacion.call_args[0]
    assert "laura@ejemplo.com" in args
```

#### 3. Pruebas de Componentes con Contenedores

Utiliza contenedores para probar servicios individuales con sus dependencias.

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  usuarios-service:
    build: .
    environment:
      - DATABASE_URL=postgresql://test:test@postgres:5432/test
      - NOTIFICACIONES_SERVICE_URL=http://wiremock:8080
    depends_on:
      - postgres
      - wiremock

  postgres:
    image: postgres:14
    environment:
      - POSTGRES_USER=test
      - POSTGRES_PASSWORD=test
      - POSTGRES_DB=test

  wiremock:
    image: wiremock/wiremock:2.32.0
    volumes:
      - ./tests/wiremock:/home/wiremock/mappings
```

## Pruebas en DDD

El Diseño Dirigido por el Dominio (DDD) influye en cómo estructuramos las pruebas:

### 1. Pruebas del Modelo de Dominio

Enfocadas en las reglas de negocio y comportamiento del dominio.

```python
# tests/unit/domain/model/test_pedido.py
def test_pedido_no_puede_confirmarse_sin_items():
    # Arrange
    pedido = Pedido(cliente_id="123")
    
    # Act & Assert
    with pytest.raises(ValueError, match="sin productos"):
        pedido.confirmar()

def test_pedido_calcula_total_correctamente():
    # Arrange
    pedido = Pedido(cliente_id="123")
    pedido.agregar_producto("P1", 2, 10.0)  # 2 unidades a $10 = $20
    pedido.agregar_producto("P2", 1, 15.0)  # 1 unidad a $15 = $15
    
    # Act
    total = pedido.total
    
    # Assert
    assert total == 35.0
```

### 2. Pruebas de Servicios de Aplicación

Verifican la orquestación correcta de la lógica del dominio.

```python
# tests/unit/application/service/test_procesar_pedido_service.py
def test_procesar_pedido_verifica_stock():
    # Arrange
    producto_id = "P1"
    cliente_id = "C1"
    
    pedido_repo_mock = Mock()
    stock_service_mock = Mock()
    # Configurar que no hay suficiente stock
    stock_service_mock.verificar_disponibilidad.return_value = False
    
    service = ProcesarPedidoService(pedido_repo_mock, stock_service_mock)
    
    # Act & Assert
    with pytest.raises(StockInsuficienteError):
        service.procesar(cliente_id, [(producto_id, 5)])
    
    # Verificar que se llamó al servicio de stock
    stock_service_mock.verificar_disponibilidad.assert_called_once_with(producto_id, 5)
    # Verificar que no se creó el pedido
    pedido_repo_mock.guardar.assert_not_called()
```

### 3. Pruebas de Eventos de Dominio

Verifican que los eventos se disparan correctamente.

```python
# tests/unit/domain/model/test_eventos_pedido.py
def test_confirmar_pedido_genera_evento():
    # Arrange
    pedido = Pedido(cliente_id="123")
    pedido.agregar_producto("P1", 2, 10.0)
    
    # Act
    pedido.confirmar()
    eventos = pedido.obtener_eventos()
    
    # Assert
    assert len(eventos) == 1
    assert isinstance(eventos[0], PedidoConfirmado)
    assert eventos[0].pedido_id == pedido.id
    assert eventos[0].total == 20.0
```

## Herramientas Recomendadas

### Para Python

- **pytest**: Framework completo para pruebas
- **pytest-cov**: Medición de cobertura
- **pytest-mock**: Facilita el uso de mocks
- **factory_boy**: Generación de objetos de prueba
- **Pact**: Pruebas de contrato

### Para TypeScript/JavaScript

- **Jest**: Framework completo para pruebas
- **Supertest**: Pruebas de API
- **Testing Library**: Pruebas de UI
- **Cypress**: Pruebas E2E
- **Pact-JS**: Pruebas de contrato

## Mejores Prácticas Generales

### 1. Organización de Pruebas

Estructura las pruebas para reflejar la estructura del código:

```
tests/
├── unit/                 # Pruebas unitarias
│   ├── domain/
│   ├── application/
│   └── infrastructure/
├── integration/          # Pruebas de integración
│   ├── api/
│   ├── repository/
│   └── clients/
├── e2e/                  # Pruebas de extremo a extremo
├── contract/             # Pruebas de contrato
│   ├── consumer/
│   └── provider/
└── conftest.py           # Configuración compartida
```

### 2. Convenciones de Nomenclatura

Nombres claros y descriptivos para las pruebas:

```python
# Convenio: test_[lo que se prueba]_[condición]_[resultado esperado]
def test_crear_usuario_con_email_invalido_lanza_excepcion():
    # ...

def test_confirmar_pedido_con_items_cambia_estado():
    # ...
```

### 3. Patrones AAA (Arrange-Act-Assert)

Estructura cada prueba en tres secciones claras:

```python
def test_ejemplo():
    # Arrange (Preparar)
    usuario = Usuario("test", "test@ejemplo.com")
    
    # Act (Actuar)
    resultado = usuario.validar()
    
    # Assert (Verificar)
    assert resultado is True
```

### 4. Fixtures y Factories

Utiliza fixtures para reutilizar configuraciones comunes:

```python
# conftest.py
import pytest
from datetime import datetime
from src.domain.model.usuario import Usuario

@pytest.fixture
def usuario_activo():
    return Usuario(
        id="123",
        nombre="Usuario de Prueba",
        email="test@ejemplo.com",
        fecha_registro=datetime(2023, 1, 1),
        activo=True
    )
```

### 5. Estrategias de Mocking

Usa mocks para aislar el código bajo prueba:

```python
from unittest.mock import patch, Mock

@patch('src.infrastructure.email_sender.EmailSender')
def test_notificar_usuario(mock_email_sender):
    # Configurar el mock
    mock_sender_instance = mock_email_sender.return_value
    mock_sender_instance.send.return_value = True
    
    # Usar el servicio que depende del EmailSender
    notificacion_service = NotificacionService(mock_sender_instance)
    resultado = notificacion_service.notificar_usuario("123", "Mensaje de prueba")
    
    # Verificar que se llamó al método send
    mock_sender_instance.send.assert_called_once()
    assert resultado is True
```

## CI/CD y Pruebas Automatizadas

### Integración en Pipeline de CI

Ejemplo de configuración para GitHub Actions:

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: '3.10'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements-dev.txt
    
    - name: Lint with flake8
      run: flake8 src tests
    
    - name: Type check with mypy
      run: mypy src
    
    - name: Test with pytest
      run: pytest --cov=src tests/ --cov-report=xml
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v2
      with:
        file: ./coverage.xml
```

### Estrategias para Pruebas en Despliegue

1. **Despliegues Canary**: Prueba con un pequeño porcentaje de tráfico real
2. **Feature Toggles**: Habilita/deshabilita características en producción
3. **Pruebas de Humo**: Verifica funcionalidad básica post-despliegue
4. **Rollback Automatizado**: Revierte cambios si las pruebas fallan

## Conclusión

Una estrategia de pruebas efectiva requiere equilibrio entre diferentes tipos de pruebas, automatización en CI/CD, y adaptación a la arquitectura específica del sistema. Al aplicar estos principios, puedes construir software más confiable y mantenible, reduciendo riesgos y facilitando la evolución continua. 