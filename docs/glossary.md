# Glosario de Arquitectura de Software

Este glosario proporciona definiciones claras de términos clave utilizados en arquitectura de software, facilitando un vocabulario común para nuestro equipo.

## A

**Acoplamiento**: Grado de interdependencia entre módulos de software. Un bajo acoplamiento es deseable para mejorar la mantenibilidad y escalabilidad.

**API (Application Programming Interface)**: Conjunto de reglas y especificaciones que permite a diferentes aplicaciones comunicarse entre sí.

**Agregado (Aggregate)**: En DDD, un grupo de objetos relacionados que se tratan como una unidad cohesiva para cambios de datos con una entidad raíz que garantiza la consistencia.

**Arquitectura hexagonal**: También conocida como "Ports and Adapters", aísla la lógica central de la aplicación de servicios externos utilizando puertos e interfaces.

## B

**Backend**: Parte de una aplicación que maneja la lógica de negocio, el acceso a datos y la autenticación, ejecutándose en el servidor.

**Bounded Context**: Concepto de DDD que define un límite explícito dentro del cual un modelo de dominio se aplica consistentemente.

**Behavior-Driven Development (BDD)**: Metodología de desarrollo que extiende TDD para enfocarse en el comportamiento esperado del sistema usando un lenguaje compartido con los stakeholders.

## C

**Capas (Layered Architecture)**: Patrón que organiza el código en capas con responsabilidades específicas (presentación, aplicación, dominio, infraestructura).

**Clean Architecture**: Enfoque propuesto por Robert C. Martin que enfatiza la separación de preocupaciones y la independencia de frameworks.

**CQRS (Command Query Responsibility Segregation)**: Patrón que separa las operaciones de lectura (queries) de las de escritura (commands).

**Cohesión**: Medida en que los elementos de un módulo pertenecen juntos. Alta cohesión es deseable.

**Contexto Acotado (Bounded Context)**: En DDD, un límite explícito dentro del cual un modelo de dominio particular se aplica de manera consistente.

**Command**: Objeto que encapsula toda la información necesaria para realizar una acción o desencadenar un evento en el sistema.

## D

**DDD (Domain-Driven Design)**: Enfoque que centra el desarrollo en el modelado del dominio del negocio.

**Dependencia**: Relación donde un componente requiere otro para funcionar correctamente.

**DTO (Data Transfer Object)**: Objeto que transporta datos entre procesos sin comportamiento adicional.

**Domain Events**: Eventos que representan ocurrencias significativas dentro del dominio de negocio.

**Domain Model**: Modelo abstracto del dominio que incorpora tanto comportamiento como datos.

**Domain Service**: Servicio que encapsula lógica de negocio que no pertenece naturalmente a ninguna entidad o valor objeto.

## E

**Entidad**: Objeto con identidad única y persistencia que representa un concepto del dominio.

**Event Sourcing**: Patrón donde los cambios de estado se capturan como una secuencia de eventos.

**Event-Driven Architecture**: Arquitectura donde los componentes se comunican a través de eventos.

**Enfoque Feature-First**: Organización del código alrededor de características funcionales completas en lugar de capas técnicas.

## F

**Factory Pattern**: Patrón de diseño creacional que proporciona una interfaz para crear objetos.

**Frontend**: Parte de una aplicación que interactúa directamente con el usuario.

**Facade Pattern**: Patrón de diseño estructural que proporciona una interfaz simplificada a un subsistema complejo.

## I

**Inyección de Dependencias**: Técnica donde un objeto recibe otros objetos de los que depende externamente.

**Interfaz**: Contrato que define un conjunto de métodos que una clase debe implementar.

**Invariantes**: Condiciones o reglas que deben mantenerse verdaderas durante la vida de un objeto o sistema.

## M

**Microservicios**: Arquitectura que estructura una aplicación como un conjunto de servicios pequeños, autónomos y con un único propósito.

**Modelo de Dominio**: Representación conceptual de las entidades, valores y reglas de negocio relevantes.

**Monolito**: Aplicación donde todos los componentes están integrados en una sola unidad desplegable.

**Modelo Anémico**: Antipatrón donde las entidades de dominio contienen principalmente datos sin comportamiento significativo.

**Mappers**: Componentes responsables de transformar datos entre diferentes representaciones, como entidades de dominio y modelos de persistencia.

**Mediator Pattern**: Patrón de diseño que reduce el acoplamiento entre componentes al hacer que se comuniquen indirectamente a través de un objeto mediador.

## O

**Objeto de Valor (Value Object)**: Objeto inmutable que representa un concepto descriptivo dentro del dominio.

**Onion Architecture**: Arquitectura en capas concéntricas donde las dependencias apuntan hacia el centro, que contiene las entidades y reglas de negocio.

## P

**Patrón de Diseño**: Solución reutilizable a problemas comunes en el diseño de software.

**Principio de Responsabilidad Única**: Principio SOLID que establece que una clase debe tener una sola razón para cambiar.

**Principio de Inversión de Dependencias**: Principio SOLID donde los módulos de alto nivel no deben depender de módulos de bajo nivel, ambos deben depender de abstracciones.

**Patrón Repository**: Abstracción que encapsula la lógica para acceder a una fuente de datos, proporcionando una vista orientada a objetos de colección.

## R

**RESTful API**: API que sigue los principios de REST (Representational State Transfer).

**Repositorio**: Abstracción que proporciona una interfaz para acceder y persistir objetos del dominio.

**Reactive Programming**: Paradigma de programación orientado a flujos de datos asíncronos y propagación de cambios.

## S

**Saga Pattern**: Patrón para gestionar transacciones distribuidas en arquitecturas de microservicios.

**SOLID**: Conjunto de cinco principios de diseño orientado a objetos (SRP, OCP, LSP, ISP, DIP).

**Service Mesh**: Infraestructura dedicada a gestionar la comunicación entre servicios.

**Servicio de Aplicación**: Coordina actividades de alto nivel, típicamente implementando casos de uso mediante la orquestación de servicios de dominio, repositorios y entidades.

**Specification Pattern**: Patrón que permite encapsular reglas de negocio en objetos independientes que pueden combinarse mediante operaciones lógicas.

## T

**TDD (Test-Driven Development)**: Práctica donde se escriben primero las pruebas antes de implementar la funcionalidad.

**Transaction Script**: Patrón donde la lógica de negocio se organiza en procedimientos, cada uno manejando una única petición.

**Tactical Design**: En DDD, se refiere a los patrones específicos utilizados para implementar el modelo de dominio (entidades, objetos de valor, agregados, etc.).

## U

**Ubiquitous Language**: Lenguaje compartido entre desarrolladores y expertos del dominio en DDD.

**Unit of Work**: Patrón que mantiene una lista de objetos afectados por una transacción de negocio y coordina la escritura de cambios y la resolución de problemas de concurrencia.

## V

**Vertical Slice Architecture**: Enfoque que organiza el código por características completas en lugar de por capas técnicas.

**Value Object**: Objeto que representa un concepto descriptivo dentro del dominio y se caracteriza por no tener identidad propia y ser inmutable. 