# 🍳 RecipeBrand - Aplicación de Recetas

Aplicación web de recetas desarrollada con Flutter, con un diseño elegante y minimalista estilo Apple.

## 📱 Características

### Pantallas Implementadas

1. **Login** - Pantalla de inicio de sesión

   - Diseño limpio y minimalista
   - Campos para Email y Contraseña
   - Botón azul "Iniciar Sesión"
   - Link para crear cuenta

2. **Registro** - Pantalla de crear cuenta

   - Formulario con campos: Nombre, Email, Contraseña y Confirmar Contraseña
   - Tarjeta blanca centrada con fondo gris claro
   - Validación de formularios

3. **Home** - Pantalla principal

   - Header con logo, búsqueda y menú de navegación
   - Receta destacada del día
   - Sección de recetas populares
   - Footer con links y redes sociales

4. **Detalle de Receta** - Vista completa de una receta

   - Imagen hero de la receta
   - Información: tiempo, porciones y dificultad
   - Lista de ingredientes
   - Pasos de preparación detallados
   - Botones para imprimir y guardar

5. **Perfil de Usuario** - Página de perfil personal

   - Banner con foto de perfil y nombre
   - Descripción del usuario
   - Botón "Crear Nueva Receta"
   - Grid de 3 columnas con "Mis Recetas"
   - Navegación a detalles de recetas

6. **Crear Receta** - Formulario de creación
   - Título "Comparte tu receta"
   - Campos: Título, Descripción
   - Área para subir foto (drag & drop)
   - Lista dinámica de Ingredientes (añadir/eliminar)
   - Lista dinámica de Pasos numerados (añadir/eliminar)
   - Botón "Publicar Receta"

## 🎨 Diseño

- **Paleta de colores:** Blancos, grises suaves y azul #007AFF
- **Tipografía:** Sans-serif con excelente legibilidad
- **Espaciado:** Generoso uso de espacio en blanco
- **Bordes:** Redondeados de 8-16px
- **Sombras:** Sutiles y elegantes

## 🚀 Cómo ejecutar

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en navegador Edge
flutter run -d edge

# O en Windows desktop
flutter run -d windows
```

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                       # Punto de entrada
├── core/                           # Clases centrales y utilitarios
│   └── image_optimizer.dart        # Optimización de imágenes
├── services/                       # Servicios de API y backend
│   └── api_service.dart            # Cliente API REST
└── presentation/                   # Interfaz de usuario
    ├── widgets/
    │   └── create_recipe_widget.dart
    └── screens/
        ├── login_screen.dart       # Pantalla de login
        ├── signup_screen.dart      # Pantalla de registro
        ├── home_screen.dart        # Pantalla principal
        ├── recipe_detail_screen.dart # Detalle de receta
        ├── profile_screen.dart     # Perfil de usuario
        └── create_recipe_screen.dart # Formulario crear receta
```

## 🛠️ Tecnologías

- **Flutter** 3.9.2
- **Dart** 3.9.2
- Material Design 3
- Responsive Web Design
- **HTTP Client** para integración con API REST
- **SharedPreferences** para persistencia local
- **Image Picker & Processing** para manejo de imágenes

## 📝 Testing

El proyecto incluye tests comprehensivos:

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage
```

Ver `TEST_REPORT.md` para detalles completos de los tests implementados.

---

# 📡 API Documentation

Esta documentación describe todas las rutas de la API que utiliza la aplicación frontend de recetas y cómo se realizan las llamadas, incluyendo los cuerpos de las peticiones y las respuestas.

## Base URL

```
http://localhost:3000/api
```

## Autenticación

La API utiliza autenticación JWT (JSON Web Token). El token se almacena localmente usando `SharedPreferences` y se envía en el header `Authorization` con el prefijo `Bearer`.

### Headers requeridos para rutas protegidas:

```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

---

## Endpoints de Autenticación

### 1. Registrar Usuario

**Endpoint:** `POST /auth/register`

**Descripción:** Registra un nuevo usuario en el sistema.

**Cuerpo de la petición:**

```json
{
  "name": "string",
  "email": "string",
  "password": "string"
}
```

**Ejemplo de uso en código:**

```dart
await apiService.registrarUsuario(
  nombre: "Juan Pérez",
  email: "juan@example.com",
  password: "miPassword123"
);
```

**Respuesta exitosa (201):**

```json
{
  "message": "Usuario registrado exitosamente",
  "user": {
    "id": "number",
    "name": "string",
    "email": "string"
  },
  "token": "jwt_token_string"
}
```

**Errores posibles:**

- `400`: Email ya registrado
- `400`: Datos de entrada inválidos

---

### 2. Iniciar Sesión

**Endpoint:** `POST /auth/login`

**Descripción:** Autentica un usuario existente y devuelve un token JWT.

**Cuerpo de la petición:**

```json
{
  "email": "string",
  "password": "string"
}
```

**Ejemplo de uso en código:**

```dart
await apiService.iniciarSesion(
  email: "juan@example.com",
  password: "miPassword123"
);
```

**Respuesta exitosa (200):**

```json
{
  "message": "Login exitoso",
  "user": {
    "id": "number",
    "name": "string",
    "email": "string"
  },
  "token": "jwt_token_string"
}
```

**Errores posibles:**

- `401`: Credenciales inválidas
- `400`: Datos de entrada inválidos

---

## Endpoints de Recetas

### 3. Obtener Todas las Recetas

**Endpoint:** `GET /recetas`

**Descripción:** Obtiene todas las recetas públicas disponibles.

**Headers requeridos:**

```http
Authorization: Bearer <jwt_token>
```

**Ejemplo de uso en código:**

```dart
List<dynamic> recetas = await ApiService().obtenerTodasLasRecetas();
```

**Respuesta exitosa (200):**

```json
// Formato directo (array)
[
  {
    "id": "number",
    "titulo": "string", // También puede ser "title" o "name"
    "descripcion": "string",
    "ingredientes": ["string"],
    "pasos": ["string"],
    "imagen_url": "string",
    "usuario_id": "number",
    "creado_en": "datetime"
  }
]

// O formato envuelto (objeto con propiedad data/recetas/rows)
{
  "data": [...], // o "recetas": [...] o "rows": [...]
}
```

**Nota:** La aplicación maneja automáticamente ambos formatos de respuesta mediante normalización.

---

### 4. Obtener Mis Recetas

**Endpoint:** `GET /recetas/mis-recetas`

**Descripción:** Obtiene todas las recetas creadas por el usuario autenticado.

**Headers requeridos:**

```http
Authorization: Bearer <jwt_token>
```

**Ejemplo de uso en código:**

```dart
List<dynamic> misRecetas = await ApiService().obtenerMisRecetas();
```

**Respuesta exitosa (200):** Mismo formato que "Obtener Todas las Recetas"

---

### 5. Obtener Receta por ID

**Endpoint:** `GET /recetas/:id`

**Descripción:** Obtiene los detalles de una receta específica por su ID.

**Headers requeridos:**

```http
Authorization: Bearer <jwt_token>
```

**Parámetros de ruta:**

- `id`: ID numérico de la receta

**Ejemplo de uso en código:**

```dart
Map<String, dynamic> receta = await ApiService().obtenerRecetaPorId(123);
```

**Respuesta exitosa (200):**

```json
// Formato directo
{
  "id": "number",
  "titulo": "string",
  "descripcion": "string",
  "ingredientes": ["string"],
  "pasos": ["string"],
  "imagen_url": "string",
  "usuario_id": "number",
  "creado_en": "datetime"
}

// O formato envuelto
{
  "data": {...}, // o "receta": {...}
}
```

**Errores posibles:**

- `404`: Receta no encontrada
- `403`: Sin permisos para acceder a la receta

---

### 6. Crear Receta

**Endpoint:** `POST /recetas`

**Descripción:** Crea una nueva receta para el usuario autenticado.

**Headers requeridos:**

```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Cuerpo de la petición:**

```json
{
  "titulo": "string",
  "descripcion": "string",
  "ingredientes": ["string"],
  "pasos": ["string"],
  "imagen_url": "string" // Opcional
}
```

**Ejemplo de uso en código:**

```dart
await ApiService().crearReceta(
  titulo: "Pasta Carbonara",
  descripcion: "Deliciosa pasta italiana",
  ingredientes: ["400g pasta", "200g panceta", "3 huevos", "Queso parmesano"],
  pasos: ["Hervir pasta", "Freír panceta", "Mezclar huevos y queso", "Combinar todo"],
  imagenUrl: "https://example.com/pasta.jpg"
);
```

**Respuesta exitosa (201):**

```json
{
  "message": "Receta creada exitosamente",
  "receta": {
    "id": "number",
    "titulo": "string",
    "descripcion": "string",
    "ingredientes": ["string"],
    "pasos": ["string"],
    "imagen_url": "string",
    "usuario_id": "number",
    "creado_en": "datetime"
  }
}
```

**Errores posibles:**

- `400`: Datos de entrada inválidos
- `401`: Token de autenticación inválido

---

### 7. Actualizar Receta

**Endpoint:** `PUT /recetas/:id`

**Descripción:** Actualiza una receta específica. Solo el propietario puede actualizar su receta.

**Headers requeridos:**

```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Parámetros de ruta:**

- `id`: ID numérico de la receta a actualizar

**Cuerpo de la petición:**

```json
{
  "titulo": "string",
  "descripcion": "string",
  "ingredientes": ["string"],
  "pasos": ["string"],
  "imagen_url": "string" // Opcional
}
```

**Ejemplo de uso en código:**

```dart
await ApiService().actualizarReceta(
  "123",
  {
    "titulo": "Pasta Carbonara Mejorada",
    "descripcion": "Versión mejorada de la pasta italiana",
    "ingredientes": ["500g pasta", "250g panceta", "4 huevos", "Queso parmesano extra"],
    "pasos": ["Hervir pasta al dente", "Freír panceta hasta dorar", "Mezclar huevos y queso", "Combinar todo con cuidado"],
    "imagen_url": "https://example.com/pasta-mejorada.jpg"
  }
);
```

**Respuesta exitosa (200):**

```json
{
  "message": "Receta actualizada exitosamente",
  "receta": {
    "id": "number",
    "titulo": "string",
    "descripcion": "string",
    "ingredientes": ["string"],
    "pasos": ["string"],
    "imagen_url": "string",
    "usuario_id": "number",
    "actualizado_en": "datetime"
  }
}
```

**Errores posibles:**

- `400`: Datos de entrada inválidos
- `401`: Token de autenticación inválido
- `403`: Sin permisos para actualizar la receta
- `404`: Receta no encontrada

---

### 8. Eliminar Receta

**Endpoint:** `DELETE /recetas/:id`

**Descripción:** Elimina una receta específica. Solo el propietario puede eliminar su receta.

**Headers requeridos:**

```http
Authorization: Bearer <jwt_token>
```

**Parámetros de ruta:**

- `id`: ID numérico de la receta a eliminar

**Ejemplo de uso en código:**

```dart
await ApiService().eliminarReceta(123);
```

**Respuesta exitosa (200):**

```json
{
  "message": "Receta eliminada exitosamente"
}
```

**Errores posibles:**

- `404`: Receta no encontrada
- `403`: Sin permisos para eliminar la receta
- `401`: Token de autenticación inválido

---

## Manejo de Errores

### Códigos de Estado HTTP

- `200`: Operación exitosa
- `201`: Recurso creado exitosamente
- `400`: Solicitud inválida (datos malformados)
- `401`: No autorizado (token inválido o ausente)
- `403`: Prohibido (sin permisos)
- `404`: Recurso no encontrado
- `500`: Error interno del servidor

### Estructura de Respuesta de Error

```json
{
  "error": "string",
  "message": "string",
  "statusCode": "number"
}
```

### Ejemplo de manejo en código:

```dart
try {
  await ApiService().crearReceta(...);
} catch (e) {
  print('Error: $e');
  // El ApiService ya maneja la mayoría de errores y los registra
}
```

---

## Normalización de Respuestas

La aplicación incluye lógica de normalización para manejar diferentes formatos de respuesta de la API:

### Campos de Título Soportados:

- `titulo` (español)
- `title` (inglés)
- `name` (alternativo)
- `nombre` (alternativo en español)

### Campos de ID Soportados:

- `id` (estándar)
- `_id` (MongoDB)
- `recetaId` (específico del contexto)

### Formatos de Respuesta Arrays:

- Array directo: `[{receta1}, {receta2}]`
- Envuelto en `data`: `{"data": [{receta1}, {receta2}]}`
- Envuelto en `recetas`: `{"recetas": [{receta1}, {receta2}]}`
- Envuelto en `rows`: `{"rows": [{receta1}, {receta2}]}`

Esta normalización permite que la aplicación funcione con diferentes versiones o configuraciones de la API backend sin requerir cambios en el frontend.

---

## Configuración de Desarrollo

Para desarrollo local, asegúrate de que:

1. El backend esté ejecutándose en `http://localhost:3000`
2. Los endpoints estén configurados correctamente según esta documentación
3. El sistema de autenticación JWT esté habilitado
4. CORS esté configurado para permitir peticiones desde el frontend Flutter web

## Autenticación Persistente

La aplicación utiliza `SharedPreferences` para persistir el token JWT:

```dart
// Guardar token
await prefs.setString('jwt_token', token);

// Recuperar token
String? token = prefs.getString('jwt_token');

// Eliminar token (logout)
await prefs.remove('jwt_token');
```

El token se incluye automáticamente en todas las peticiones a rutas protegidas mediante el método `_getHeaders()` del `ApiService`.

---

Desarrollado con ❤️ usando Flutter
