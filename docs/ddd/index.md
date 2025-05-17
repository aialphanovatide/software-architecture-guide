# Domain-Driven Design

Domain-Driven Design (DDD) is an approach to software development that places the primary focus on the core domain of the application. Introduced by Eric Evans in his book "Domain-Driven Design: Tackling Complexity in the Heart of Software," DDD provides both a philosophy and a set of patterns for creating software that accurately reflects the business domain it serves.

## Core Concepts

DDD shifts our focus from technical concerns to the business domain:

- We model our code to match the business domain
- We use the language of domain experts in our code
- We organize our system around domain concepts, not technical layers
- We isolate complex domain logic to keep it pure and maintainable

## Why Domain-Driven Design?

DDD is particularly valuable when building software for complex domains where:

- Business rules are numerous and nuanced
- There's specialized domain knowledge
- The domain evolves over time
- Multiple stakeholders have different perspectives
- Technical implementations could easily obscure domain logic

## Key Benefits

When implemented effectively, DDD provides:

- **Improved communication** between developers and domain experts
- **Better alignment** between code and business needs
- **Clearer boundaries** between different parts of the system
- **More maintainable** code that reflects real-world concepts
- **Easier evolution** as business rules change

## Core Concepts of DDD

DDD encompasses several key concepts that we'll explore in detail:

1. [**Ubiquitous Language**](ubiquitous-language.md) - A shared language between developers and domain experts
2. [**Bounded Contexts**](bounded-contexts.md) - Explicit boundaries where models apply
3. [**Entities and Value Objects**](entities-value-objects.md) - The building blocks of domain models
4. [**Aggregates**](aggregates.md) - Clusters of related entities with clear boundaries
5. [**Repositories**](repositories.md) - Methods for retrieving and persisting domain objects
6. [**Domain Services**](domain-services.md) - Operations that don't naturally belong to entities
7. [**Application Services**](application-services.md) - Orchestration of domain objects to perform use cases

## DDD in Practice

The following Python example illustrates a simple domain model using DDD concepts:

```python
from dataclasses import dataclass
from typing import List, Optional

# Value Object
@dataclass(frozen=True)
class Email:
    """Email value object with validation."""
    address: str
    
    def __post_init__(self):
        if "@" not in self.address:
            raise ValueError(f"Invalid email: {self.address}")

# Entity
class User:
    """User entity with unique identity."""
    def __init__(self, user_id: int, name: str, email: Email):
        self.id = user_id
        self.name = name
        self.email = email
    
    def change_email(self, new_email: Email) -> None:
        """Domain logic for changing email."""
        if new_email.address == self.email.address:
            raise ValueError("New email must be different")
        self.email = new_email

# Repository (interface)
class UserRepository:
    """Repository for User access."""
    def find_by_id(self, user_id: int) -> Optional[User]:
        raise NotImplementedError
        
    def save(self, user: User) -> None:
        raise NotImplementedError

# Application Service
class UserService:
    """Application service for user operations."""
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository
    
    def change_user_email(self, user_id: int, new_email_str: str) -> None:
        """Use case: Change a user's email address."""
        user = self.user_repository.find_by_id(user_id)
        if not user:
            raise ValueError(f"User {user_id} not found")
            
        # Create value object
        new_email = Email(new_email_str)
        
        # Use domain logic
        user.change_email(new_email)
        
        # Persist changes
        self.user_repository.save(user)
```

In the sections that follow, we'll explore each DDD concept in depth, with practical examples of how to apply them in Python and TypeScript backends. 