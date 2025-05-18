# Arquitectura en Capas

La arquitectura en capas es uno de los patrones arquitectónicos más tradicionales y ampliamente utilizados en el desarrollo de software. Este enfoque organiza el sistema en capas horizontales, donde cada capa proporciona servicios a la capa superior y utiliza los servicios de la capa inferior.

## Principios Fundamentales

La arquitectura en capas se basa en los siguientes principios:

1. **Separación de responsabilidades**: Cada capa tiene una responsabilidad específica y claramente definida.
2. **Abstracción**: Cada capa oculta sus detalles internos y expone solo interfaces bien definidas.
3. **Aislamiento**: Los cambios en una capa no deberían afectar a las capas no adyacentes.
4. **Dependencia unidireccional**: Las capas superiores dependen de las inferiores, pero no al revés.

## Capas Típicas

Una aplicación típica basada en capas suele incluir las siguientes capas (de arriba hacia abajo):

### 1. Capa de Presentación (UI)

**Responsabilidad**: Interactúa con el usuario, muestra información y captura entradas.

**Componentes comunes**:
- Interfaces de usuario (web, móvil, escritorio)
- API controllers
- Vistas y plantillas
- Validación de entrada básica

```python
# Ejemplo de controlador en Flask (Capa de Presentación)
@app.route('/usuarios/<int:usuario_id>', methods=['GET'])
def obtener_usuario(usuario_id):
    try:
        # Llama a la capa de aplicación
        usuario = servicio_usuarios.obtener_por_id(usuario_id)
        if not usuario:
            return jsonify({"error": "Usuario no encontrado"}), 404
        return jsonify(usuario.to_dict())
    except Exception as e:
        return jsonify({"error": str(e)}), 500
```

### 2. Capa de Aplicación

**Responsabilidad**: Orquesta el flujo de la aplicación, coordina la lógica de negocio y controla las transacciones.

**Componentes comunes**:
- Servicios de aplicación
- Orquestadores
- Casos de uso
- DTOs (Data Transfer Objects)

```python
# Ejemplo de servicio de aplicación (Capa de Aplicación)
class ServicioUsuarios:
    def __init__(self, repositorio_usuarios):
        self.repositorio_usuarios = repositorio_usuarios
    
    def obtener_por_id(self, usuario_id):
        # Llama a la capa de dominio/repositorio
        usuario = self.repositorio_usuarios.obtener_por_id(usuario_id)
        if not usuario:
            return None
        return usuario
    
    def crear_usuario(self, datos_usuario):
        # Validaciones de aplicación
        if self.repositorio_usuarios.existe_email(datos_usuario.email):
            raise EmailDuplicadoError("El email ya está en uso")
        
        # Crea la entidad de dominio
        nuevo_usuario = Usuario(
            nombre=datos_usuario.nombre,
            email=datos_usuario.email,
            password=self.hash_password(datos_usuario.password)
        )
        
        # Persiste a través del repositorio
        return self.repositorio_usuarios.guardar(nuevo_usuario)
```

### 3. Capa de Dominio

**Responsabilidad**: Contiene la lógica de negocio, entidades y reglas del dominio de la aplicación.

**Componentes comunes**:
- Entidades
- Objetos de valor
- Servicios de dominio
- Lógica y reglas de negocio

```python
# Ejemplo de entidad de dominio (Capa de Dominio)
class Usuario:
    def __init__(self, nombre, email, password):
        self.id = None  # Asignado durante la persistencia
        self.nombre = nombre
        self.email = email
        self.password_hash = password
        self.fecha_registro = datetime.now()
        self.activo = True
    
    def cambiar_password(self, password_actual, nueva_password, verificador_password):
        if not verificador_password.verificar(self.password_hash, password_actual):
            raise PasswordIncorrectoError("La contraseña actual es incorrecta")
        
        self.password_hash = verificador_password.hashear(nueva_password)
    
    def desactivar(self):
        self.activo = False
```

### 4. Capa de Infraestructura

**Responsabilidad**: Proporciona capacidades técnicas que soportan las capas superiores, como persistencia, comunicación, etc.

**Componentes comunes**:
- Repositorios y DAOs (Data Access Objects)
- Implementaciones de interfaces de dominio
- Clientes de servicios externos
- ORM y acceso a datos
- Frameworks y librerías

```python
# Ejemplo de repositorio (Capa de Infraestructura)
class RepositorioUsuariosSQLAlchemy(RepositorioUsuarios):
    def __init__(self, session):
        self.session = session
    
    def obtener_por_id(self, usuario_id):
        return self.session.query(UsuarioModel).filter_by(id=usuario_id).first()
    
    def guardar(self, usuario):
        if usuario.id:
            # Actualizar usuario existente
            usuario_model = self.session.query(UsuarioModel).get(usuario.id)
            usuario_model.nombre = usuario.nombre
            usuario_model.email = usuario.email
            usuario_model.password_hash = usuario.password_hash
            usuario_model.activo = usuario.activo
        else:
            # Crear nuevo usuario
            usuario_model = UsuarioModel(
                nombre=usuario.nombre,
                email=usuario.email,
                password_hash=usuario.password_hash,
                fecha_registro=usuario.fecha_registro,
                activo=usuario.activo
            )
            self.session.add(usuario_model)
        
        self.session.commit()
        return usuario_model.to_entity()
```

## Beneficios de la Arquitectura en Capas

- **Separación de preocupaciones**: Cada capa tiene un enfoque claro, facilitando el mantenimiento.
- **Facilidad de prueba**: Las capas pueden probarse de forma aislada con mocks o stubs.
- **Flexibilidad y escalabilidad**: Las capas pueden escalar independientemente según sea necesario.
- **Desarrollo en paralelo**: Diferentes equipos pueden trabajar simultáneamente en diferentes capas.
- **Reusabilidad**: Los componentes de las capas inferiores pueden reutilizarse en diferentes partes del sistema.

## Desafíos y Consideraciones

- **Complejidad**: Agregar capas introduce complejidad y sobrecarga.
- **Rendimiento**: Atravesar múltiples capas puede afectar el rendimiento.
- **Tentación de acceso directo**: Los desarrolladores pueden verse tentados a saltarse capas.
- **Acoplamiento vertical**: Si no se diseñan correctamente las interfaces, las capas pueden acoplarse estrechamente.

## Relación con Otros Patrones

La arquitectura en capas se complementa bien con:

- **Patrón Repositorio**: Para abstraer el acceso a datos en la capa de infraestructura.
- **Inyección de Dependencias**: Para gestionar las dependencias entre capas.
- **Patrón Fachada**: Para simplificar interfaces complejas entre capas.
- **Diseño Dirigido por el Dominio (DDD)**: La arquitectura en capas proporciona la estructura para implementar DDD.

## Cuándo Usar Arquitectura en Capas

La arquitectura en capas es especialmente adecuada para:

- Aplicaciones empresariales con lógica de negocio compleja
- Sistemas que requieren una clara separación de responsabilidades
- Aplicaciones que necesitan adaptarse a diferentes interfaces de usuario o fuentes de datos
- Equipos grandes donde diferentes subequipos trabajan en diferentes aspectos del sistema

## Variaciones

### Arquitectura de 3 Capas vs. 4 Capas

- **3 Capas**: Presentación, Lógica de Negocio, Datos
- **4 Capas**: Presentación, Aplicación, Dominio, Infraestructura (enfoque más alineado con DDD)

### Capas Estrictas vs. Relajadas

- **Estricta**: Una capa solo puede comunicarse con la capa inmediatamente inferior
- **Relajada**: Una capa puede comunicarse con cualquier capa inferior

## Conclusión

La arquitectura en capas es un patrón fundamental en el diseño de software que proporciona estructura, separación de preocupaciones y flexibilidad. Aunque puede no ser tan modular como los microservicios, sigue siendo una excelente opción para muchos tipos de aplicaciones, especialmente aquellas con lógica de negocio compleja que se beneficia de una clara separación de responsabilidades. 