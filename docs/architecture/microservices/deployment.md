# Estrategias de Despliegue de Microservicios

El despliegue eficiente y confiable de microservicios es crucial para aprovechar completamente los beneficios de esta arquitectura. Esta sección explora las diferentes estrategias, herramientas y mejores prácticas para el despliegue de microservicios.

## Desafíos en el Despliegue de Microservicios

A diferencia de las aplicaciones monolíticas, los microservicios presentan desafíos únicos:

- **Mayor complejidad operativa**: Gestión de múltiples servicios independientes
- **Consistencia del entorno**: Garantizar que todos los servicios operen en condiciones similares
- **Orquestación**: Coordinar el despliegue y la comunicación entre servicios
- **Configuración distribuida**: Gestionar configuraciones para múltiples servicios
- **Observabilidad**: Monitorear y depurar un sistema distribuido

## Infraestructura como Código (IaC)

La infraestructura como código es fundamental para gestionar entornos de microservicios de manera consistente y reproducible.

### Herramientas populares de IaC

#### Terraform

```hcl
# Ejemplo de Terraform para desplegar microservicios en Kubernetes
resource "kubernetes_deployment" "servicio_usuarios" {
  metadata {
    name = "servicio-usuarios"
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "servicio-usuarios"
      }
    }
    template {
      metadata {
        labels = {
          app = "servicio-usuarios"
        }
      }
      spec {
        container {
          name  = "servicio-usuarios"
          image = "miregistro/servicio-usuarios:1.0.0"
          port {
            container_port = 8080
          }
          env {
            name  = "DB_HOST"
            value = var.db_host
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "0.2"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}
```

#### Ansible

```yaml
# Playbook de Ansible para configurar un servidor de microservicios
- name: Configurar Servidor de Microservicios
  hosts: microservicios
  become: true
  tasks:
    - name: Instalar Docker
      apt:
        name: docker.io
        state: present
      
    - name: Instalar Docker Compose
      get_url:
        url: https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64
        dest: /usr/local/bin/docker-compose
        mode: '0755'
        
    - name: Crear directorio de configuración
      file:
        path: /opt/microservicios
        state: directory
        
    - name: Copiar archivos de configuración
      copy:
        src: "{{ item }}"
        dest: /opt/microservicios/
      with_items:
        - docker-compose.yml
        - .env
```

## Contenedorización

Los contenedores son la base para el despliegue moderno de microservicios, proporcionando entornos aislados y consistentes.

### Docker

```dockerfile
# Dockerfile para un microservicio Python
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PORT=8080

EXPOSE $PORT

CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "${PORT}"]
```

### Docker Compose para Desarrollo Local

```yaml
# docker-compose.yml para un ecosistema de microservicios
version: '3.8'

services:
  servicio-usuarios:
    build: ./servicio-usuarios
    ports:
      - "8001:8080"
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    depends_on:
      - postgres
      - redis
      
  servicio-productos:
    build: ./servicio-productos
    ports:
      - "8002:8080"
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:14
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_PASSWORD=secreto
      - POSTGRES_USER=app
    volumes:
      - pg_data:/var/lib/postgresql/data
      
  redis:
    image: redis:6
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  pg_data:
  redis_data:
```

## Orquestación de Contenedores

Para entornos de producción, se requiere un orquestador para gestionar múltiples contenedores.

### Kubernetes

Kubernetes es la plataforma de orquestación de contenedores más popular para microservicios.

```yaml
# Archivo de despliegue de Kubernetes para un microservicio
apiVersion: apps/v1
kind: Deployment
metadata:
  name: servicio-usuarios
spec:
  replicas: 3
  selector:
    matchLabels:
      app: servicio-usuarios
  template:
    metadata:
      labels:
        app: servicio-usuarios
    spec:
      containers:
      - name: servicio-usuarios
        image: miregistro/servicio-usuarios:1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: db-config
              key: host
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: password
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 20
```

## Estrategias de Despliegue Avanzadas

### 1. Despliegue Azul-Verde (Blue-Green)

El despliegue azul-verde mantiene dos entornos idénticos, con uno activo (azul) y otro inactivo (verde). Cuando se despliega una nueva versión:

1. La nueva versión se despliega en el entorno inactivo (verde)
2. Se realizan pruebas en el entorno verde
3. El tráfico se cambia del entorno azul al verde
4. El antiguo entorno azul queda inactivo para futuras actualizaciones

```yaml
# Ejemplo de servicio Kubernetes para Blue-Green
apiVersion: v1
kind: Service
metadata:
  name: servicio-frontend
spec:
  selector:
    app: frontend
    version: blue  # Cambiar a 'green' para realizar el switch
  ports:
  - port: 80
    targetPort: 8080
```

### 2. Despliegue Canario (Canary Deployment)

El despliegue canario envía un pequeño porcentaje del tráfico a la nueva versión y lo incrementa gradualmente.

```yaml
# Ejemplo con Istio para despliegue canario
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: servicio-frontend
spec:
  hosts:
    - frontend.miapp.com
  http:
  - route:
    - destination:
        host: frontend-v1
        subset: v1
      weight: 90
    - destination:
        host: frontend-v2
        subset: v2
      weight: 10  # 10% del tráfico va a la nueva versión
```

### 3. Despliegue Continuo

El despliegue continuo automatiza completamente el proceso de lanzamiento de software.

![Pipeline de CI/CD para Microservicios](https://miro.medium.com/max/1400/1*Z7WZnO71Jz-1iT8PyahJew.png)

```yaml
# Archivo GitHub Actions para despliegue continuo
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Configurar Docker Buildx
      uses: docker/setup-buildx-action@v1
    
    - name: Login a DockerHub
      uses: docker/login-action@v1
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
    
    - name: Construir y Publicar Imagen
      uses: docker/build-push-action@v2
      with:
        context: .
        push: true
        tags: miregistro/servicio-usuarios:${{ github.sha }}
    
    - name: Desplegar a Kubernetes
      uses: steebchen/kubectl@v2
      with:
        config: ${{ secrets.KUBE_CONFIG_DATA }}
        command: set image deployment/servicio-usuarios servicio-usuarios=miregistro/servicio-usuarios:${{ github.sha }}
```

## Configuración de Microservicios

La gestión de configuración en microservicios debe ser externa al código y fácilmente modificable.

### Gestión Centralizada de Configuración

#### Usando HashiCorp Vault para Secretos

```python
# Cliente Python para HashiCorp Vault
import hvac

client = hvac.Client(url='https://vault.midominio.com:8200')
client.token = os.environ['VAULT_TOKEN']

# Leer secretos
secrets = client.secrets.kv.v2.read_secret_version(
    mount_point='kv',
    path='microservicio/servicio-usuarios'
)
db_password = secrets['data']['data']['db_password']
```

#### Usando Kubernetes ConfigMaps

```yaml
# ConfigMap para configuración de microservicios
apiVersion: v1
kind: ConfigMap
metadata:
  name: servicio-usuarios-config
data:
  database_url: "postgres://usuario@postgres:5432/usuarios"
  redis_url: "redis://redis:6379/0"
  log_level: "INFO"
  max_connections: "100"
```

## Observabilidad

La observabilidad es crucial para entender el comportamiento de los microservicios en producción.

### 1. Logs Centralizados

```python
# Configuración de logging para ELK Stack
import logging
from logstash_formatter import LogstashFormatterV1

handler = logging.StreamHandler()
handler.setFormatter(LogstashFormatterV1())

logger = logging.getLogger('servicio-usuarios')
logger.addHandler(handler)
logger.setLevel(logging.INFO)

logger.info('Procesando solicitud', extra={
    'usuario_id': usuario.id,
    'accion': 'actualizar_perfil',
    'tiempo_ms': 235
})
```

### 2. Métricas

```python
# Instrumentación con Prometheus en Python
from prometheus_client import Counter, Histogram, start_http_server

# Definir métricas
REQUEST_COUNT = Counter('request_count', 'Número total de peticiones', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('request_latency_seconds', 'Latencia de las peticiones', ['method', 'endpoint'])

# Middleware para FastAPI
@app.middleware("http")
async def track_requests(request, call_next):
    method = request.method
    path = request.url.path
    
    REQUEST_COUNT.labels(method=method, endpoint=path).inc()
    
    with REQUEST_LATENCY.labels(method=method, endpoint=path).time():
        response = await call_next(request)
        
    return response

# Exponer métricas en endpoint
start_http_server(8000)
```

### 3. Trazabilidad (Tracing)

```python
# Instrumentación con OpenTelemetry
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.jaeger.thrift import JaegerExporter

# Configurar el tracer
trace.set_tracer_provider(TracerProvider())
jaeger_exporter = JaegerExporter(
    agent_host_name="jaeger",
    agent_port=6831,
)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(jaeger_exporter)
)

# Usar el tracer
tracer = trace.get_tracer(__name__)

def procesar_pedido(pedido_id):
    with tracer.start_as_current_span("procesar_pedido") as span:
        span.set_attribute("pedido.id", pedido_id)
        # Lógica de procesamiento
        resultado = cargar_pedido(pedido_id)
        return resultado

def cargar_pedido(pedido_id):
    with tracer.start_as_current_span("cargar_pedido") as span:
        span.set_attribute("db.operation", "SELECT")
        # Operación de base de datos
        return {"id": pedido_id, "estado": "completado"}
```

## Mejores Prácticas de Despliegue

1. **Automatizar todo**: Utilizar CI/CD para eliminar errores manuales
2. **Inmutabilidad**: Los contenedores desplegados no deben modificarse, sino reemplazarse
3. **Pruebas automatizadas**: Incluir pruebas unitarias, de integración y de extremo a extremo
4. **Despliegues incrementales**: Evitar despliegues de "big bang"
5. **Capacidad de rollback**: Poder revertir rápidamente a una versión anterior
6. **Gestión de estado**: Manejar correctamente los datos y estado entre actualizaciones
7. **Supervisión proactiva**: Monitorear no solo fallos sino también degradación del rendimiento

## Patrones de Despliegue según el Tamaño del Equipo

### Para Equipos Pequeños (1-3 Desarrolladores)
- Docker Compose para desarrollo local
- Plataformas como Heroku, Google App Engine o AWS Elastic Beanstalk
- Jenkins simple o GitHub Actions para CI/CD

### Para Equipos Medianos (4-10 Desarrolladores)
- Kubernetes gestionado (EKS, GKE, AKS)
- Terraform para infraestructura
- Pipeline de CI/CD más completo con etapas de pruebas

### Para Equipos Grandes (10+ Desarrolladores)
- Kubernetes autogestionado o multinube
- GitOps con Flux o ArgoCD
- Malla de servicios (Service Mesh) como Istio
- Plataforma interna de desarrollo (Internal Developer Platform)

La elección de la estrategia de despliegue correcta dependerá del tamaño del equipo, complejidad del sistema, y requisitos específicos de tu organización. 