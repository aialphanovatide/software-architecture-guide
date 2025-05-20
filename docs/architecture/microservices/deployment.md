# Desplegando Microservicios

## ¿Qué significa desplegar microservicios?

Desplegar microservicios significa poner tus aplicaciones en un entorno donde puedan funcionar para usuarios reales. A diferencia de las aplicaciones monolíticas donde despliegas una sola pieza, con microservicios necesitas coordinar el despliegue de múltiples piezas independientes.

## ¿Por qué es importante entender el despliegue?

Como desarrollador, necesitas entender cómo tus microservicios:
- Se ejecutan en producción
- Se comunican entre sí
- Se monitorean
- Se escalan cuando es necesario

No importa lo bien que escribas tu código: si no se despliega correctamente, no funcionará para tus usuarios.

## Desafíos Específicos de Desplegar Microservicios

Desplegar microservicios presenta retos únicos comparado con monolitos:

| Desafío | Explicación | Cómo afecta a tu trabajo |
|---------|-------------|-------------------------|
| Múltiples componentes | Decenas o cientos de servicios que desplegar | Necesitas automatización para gestionar todo |
| Dependencias entre servicios | Los servicios dependen unos de otros | Tienes que pensar en el orden y compatibilidad |
| Configuración distribuida | Cada servicio necesita su propia configuración | Debes gestionar variables de entorno y secretos a escala |
| Seguimiento de problemas | Los errores pueden ocurrir en cualquier servicio | Necesitas buena observabilidad para saber qué pasó dónde |
| Actualizaciones sin interrupciones | Usuarios no deben notar los despliegues | Se requieren estrategias como rolling updates |

## Conceptos Fundamentales para el Despliegue

### 1. Contenedorización con Docker

Docker es el estándar de facto para empaquetar microservicios. Permite ejecutar tus aplicaciones de forma consistente en cualquier entorno.

#### ¿Qué es un contenedor?

Un contenedor es como una mini computadora virtual que incluye tu aplicación y todo lo que necesita para funcionar.

```dockerfile
# Dockerfile básico para una aplicación Python
FROM python:3.10-slim

WORKDIR /app

# Copiar los archivos de dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación
COPY . .

# Variable de entorno que se puede cambiar al ejecutar
ENV PORT=8000

# Puerto en que escuchará la aplicación
EXPOSE $PORT

# Comando para iniciar la aplicación
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "${PORT}"]
```

#### Principales comandos de Docker:

```bash
# Construir una imagen desde un Dockerfile
docker build -t mi-servicio:1.0 .

# Ejecutar un contenedor
docker run -p 8000:8000 mi-servicio:1.0

# Ver contenedores en ejecución
docker ps

# Ver logs de un contenedor
docker logs [id-del-contenedor]

# Detener un contenedor
docker stop [id-del-contenedor]
```

### 2. Desarrollo Local con Docker Compose

Docker Compose permite ejecutar múltiples servicios juntos localmente, perfecto para desarrollo.

```yaml
# docker-compose.yml básico para un sistema de microservicios
version: '3.8'

services:
  # Servicio de usuarios
  user-service:
    build: ./user-service
    ports:
      - "8001:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/userdb
      - JWT_SECRET=dev_secret_key
    depends_on:
      - db
      
  # Servicio de productos
  product-service:
    build: ./product-service
    ports:
      - "8002:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/productdb
    depends_on:
      - db
      
  # API Gateway
  api-gateway:
    build: ./api-gateway
    ports:
      - "8000:8000"
    environment:
      - USER_SERVICE_URL=http://user-service:8000
      - PRODUCT_SERVICE_URL=http://product-service:8000
    depends_on:
      - user-service
      - product-service
  
  # Base de datos compartida (solo para desarrollo)
  db:
    image: postgres:14
    environment:
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
```

#### Comandos básicos de Docker Compose:

```bash
# Iniciar todos los servicios
docker-compose up

# Iniciar en modo detached (background)
docker-compose up -d

# Ver logs de todos los servicios
docker-compose logs

# Ver logs de un servicio específico
docker-compose logs product-service

# Detener todos los servicios
docker-compose down
```

### 3. Infraestructura como Código (IaC)

En lugar de configurar servidores manualmente, defines tu infraestructura en archivos de código.

#### Terraform: Define recursos en la nube

Terraform es una herramienta que permite definir infraestructura en la nube usando código. Ejemplo simplificado:

```hcl
# Define un clúster Kubernetes en AWS
resource "aws_eks_cluster" "microservices_cluster" {
  name     = "microservices-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnet[*].id
  }
}

# Define un grupo de nodos para ejecutar tus microservicios
resource "aws_eks_node_group" "microservices_nodes" {
  cluster_name    = aws_eks_cluster.microservices_cluster.name
  node_group_name = "microservices-workers"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = aws_subnet.eks_subnet[*].id
  
  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}
```

### 4. Orquestación de Contenedores con Kubernetes

Kubernetes (K8s) es el estándar para gestionar contenedores en producción. Automatiza:
- Despliegue de contenedores
- Escalado 
- Recuperación ante fallos
- Balanceo de carga

#### Elementos básicos de Kubernetes:

1. **Pod**: La unidad más pequeña, uno o más contenedores
2. **Deployment**: Gestiona versiones y actualizaciones de Pods
3. **Service**: Proporciona un punto de acceso estable a los Pods
4. **ConfigMap/Secret**: Configuración y secretos para los Pods
5. **Ingress**: Expone servicios HTTP/HTTPS al exterior

Ejemplo de un archivo Kubernetes para un microservicio:

```yaml
# Deployment para gestionar las réplicas del servicio de usuarios
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 3  # Ejecutar 3 instancias para alta disponibilidad
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: myregistry/user-service:1.0.5
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: user-db-url
        resources:
          limits:
            cpu: "0.5"
            memory: "512Mi"
          requests:
            cpu: "0.2"
            memory: "256Mi"
        livenessProbe:  # Verifica si el servicio está vivo
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:  # Verifica si el servicio está listo para recibir tráfico
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
# Service para exponer el Deployment internamente
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
```

## Estrategias de Despliegue

Existen varias estrategias para actualizar tus servicios sin afectar a los usuarios:

### 1. Rolling Updates (Actualizaciones Continuas)

Las instancias antiguas se reemplazan gradualmente por nuevas.

```
Antes:  [V1] [V1] [V1] [V1]
Paso 1: [V1] [V1] [V2] [V1]
Paso 2: [V1] [V2] [V2] [V1]
Paso 3: [V2] [V2] [V2] [V1]
Después: [V2] [V2] [V2] [V2]
```

**Ventajas:**
- Actualización sin tiempo de inactividad
- Implementación predeterminada en Kubernetes

### 2. Blue/Green Deployment (Despliegue Azul/Verde)

Ejecutas dos entornos idénticos (azul=actual, verde=nuevo) y cambias el tráfico cuando el nuevo está listo.

```
Antes:     [Tráfico] → [Entorno Azul V1]
           [Entorno Verde V2] (en pruebas, sin tráfico)
Cambio:    [Tráfico] → [Entorno Verde V2]
Después:   [Entorno Azul V1] (se puede eliminar o mantener para rollback)
```

**Ventajas:**
- Cambio rápido entre versiones
- Fácil rollback
- Pruebas completas antes de cambiar

### 3. Canary Deployment (Despliegue Canario)

Envías un pequeño porcentaje de tráfico a la nueva versión y lo aumentas gradualmente.

```
Inicial:   [Tráfico] → 100% → [V1]
Canario:   [Tráfico] → 90% → [V1]
                     → 10% → [V2]
Gradual:   [Tráfico] → 50% → [V1]
                     → 50% → [V2]
Final:     [Tráfico] → 100% → [V2]
```

**Ventajas:**
- Exposición gradual a nuevas versiones
- Detección temprana de problemas en producción
- Minimiza el impacto de errores

## Ejemplo Práctico: Despliegue Completo

Veamos cómo se desplegaría un sistema completo de microservicios en Kubernetes:

1. **Paso 1**: Construir imágenes Docker para cada servicio
    ```bash
    docker build -t my-registry/user-service:1.0.5 ./user-service
    docker build -t my-registry/product-service:1.2.1 ./product-service
    docker build -t my-registry/order-service:0.9.3 ./order-service
    docker build -t my-registry/api-gateway:1.1.0 ./api-gateway
    ```

2. **Paso 2**: Subir imágenes al registro
    ```bash
    docker push my-registry/user-service:1.0.5
    docker push my-registry/product-service:1.2.1
    docker push my-registry/order-service:0.9.3
    docker push my-registry/api-gateway:1.1.0
    ```

3. **Paso 3**: Aplicar configuraciones a Kubernetes
    ```bash
    # Aplicar secretos y configuraciones
    kubectl apply -f config/secrets.yaml
    kubectl apply -f config/configmaps.yaml
    
    # Desplegar servicios de base de datos
    kubectl apply -f db/postgres.yaml
    kubectl apply -f db/redis.yaml
    
    # Desplegar microservicios
    kubectl apply -f services/user-service.yaml
    kubectl apply -f services/product-service.yaml
    kubectl apply -f services/order-service.yaml
    
    # Desplegar API Gateway e Ingress
    kubectl apply -f api-gateway.yaml
    kubectl apply -f ingress.yaml
    ```

4. **Paso 4**: Verificar despliegue
    ```bash
    # Ver pods en ejecución
    kubectl get pods
    
    # Ver servicios
    kubectl get services
    
    # Ver logs de un servicio específico
    kubectl logs -l app=user-service
    ```

## Buenas Prácticas para Despliegue de Microservicios

1. **Automatiza todo**: Usa CI/CD para evitar errores manuales
2. **Versiona tus imágenes**: Nunca uses etiquetas como `latest`
3. **Configura health checks**: Para detectar servicios que no están funcionando correctamente
4. **Implementa monitoreo y logging**: Necesitas saber qué está pasando en cada servicio
5. **Usa entornos idénticos**: Desarrollo, pruebas y producción deben ser lo más similares posible
6. **Planifica tu estrategia de red**: Define claramente cómo se comunican los servicios
7. **Configura recursos adecuados**: CPU, memoria y disco para cada servicio

## Preguntas de Reflexión

1. ¿Qué estrategia de despliegue (rolling, blue/green, canary) crees que sería más adecuada para un servicio crítico de procesamiento de pagos? ¿Por qué?

2. Si tuvieras que desplegar un nuevo microservicio que depende de otros tres servicios existentes, ¿qué consideraciones tendrías que tener en cuenta?

3. ¿Cómo cambiaría tu enfoque de despliegue si estuvieras trabajando en una startup con recursos limitados versus una gran empresa con infraestructura existente? 