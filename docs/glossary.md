# Glosario de Arquitectura de Software

Este glosario proporciona definiciones claras de términos clave utilizados en arquitectura de software, facilitando un vocabulario común para nuestro equipo.

## A

**Acoplamiento**: Grado de interdependencia entre módulos de software. Un bajo acoplamiento es deseable para mejorar la mantenibilidad y escalabilidad.

**API (Application Programming Interface)**: Conjunto de reglas y especificaciones que permite a diferentes aplicaciones comunicarse entre sí.

**Arquitectura hexagonal**: También conocida como "Ports and Adapters", aísla la lógica central de la aplicación de servicios externos utilizando puertos e interfaces.

## B

**Backend**: Parte de una aplicación que maneja la lógica de negocio, el acceso a datos y la autenticación, ejecutándose en el servidor.

**Bounded Context**: Concepto de DDD que define un límite explícito dentro del cual un modelo de dominio se aplica consistentemente.

## C

**Capas (Layered Architecture)**: Patrón que organiza el código en capas con responsabilidades específicas (presentación, aplicación, dominio, infraestructura).

**Clean Architecture**: Enfoque propuesto por Robert C. Martin que enfatiza la separación de preocupaciones y la independencia de frameworks.

**CQRS (Command Query Responsibility Segregation)**: Patrón que separa las operaciones de lectura (queries) de las de escritura (commands).

**Cohesión**: Medida en que los elementos de un módulo pertenecen juntos. Alta cohesión es deseable.

## D

**DDD (Domain-Driven Design)**: Enfoque que centra el desarrollo en el modelado del dominio del negocio.

**Dependencia**: Relación donde un componente requiere otro para funcionar correctamente.

**DTO (Data Transfer Object)**: Objeto que transporta datos entre procesos sin comportamiento adicional.

## E

**Entidad**: Objeto con identidad única y persistencia que representa un concepto del dominio.

**Event Sourcing**: Patrón donde los cambios de estado se capturan como una secuencia de eventos.

**Event-Driven Architecture**: Arquitectura donde los componentes se comunican a través de eventos.

## F

**Factory Pattern**: Patrón de diseño creacional que proporciona una interfaz para crear objetos.

**Frontend**: Parte de una aplicación que interactúa directamente con el usuario.

## I

**Inyección de Dependencias**: Técnica donde un objeto recibe otros objetos de los que depende externamente.

**Interfaz**: Contrato que define un conjunto de métodos que una clase debe implementar.

## M

**Microservicios**: Arquitectura que estructura una aplicación como un conjunto de servicios pequeños, autónomos y con un único propósito.

**Modelo de Dominio**: Representación conceptual de las entidades, valores y reglas de negocio relevantes.

**Monolito**: Aplicación donde todos los componentes están integrados en una sola unidad desplegable.

## O

**Objeto de Valor (Value Object)**: Objeto inmutable que representa un concepto descriptivo dentro del dominio.

## P

**Patrón de Diseño**: Solución reutilizable a problemas comunes en el diseño de software.

**Principio de Responsabilidad Única**: Principio SOLID que establece que una clase debe tener una sola razón para cambiar.

## R

**RESTful API**: API que sigue los principios de REST (Representational State Transfer).

**Repositorio**: Abstracción que proporciona una interfaz para acceder y persistir objetos del dominio.

## S

**Saga Pattern**: Patrón para gestionar transacciones distribuidas en arquitecturas de microservicios.

**SOLID**: Conjunto de cinco principios de diseño orientado a objetos (SRP, OCP, LSP, ISP, DIP).

**Service Mesh**: Infraestructura dedicada a gestionar la comunicación entre servicios.

## T

**TDD (Test-Driven Development)**: Práctica donde se escriben primero las pruebas antes de implementar la funcionalidad.

**Transaction Script**: Patrón donde la lógica de negocio se organiza en procedimientos, cada uno manejando una única petición.

## U

**Ubiquitous Language**: Lenguaje compartido entre desarrolladores y expertos del dominio en DDD.

## V

**Vertical Slice Architecture**: Enfoque que organiza el código por características completas en lugar de por capas técnicas. 