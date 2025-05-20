# Lenguaje Ubicuo (Ubiquitous Language)

## Definición
Un lenguaje común compartido entre desarrolladores y expertos del dominio que refleja con precisión los conceptos del negocio y se usa consistentemente en toda comunicación y código.

## Importancia
- **Desarrolladores**: Reduce la traducción constante entre términos técnicos y de negocio
- **Expertos del dominio**: Facilita validar que el software atiende sus necesidades
- **Proyecto**: Reduce malentendidos y mejora la transferencia de conocimiento

## Desarrollo del Lenguaje Ubicuo

### 1. Identificar Términos del Dominio
- **Sustantivos**: Entidades, objetos de valor, agregados
- **Verbos**: Operaciones, comandos, eventos
- **Reglas**: Políticas y lógica de negocio

### 2. Documentar y Refinar
- Crear glosarios con definiciones claras
- Desarrollar mapas conceptuales
- Escribir casos de uso con el lenguaje acordado

### 3. Implementar en Código

#### Sin Lenguaje Ubicuo
```python
# Sistema de reservas de hotel sin Lenguaje Ubicuo
class Reservation:
    def __init__(self, user_id, room_id, start_date, end_date):
        self.user_id = user_id
        self.room_id = room_id
        self.start_date = start_date
        self.end_date = end_date
        self.status = "pending"
    
    def update_status(self, new_status):
        self.status = new_status
    
    def is_valid(self):
        # Validación técnica genérica
        return (self.end_date > self.start_date and
                self.check_availability())
    
    def check_availability(self):
        # Consulta técnica a la base de datos
        return database.execute_query(
            f"SELECT COUNT(*) FROM bookings WHERE room_id = {self.room_id} " +
            f"AND status = 'confirmed' " +
            f"AND ((start_date <= '{self.start_date}' AND end_date >= '{self.start_date}') " +
            f"OR (start_date <= '{self.end_date}' AND end_date >= '{self.end_date}'))"
        ) == 0
```

#### Con Lenguaje Ubicuo
```python
# Sistema de reservas de hotel con Lenguaje Ubicuo
class ReservaHotelera:
    def __init__(self, huesped_id, habitacion_id, fecha_llegada, fecha_salida):
        self.huesped_id = huesped_id
        self.habitacion_id = habitacion_id
        self.fecha_llegada = fecha_llegada
        self.fecha_salida = fecha_salida
        self.estado = EstadoReserva.PENDIENTE
    
    def confirmar(self):
        if not self.es_confirmable():
            raise ReservaNoConfirmableError("La reserva no cumple los requisitos para ser confirmada")
        
        self.estado = EstadoReserva.CONFIRMADA
        self.fecha_confirmacion = datetime.now()
        
        # Publicar evento de dominio
        publicar_evento(ReservaConfirmadaEvento(self.id))
    
    def es_confirmable(self):
        return (self.fecha_salida > self.fecha_llegada and
                self.habitacion_esta_disponible_para_fechas())
    
    def habitacion_esta_disponible_para_fechas(self):
        # Método que expresa claramente la intención del negocio
        return RepositorioReservas.verificar_disponibilidad(
            self.habitacion_id, 
            self.fecha_llegada, 
            self.fecha_salida
        )
```

### 4. Usar en Comunicación Diaria
- Reuniones, documentación, historias de usuario
- Mensajes de commit, nombres de ramas
- Logs y mensajes de error

## Técnicas de Colaboración

### Event Storming
Sesión donde técnicos y expertos mapean procesos usando notas adhesivas para representar:
- Eventos del dominio (naranja)
- Comandos (azul)
- Agregados y entidades (amarillo)
- Políticas y reglas (lila)

### Example Mapping
Exploración de ejemplos concretos para clarificar conceptos y reglas.

### Glosario Activo
Documento vivo mantenido conjuntamente por técnicos y expertos.

## Errores Comunes
- Mezclar lenguajes técnicos y de dominio
- Inconsistencia en el uso de términos
- Terminología vaga o ambigua

## Mantenimiento
- Revisiones periódicas del glosario
- Refactorización del código para mantenerlo alineado
- Corrección de desviaciones en el uso de términos
- Evolución del modelo con nuevos conocimientos 