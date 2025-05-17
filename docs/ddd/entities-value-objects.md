# Entities and Value Objects

Entities and Value Objects are the basic building blocks of a domain model in Domain-Driven Design. Understanding the distinction between these two types of objects is fundamental to creating effective domain models.

## Entities

Entities are objects that have a unique identity that persists over time, regardless of changes to their attributes.

### Key Characteristics of Entities

- **Identity**: An entity has a unique identifier that distinguishes it from all other instances.
- **Mutable**: Entities can change their attributes over time while maintaining their identity.
- **Lifecycle**: Entities have a lifecycle - they're created, they may change, and they might be archived or deleted.
- **Equals by ID**: Two entities with the same identity are considered the same entity, even if they have different attribute values.

### Examples of Entities

- A `User` in a system (identified by user ID)
- An `Order` in an e-commerce system (identified by order number)
- A `BankAccount` (identified by account number)
- A `Product` in inventory (identified by SKU)

### Implementing Entities in Python

```python
class User:
    def __init__(self, user_id, name, email):
        self.id = user_id  # Identity field
        self.name = name
        self.email = email
        
    def change_name(self, new_name):
        self.name = new_name
        
    def change_email(self, new_email):
        self.email = new_email
        
    def __eq__(self, other):
        if not isinstance(other, User):
            return False
        return self.id == other.id  # Equality by ID, not attributes
        
    def __hash__(self):
        return hash(self.id)  # Hash based on identity
```

Note how:
- The `id` field holds the entity's identity
- Equality (`__eq__`) is based on identity, not attributes
- Methods allow for changing attributes while identity remains constant

## Value Objects

Value Objects are objects that have no conceptual identity - they are defined solely by their attributes.

### Key Characteristics of Value Objects

- **No Identity**: Value objects don't have an identifier field.
- **Immutable**: Once created, value objects should not change (any "change" creates a new instance).
- **Equality by Attributes**: Two value objects with the same attributes are considered equal.
- **Replaceable**: Value objects can be freely replaced with others having the same attributes.
- **Often Used to Measure, Quantify or Describe**: Value objects often represent concepts like money, dates, addresses.

### Examples of Value Objects

- An `EmailAddress` (defined by its string representation)
- A `Money` amount (defined by amount and currency)
- A `DateRange` (defined by start and end dates)
- A `Address` (defined by street, city, zip, etc.)

### Implementing Value Objects in Python

```python
from dataclasses import dataclass

@dataclass(frozen=True)  # frozen=True makes it immutable
class Money:
    amount: float
    currency: str
    
    def __post_init__(self):
        # Validation logic (in a real implementation, we'd use a
        # different approach since frozen=True prevents attribute changes)
        if self.amount < 0:
            object.__setattr__(self, "amount", 0)
            
    def add(self, other):
        if self.currency != other.currency:
            raise ValueError("Cannot add different currencies")
        # Create a new instance rather than modifying this one
        return Money(self.amount + other.amount, self.currency)
        
    def multiply(self, factor):
        # Again, creates a new instance
        return Money(self.amount * factor, self.currency)
```

Note how:
- We use `@dataclass(frozen=True)` to create an immutable object
- The `add` and `multiply` methods return new instances rather than modifying the existing one
- There's no identity field

## When to Use Entities vs. Value Objects

Use an **Entity** when:
- The object needs to be tracked over time
- The object has a distinct identity in the domain
- The same object can change over time while remaining "the same"
- You need to maintain history of the object

Use a **Value Object** when:
- The object is defined entirely by its attributes
- Equality is determined by comparing all attributes
- The concept is immutable in the domain
- Replacing it with another identical instance wouldn't matter
- It represents a descriptive aspect of the domain with no identity

## Practical Example: E-commerce Domain

Let's see how entities and value objects work together in an e-commerce scenario:

```python
from dataclasses import dataclass
from typing import List
from datetime import datetime
from uuid import UUID, uuid4

# Value Objects
@dataclass(frozen=True)
class Address:
    street: str
    city: str
    state: str
    postal_code: str
    country: str

@dataclass(frozen=True)
class Money:
    amount: float
    currency: str = "USD"

@dataclass(frozen=True)
class OrderItem:
    product_id: UUID
    quantity: int
    price_per_unit: Money
    
    def total_price(self) -> Money:
        return Money(self.price_per_unit.amount * self.quantity, 
                    self.price_per_unit.currency)

# Entity
class Order:
    def __init__(self, order_id: UUID, customer_id: UUID, 
                 shipping_address: Address):
        self.id = order_id
        self.customer_id = customer_id
        self.shipping_address = shipping_address
        self.items: List[OrderItem] = []
        self.created_at = datetime.now()
        self.status = "CREATED"
        
    def add_item(self, item: OrderItem) -> None:
        self.items.append(item)
        
    def total_price(self) -> Money:
        if not self.items:
            return Money(0)
            
        # Get the currency from the first item
        currency = self.items[0].price_per_unit.currency
        total = sum(item.total_price().amount for item in self.items)
        return Money(total, currency)
        
    def ship(self) -> None:
        if self.status != "CREATED":
            raise ValueError(f"Cannot ship order with status {self.status}")
        self.status = "SHIPPED"

# Usage
customer_id = uuid4()
order_id = uuid4()
shipping_address = Address("123 Main St", "Anytown", "CA", "12345", "USA")

# Create Order entity
order = Order(order_id, customer_id, shipping_address)

# Create and add OrderItem value objects
item1 = OrderItem(uuid4(), 2, Money(29.99))
item2 = OrderItem(uuid4(), 1, Money(49.99))

order.add_item(item1)
order.add_item(item2)

print(f"Order total: ${order.total_price().amount:.2f}")
```

This example shows:
- `Order` as an entity with identity and lifecycle
- `Address`, `Money`, and `OrderItem` as value objects (immutable, defined by their attributes)
- How entities and value objects work together in a domain model

## Domain Modeling Best Practices

When modeling with entities and value objects:

1. **Start with behavior, not data**: Focus on what the object does in the domain, not just what data it holds.

2. **Be explicit about identity**: For entities, clearly identify what makes them unique in the domain.

3. **Make value objects immutable**: This ensures they behave correctly and can be shared safely.

4. **Consider using factory methods**: For complex object creation logic, especially for value objects with validation.

5. **Encapsulate collections**: When an entity contains a collection, don't expose it directly; provide methods that control how items are added or removed.

6. **Use Value Objects for validation**: They can encapsulate and enforce domain rules about specific values.

By properly using entities and value objects, you create domain models that are both expressive and maintain their integrity as the application evolves. 