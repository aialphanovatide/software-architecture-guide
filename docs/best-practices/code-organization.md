# Organización del Código

Una organización de código efectiva es fundamental para crear software mantenible, escalable y comprensible. Esta sección presenta las mejores prácticas para organizar el código en proyectos de software, independientemente de la arquitectura específica.

## Principios Generales

### 1. Coherencia

La coherencia en la organización del código facilita la navegación, comprensión y mantenimiento del sistema:

- Utiliza convenciones de nomenclatura consistentes
- Mantén una estructura de directorios uniforme
- Sigue patrones de diseño de manera constante
- Aplica el mismo estilo de codificación en todo el proyecto

### 2. Cohesión Alta

Cada módulo, clase o función debe tener una responsabilidad clara y enfocada:

- Agrupa código con propósitos relacionados
- Evita clases o módulos que hagan demasiadas cosas
- Sigue el [Principio de Responsabilidad Única](../solid/single-responsibility.md)

### 3. Acoplamiento Bajo

Minimiza las dependencias entre componentes:

- Reduce las referencias directas entre módulos
- Utiliza interfaces para desacoplar implementaciones
- Aplica inyección de dependencias
- Comunica componentes a través de abstracciones, no implementaciones concretas

## Estructura de Directorios

### Estructura por Capas

Una estructura por capas separa el código según su nivel de abstracción y responsabilidad:

```
proyecto/
├── src/
│   ├── api/                # Interfaz de API
│   ├── application/        # Lógica de aplicación
│   ├── domain/             # Lógica de dominio
│   ├── infrastructure/     # Implementaciones técnicas
│   └── utils/              # Utilidades generales
├── tests/                  # Pruebas
└── docs/                   # Documentación
```

### Estructura por Funcionalidad

Una estructura por funcionalidad organiza el código según las capacidades de negocio:

```
proyecto/
├── src/
│   ├── usuarios/           # Todo lo relacionado con usuarios
│   ├── productos/          # Todo lo relacionado con productos
│   ├── pedidos/            # Todo lo relacionado con pedidos
│   └── común/              # Código compartido
├── tests/
└── docs/
```

### Estructura Híbrida

Muchos proyectos modernos combinan ambos enfoques:

```
proyecto/
├── src/
│   ├── usuarios/
│   │   ├── api/
│   │   ├── domain/
│   │   ├── application/
│   │   └── infrastructure/
│   ├── productos/
│   │   ├── api/
│   │   ├── domain/
│   │   ├── application/
│   │   └── infrastructure/
│   └── común/
├── tests/
└── docs/
```

## Convenciones de Nomenclatura

### Archivos y Directorios

- Utiliza nombres descriptivos que indiquen claramente el propósito
- Mantén coherencia en el formato (snake_case, camelCase, etc.)
- Evita nombres genéricos como "utils" o "helpers" sin contexto

### Clases y Funciones

- Nombres de clases: sustantivos que describan claramente su propósito
- Nombres de funciones: verbos que describan la acción realizada
- Prefijos y sufijos consistentes (ej. `Usuario` y `UsuarioRepository`)

### Ejemplos en Python

```python
# Bueno: nombres descriptivos y consistentes
class UsuarioRepository:
    def buscar_por_email(self, email: str) -> Optional[Usuario]:
        pass

# Evitar: nombres ambiguos o inconsistentes
class UR:
    def find(self, e: str) -> Optional[Usuario]:
        pass
```

### Ejemplos en TypeScript

```typescript
// Bueno: nombres descriptivos y consistentes
interface UserRepository {
  findByEmail(email: string): Promise<User | null>;
}

// Evitar: nombres ambiguos o inconsistentes
interface Repo {
  getUser(e: string): Promise<User | null>;
}
```

## Modularización Efectiva

### Tamaño de los Módulos

- Mantén los módulos pequeños y enfocados
- Si un archivo supera las 300-500 líneas, considera dividirlo
- Cada módulo debe ser fácilmente comprensible en su totalidad

### Dependencias entre Módulos

- Evita dependencias circulares
- Organiza los módulos en una jerarquía clara
- Utiliza el patrón mediador para comunicación entre módulos cuando sea necesario

### Encapsulación

- Expón solo lo necesario a través de interfaces públicas
- Oculta los detalles de implementación
- Utiliza patrones como Fachada para simplificar interfaces complejas

## Gestión de Importaciones

### Organización de Importaciones

- Agrupa las importaciones por categoría
- Mantén un orden consistente (estándar, terceros, proyecto)
- Evita importaciones genéricas con asterisco

### Ejemplos en Python

```python
# Importaciones estándar
import datetime
import json
from typing import List, Optional

# Importaciones de terceros
import sqlalchemy
from fastapi import APIRouter, Depends

# Importaciones del proyecto
from app.domain.usuario import Usuario
from app.infrastructure.database import get_session
```

### Ejemplos en TypeScript

```typescript
// Importaciones estándar
import * as fs from 'fs';
import * as path from 'path';

// Importaciones de terceros
import { Injectable } from '@nestjs/common';
import { Repository } from 'typeorm';

// Importaciones del proyecto
import { User } from '../domain/models/user';
import { UserRepository } from '../domain/repositories/user-repository';
```

## Patrones Comunes de Organización

### Separación de Interfaces e Implementaciones

- Define interfaces en capas de dominio o aplicación
- Implementa interfaces en la capa de infraestructura
- Usa inyección de dependencias para conectar interfaces e implementaciones

```python
# En domain/repository/usuario_repository.py
from abc import ABC, abstractmethod

class IUsuarioRepository(ABC):
    @abstractmethod
    def buscar_por_id(self, id: str):
        pass

# En infrastructure/repository/usuario_repository_impl.py
class SQLUsuarioRepository(IUsuarioRepository):
    def buscar_por_id(self, id: str):
        # Implementación con SQL
        pass
```

### Organización de Pruebas

- Estructura de pruebas que refleje la estructura del código
- Nombres descriptivos para archivos y funciones de prueba
- Separa pruebas por tipo (unitarias, integración, e2e)

```
tests/
├── unit/
│   ├── domain/
│   ├── application/
│   └── infrastructure/
├── integration/
└── e2e/
```

## Mejores Prácticas para Python

### Estructura de Paquetes

- Utiliza `__init__.py` para definir la API pública de los paquetes
- Aprovecha el patrón de importaciones relativas para importaciones internas del paquete
- Considera el uso de namespaces para organizar código relacionado

### Ejemplo de Estructura de Paquete Python

```python
# usuarios/__init__.py
from .models import Usuario
from .services import UsuarioService

__all__ = ["Usuario", "UsuarioService"]
```

## Mejores Prácticas para TypeScript

### Organización de Módulos

- Utiliza el sistema de módulos ES para organizar el código
- Aprovecha los archivos barrel (index.ts) para simplificar importaciones
- Considera el uso de namespaces para componentes relacionados

### Ejemplo de Barrel (index.ts)

```typescript
// src/users/index.ts
export * from './models/user';
export * from './services/user-service';
export * from './repositories/user-repository';
```

## Conclusión

Una organización de código efectiva no solo mejora la mantenibilidad y comprensión del sistema, sino que también facilita la colaboración en equipo y la evolución del software a lo largo del tiempo. Siguiendo estas prácticas recomendadas, podrás crear bases de código más limpias, comprensibles y adaptables a los cambios. 