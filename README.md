# Software Architecture Guide Documentation

This repository contains a comprehensive guide to software architecture principles, patterns, and best practices. The documentation is built using MkDocs with the Material theme.

## Focus Areas

The guide focuses on:

1. Domain-Driven Design (DDD)
2. Microservices Architecture
3. SOLID Principles
4. Design Patterns
5. Implementation Examples in Python and TypeScript

## Multilingual Support

This documentation is available in multiple languages:

- English (en)
- Spanish (es)

The language selector will appear in the navigation menu. You can contribute to translations by adding content to the respective language folders in the `docs` directory.

## Getting Started

### Prerequisites

- Python 3.8+
- Docker and Docker Compose (optional)
- Make (optional, for using the Makefile)

### Using the Makefile

The project includes a Makefile for convenience:

```bash
# Show all available commands
make help

# Local development
make setup    # Install dependencies
make run      # Run local development server

# Docker operations
make start-docker    # Build and start in Docker
make docker-logs     # View logs
make docker-down     # Stop the Docker container
```

### Local Development

1. Clone this repository:
   ```
   git clone <repository-url>
   cd software-architecture-guide
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
   Or use: `make setup`

3. Start the development server:
   ```
   mkdocs serve
   ```
   Or use: `make run`

4. View the documentation at `http://localhost:8000`

### Using Docker Compose

1. Start the service:
   ```
   docker-compose up -d
   ```
   Or use: `make docker-up`

2. View the documentation at `http://localhost:8000`

3. Stop the service:
   ```
   docker-compose down
   ```
   Or use: `make docker-down`

### Using Docker (Legacy Method)

1. Build the Docker image:
   ```
   docker build -t software-architecture-guide .
   ```

2. Run the container:
   ```
   docker run -p 8000:8000 software-architecture-guide
   ```

3. View the documentation at `http://localhost:8000`

## Building the Documentation

To build static HTML files:

```
mkdocs build
```
Or use: `make build`

The built site will be in the `site` directory.

## Contributing

We welcome contributions to this guide. To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Project Structure

```
software-architecture-guide/
├── docs/                    # Documentation content
│   ├── en/                  # English content
│   │   ├── index.md         # English home page
│   │   ├── solid/           # SOLID principles
│   │   ├── design-patterns/ # Design patterns
│   │   ├── architecture/    # Architectural styles
│   │   ├── ddd/             # Domain-Driven Design
│   │   ├── examples/        # Implementation examples
│   │   ├── best-practices/  # Best practices
│   │   └── team-adoption/   # Team adoption strategies
│   └── es/                  # Spanish content
│       ├── index.md         # Spanish home page
│       ├── solid/           # SOLID principles (Spanish)
│       ├── design-patterns/ # Design patterns (Spanish)
│       ├── architecture/    # Architectural styles (Spanish)
│       ├── ddd/             # Domain-Driven Design (Spanish)
│       ├── examples/        # Implementation examples (Spanish)
│       ├── best-practices/  # Best practices (Spanish)
│       └── team-adoption/   # Team adoption strategies (Spanish)
├── mkdocs.yml               # MkDocs configuration
├── docker-compose.yml       # Docker Compose configuration
├── Makefile                 # Automation commands
├── requirements.txt         # Python dependencies
└── dockerfile               # Docker configuration
```

## License

[Your License] 