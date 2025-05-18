# Registros de Decisiones de Arquitectura (ADRs)

Los Registros de Decisiones de Arquitectura (ADRs, por sus siglas en inglés) son documentos que capturan decisiones arquitectónicas importantes tomadas en un proyecto, junto con su contexto y consecuencias. Son una herramienta valiosa para documentar, comunicar y planificar la evolución de la arquitectura de un sistema.

## ¿Por qué utilizar ADRs?

Los ADRs ofrecen múltiples beneficios:

1. **Memoria organizacional**: Preservan el conocimiento que de otro modo podría perderse con la rotación del personal
2. **Contexto para futuras decisiones**: Proporcionan el "por qué" detrás de la arquitectura existente
3. **Onboarding más efectivo**: Ayudan a nuevos miembros del equipo a entender rápidamente las decisiones pasadas
4. **Transparencia**: Documentan el proceso de toma de decisiones para todas las partes interesadas
5. **Mejor planificación**: Fomentan un pensamiento más cuidadoso sobre las decisiones arquitectónicas

## Estructura recomendada para ADRs

Un ADR efectivo debe incluir:

### 1. Título

Un título claro y descriptivo que identifique la decisión.

Ejemplo: "ADR 001: Adopción de GraphQL para APIs en microservicios internos"

### 2. Estado

El estado actual de la decisión:

- **Propuesto**: Decisión en consideración
- **Aceptado**: Decisión aprobada
- **Rechazado**: Decisión considerada pero no aprobada
- **Reemplazado**: Decisión que ha sido sustituida por otra (incluir referencia)
- **Obsoleto**: Decisión que ya no es relevante

### 3. Contexto

Describir la situación que ha llevado a la necesidad de tomar esta decisión. Incluir:

- Problema a resolver
- Restricciones conocidas
- Estado actual del sistema
- Fuerzas que influyen en la decisión

### 4. Decisión

La decisión arquitectónica tomada, explicada de forma clara y concisa.

### 5. Consecuencias

Las consecuencias (positivas y negativas) resultantes de esta decisión:

- Impacto técnico
- Impacto en recursos y costos
- Impacto en mantenibilidad y escalabilidad
- Riesgos introducidos o mitigados
- Dependencias creadas o eliminadas

### 6. Alternativas consideradas

Otras opciones que se evaluaron pero no fueron seleccionadas, y por qué.

### 7. Referencias

Enlaces a documentos relevantes, investigaciones, o ADRs relacionados.

## Ejemplo de ADR

```markdown
# ADR 002: Adopción de CQRS para el Servicio de Pedidos

## Estado

Aceptado (2023-05-15)

## Contexto

El servicio de pedidos está experimentando problemas de rendimiento y complejidad debido a que las operaciones de lectura y escritura tienen requisitos muy diferentes:

- Las operaciones de escritura requieren validaciones complejas, consistencia transaccional y generación de eventos
- Las operaciones de lectura requieren consultas optimizadas para diferentes vistas (historial de pedidos, dashboard, reportes)
- El modelo actual intenta satisfacer ambos tipos de operaciones, resultando en un compromiso ineficiente

Además, las consultas analíticas están impactando el rendimiento de las operaciones transaccionales.

## Decisión

Implementaremos el patrón Command Query Responsibility Segregation (CQRS) en el servicio de pedidos, separando:

1. **Modelo de comandos**: Optimizado para operaciones de escritura, con dominio rico basado en DDD
2. **Modelo de consultas**: Optimizado para lecturas, con modelos desnormalizados y específicos para cada tipo de consulta

Utilizaremos eventos de dominio para sincronizar los cambios del modelo de comandos al modelo de consultas.

## Consecuencias

### Positivas

- Mejor rendimiento para operaciones de lectura y escritura al optimizarlas por separado
- Posibilidad de escalar los componentes de lectura y escritura independientemente
- Mayor flexibilidad para evolucionar el modelo de dominio sin afectar a las consultas
- Capacidad para adaptarse a requisitos específicos de consulta sin comprometer el modelo de dominio

### Negativas

- Mayor complejidad en la arquitectura general
- Consistencia eventual entre los modelos de comando y consulta
- Curva de aprendizaje para el equipo
- Duplicación de datos entre los modelos

## Alternativas consideradas

### 1. Optimización del modelo actual

Consideramos optimizar el modelo actual sin separar lecturas/escrituras, usando:
- Índices especializados
- Cachés de lectura
- Optimización de consultas

Esta opción fue rechazada porque solo aliviaría el problema temporalmente sin resolver la discordancia fundamental entre los requisitos de lectura y escritura.

### 2. Vistas materializadas en la base de datos

Consideramos implementar vistas materializadas en la base de datos para consultas complejas.

Esta opción fue rechazada porque seguiría acoplando los modelos de lectura y escritura, y porque no tendríamos el control granular que ofrece CQRS para optimizar cada modelo.

## Referencias

- [Martin Fowler sobre CQRS](https://martinfowler.com/bliki/CQRS.html)
- [Microservicios.io - Patrón CQRS](https://microservices.io/patterns/data/cqrs.html)
- [ADR-001: Adopción de Event Sourcing]
```

## Proceso para crear y gestionar ADRs

### 1. Cuándo crear un ADR

Crea un ADR cuando se toma una decisión arquitectónica significativa:

- Selección de tecnologías o frameworks importantes
- Patrones arquitectónicos a implementar
- Estrategias de integración entre componentes
- Enfoques para problemas complejos de diseño
- Cambios arquitectónicos relevantes

### 2. Flujo de trabajo recomendado

1. **Propuesta**: Crear un borrador de ADR en una rama de características
2. **Revisión**: Compartir con el equipo para obtener feedback
3. **Refinamiento**: Mejorar basándose en las sugerencias
4. **Decisión**: Aprobar o rechazar el ADR (generalmente en una reunión de arquitectura)
5. **Publicación**: Combinar el ADR aprobado en la rama principal

### 3. Herramientas y almacenamiento

Almacena los ADRs junto con el código fuente:

```
docs/
└── architecture/
    └── decisions/
        ├── 0001-adopcion-de-microservicios.md
        ├── 0002-implementacion-cqrs-servicio-pedidos.md
        ├── 0003-seleccion-de-kafka-para-eventos.md
        └── index.md
```

Puedes usar herramientas como:
- [adr-tools](https://github.com/npryce/adr-tools): CLI para gestionar ADRs
- Plantillas en Markdown dentro del repositorio
- Integración con sistemas de documentación como MkDocs

## Buenas prácticas para ADRs efectivos

### 1. Mantenlos concisos

- Enfócate en lo esencial
- Un ADR no debe exceder las 2 páginas (en formato Markdown)
- Evita detalles de implementación que no sean arquitectónicamente relevantes

### 2. Usa un lenguaje claro

- Evita jerga innecesaria
- Define términos técnicos si no son ampliamente conocidos
- Utiliza diagramas cuando clarifiquen la explicación

### 3. Numera secuencialmente los ADRs

Usa un esquema de numeración simple y secuencial:
- ADR-0001
- ADR-0002
- etc.

### 4. Vincula ADRs relacionados

Establece referencias cruzadas entre ADRs cuando existan relaciones:

```markdown
## Referencias

- [ADR-0005: Selección de base de datos NoSQL](./0005-seleccion-de-base-de-datos-nosql.md) - Influye en cómo implementamos el almacenamiento para este componente
```

### 5. No cambies los ADRs existentes

Los ADRs son inmutables después de ser aceptados:
- No modifiques decisiones pasadas
- Si una decisión cambia, crea un nuevo ADR que reemplace al anterior
- Actualiza solo el campo "Estado" del ADR original para indicar que ha sido reemplazado

### 6. Revisa periódicamente

Programa revisiones periódicas de los ADRs existentes para:
- Verificar que sigan siendo relevantes
- Identificar decisiones que necesiten ser reemplazadas
- Asegurar que la arquitectura está evolucionando según lo planeado

## Plantilla para ADRs

```markdown
# ADR [Número]: [Título]

## Estado

[Propuesto | Aceptado | Rechazado | Reemplazado por [ADR-XXX](./XXX-nombre.md) | Obsoleto]

Fecha: [YYYY-MM-DD]

## Contexto

[Descripción del contexto y problema]

## Decisión

[Descripción de la decisión tomada]

## Consecuencias

### Positivas

- [Consecuencia positiva 1]
- [Consecuencia positiva 2]

### Negativas

- [Consecuencia negativa 1]
- [Consecuencia negativa 2]

## Alternativas consideradas

### [Alternativa 1]

[Descripción y razones para no seleccionarla]

### [Alternativa 2]

[Descripción y razones para no seleccionarla]

## Referencias

- [Enlace 1]
- [Enlace 2]
```

## Consejos para la adopción en el equipo

### 1. Introducción gradual

- Comienza con decisiones importantes recientes
- Documenta las decisiones nuevas a medida que surgen
- Cuando sea posible, documenta retrospectivamente decisiones clave ya tomadas

### 2. Capacitación del equipo

- Realiza una sesión de capacitación sobre ADRs
- Comparte ejemplos de ADRs bien escritos
- Proporciona plantillas y directrices claras

### 3. Integración en el proceso

- Incluye la creación de ADRs en las ceremonias del equipo
- Considera los ADRs como artefactos de entrega para decisiones arquitectónicas
- Revisa los ADRs como parte del proceso de revisión de código para cambios arquitectónicos

### 4. Fomenta la colaboración

- Permite que cualquier miembro del equipo proponga un ADR
- Usa revisiones por pares para mejorar la calidad
- Revisa y discute los ADRs en reuniones de arquitectura

## Conclusión

Los Registros de Decisiones de Arquitectura son una herramienta valiosa para cualquier equipo de desarrollo de software. Proporcionan transparencia, preservan el conocimiento y mejoran la toma de decisiones arquitectónicas. Al adoptar ADRs, tu equipo estará mejor equipado para gestionar la complejidad arquitectónica y evolucionar el sistema de manera efectiva a lo largo del tiempo. 