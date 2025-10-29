# 🗺️ Mapa de Navegación - RecetasDeliciosas

## Flujo de Usuario Completo

```
┌─────────────────────────────────────────────────────────────────────┐
│                         INICIO DE LA APP                             │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
                    ┌──────────────────────────┐
                    │   🔐 LOGIN SCREEN        │
                    │                          │
                    │  • Email                 │
                    │  • Contraseña            │
                    │  • Botón "Iniciar Sesión"│
                    │  • Link "Crear cuenta"   │
                    └──────────────────────────┘
                          │              │
           ┌──────────────┘              └──────────────┐
           │                                            │
           ▼                                            ▼
┌──────────────────────┐                    ┌──────────────────────────┐
│ 📝 SIGNUP SCREEN     │                    │  🏠 HOME SCREEN          │
│                      │                    │                          │
│  • Nombre            │                    │  • Header navegación     │
│  • Email             │◄───────────────────│  • Receta del día        │
│  • Contraseña        │  "Inicia sesión"   │  • Recetas populares     │
│  • Confirmar Pass    │                    │  • Footer                │
│  • Botón "Crear"     │                    │  • Avatar (→ Perfil)     │
└──────────────────────┘                    └──────────────────────────┘
           │                                            │
           │                                            │
           └────────────────────┬───────────────────────┘
                                │
                                ▼
                    ┌──────────────────────────┐
                    │  🏠 HOME SCREEN          │
                    │  (Usuario logueado)      │
                    └──────────────────────────┘
                           │       │       │
              ┌────────────┘       │       └────────────┐
              │                    │                    │
              ▼                    ▼                    ▼
┌──────────────────────┐  ┌──────────────────┐  ┌──────────────────────┐
│ 📖 RECIPE DETAIL     │  │ 👤 PROFILE       │  │  🔍 Búsqueda         │
│                      │  │                  │  │  (Futuro)            │
│  • Imagen grande     │  │  • Avatar grande │  └──────────────────────┘
│  • Título            │  │  • Nombre        │
│  • Tiempo/Porciones  │  │  • Descripción   │
│  • Ingredientes      │  │  • Botón "Crear" │
│  • Preparación       │  │  • Mis Recetas   │
│  • Imprimir/Guardar  │  │    (Grid 3 cols) │
└──────────────────────┘  └──────────────────┘
                                    │
                                    │ Click "Crear Nueva Receta"
                                    │
                                    ▼
                          ┌──────────────────────┐
                          │ ➕ CREATE RECIPE     │
                          │                      │
                          │  • Título receta     │
                          │  • Descripción       │
                          │  • Subir foto        │
                          │  • Ingredientes []   │
                          │  • Pasos []          │
                          │  • Botón "Publicar"  │
                          └──────────────────────┘
                                    │
                                    │ Publicar exitoso
                                    │
                                    ▼
                          ┌──────────────────────┐
                          │  👤 PROFILE          │
                          │  (Actualizado)       │
                          └──────────────────────┘
```

## 📱 Pantallas Implementadas (6 Total)

### 1. 🔐 Login Screen

**Ruta:** `lib/screens/login_screen.dart`

**Elementos:**

- Logo "RecipeBrand" (negro)
- Título: "Bienvenido de nuevo"
- Campo: Email
- Campo: Contraseña
- Botón azul: "Iniciar Sesión"
- Link: "Crear una cuenta"

**Navegación:**

- → Signup Screen (click en "Crear cuenta")
- → Home Screen (login exitoso)

---

### 2. 📝 Signup Screen

**Ruta:** `lib/screens/signup_screen.dart`

**Elementos:**

- Logo "RecetasDeliciosas" (azul)
- Tarjeta blanca con fondo gris
- Título: "Crea tu Cuenta"
- Subtítulo: "Únete a nuestra comunidad..."
- Campo: Nombre
- Campo: Email
- Campo: Contraseña
- Campo: Confirmar Contraseña
- Botón azul: "Crear Cuenta"
- Link: "¿Ya tienes cuenta? Inicia sesión"

**Navegación:**

- → Login Screen (click en "Inicia sesión")
- → Home Screen (registro exitoso)

---

### 3. 🏠 Home Screen

**Ruta:** `lib/screens/home_screen.dart`

**Elementos:**

- **Header:**
  - Logo "RecipeBrand"
  - Barra de búsqueda
  - Menú: Inicio, Recetas, Blog, Contacto
  - Avatar usuario
- **Receta Destacada:**
  - Imagen grande (350px altura)
  - "RECETA DEL DÍA"
  - Título: "Pasta Fresca al Pesto con Tomates Cherry"
  - Descripción
  - Botón: "Preparar Ahora"
- **Recetas Populares:**
  - Título: "Recetas Populares"
  - Grid 3 columnas
  - 3 tarjetas con imagen, título, descripción
- **Footer:**
  - Links: Sobre Nosotros, Política, Términos
  - Iconos sociales
  - Copyright

**Navegación:**

- → Recipe Detail (click en tarjeta)
- → Profile (click en avatar)

---

### 4. 📖 Recipe Detail Screen

**Ruta:** `lib/screens/recipe_detail_screen.dart`

**Elementos:**

- **Header:** Logo naranja "RecetasDeliciosas"
- **Hero Image:** 400px altura, redondeada
- **Título:** "Lasaña Clásica a la Boloñesa" (42px)
- **Botones:** Imprimir (outlined), Guardar (filled naranja)
- **Info Cards:**
  - ⏰ 90 min - Tiempo Total
  - 👥 8 personas - Porciones
  - 📊 Intermedia - Dificultad
- **Contenido (2 columnas):**
  - Izquierda: Ingredientes con bullets naranjas
  - Derecha: Preparación con pasos numerados (círculos naranjas)

**Navegación:**

- ← Back (navegación nativa del navegador)

---

### 5. 👤 Profile Screen

**Ruta:** `lib/screens/profile_screen.dart`

**Elementos:**

- **Header:** Completo con navegación
- **Banner:**
  - Avatar grande circular (120px)
  - Nombre: "Ana García" (32px bold)
  - Descripción: "Amante de la cocina casera"
- **Botón:** "Crear Nueva Receta" (azul, con icono +)
- **Mis Recetas:**
  - Título: "Mis Recetas"
  - Grid 3x2 (6 recetas total)
  - Tarjetas: Imagen, título, tiempo

**Navegación:**

- → Create Recipe (click en botón "Crear")
- → Recipe Detail (click en tarjeta)

---

### 6. ➕ Create Recipe Screen

**Ruta:** `lib/screens/create_recipe_screen.dart`

**Elementos:**

- **Header:** Con botón "Crear Receta" destacado
- **Título:** "Comparte tu receta" (36px)
- **Formulario:**
  - Campo: Título de la receta
  - Campo: Descripción (multilinea)
  - Área: Subir Foto (drag & drop)
  - Lista: Ingredientes (dinámica, add/remove)
  - Lista: Pasos (dinámica, numerada, add/remove)
  - Botón: "Publicar Receta" (azul, full width)

**Navegación:**

- → Profile (publicar exitoso)
- ← Back (cancelar)

---

## 🎨 Guía de Diseño

### Colores

- **Primario:** `#007AFF` (Azul iOS)
- **Secundario:** `#FF9500` (Naranja - Recipe Detail)
- **Fondo:** `#FFFFFF` (Blanco)
- **Fondo alternativo:** `#F5F5F5` (Gris claro)
- **Texto principal:** `#000000`
- **Texto secundario:** `#6B7280`
- **Bordes:** `#D1D5DB`

### Tipografía

- **Títulos grandes:** 32-42px, Weight: 700
- **Títulos medianos:** 28px, Weight: 700
- **Subtítulos:** 18px, Weight: 600
- **Cuerpo:** 15px, Weight: 400
- **Labels:** 14px, Weight: 600
- **Pequeño:** 12-13px, Weight: 400

### Espaciado

- **Padding horizontal:** 80px (desktop), 32px (móvil)
- **Gaps entre secciones:** 60px
- **Gaps entre elementos:** 24-32px
- **Card padding:** 20-40px

### Bordes

- **Botones:** 8-12px
- **Cards:** 12px
- **Inputs:** 8px
- **Modal:** 24px

### Sombras

```dart
BoxShadow(
  color: Colors.black.withOpacity(0.05-0.1),
  blurRadius: 10-20,
  offset: Offset(0, 4-10),
)
```

---

## 🔄 Estados y Validaciones

### Login/Signup

- ✅ Validación de email
- ✅ Validación de contraseña
- ✅ Confirmación de contraseña
- ✅ Mensajes de error
- ✅ Estados de carga

### Create Recipe

- ✅ Validación de campos requeridos
- ✅ Lista dinámica de ingredientes
- ✅ Lista dinámica de pasos
- ✅ Confirmación de publicación
- ✅ SnackBar de éxito (verde)

---

## 📊 Estadísticas del Proyecto

- **Total de pantallas:** 6
- **Total de archivos Dart:** 7 (6 screens + main.dart)
- **Líneas de código:** ~2,500+
- **Componentes reutilizables:** Headers, Cards, Forms
- **Imágenes:** Desde Unsplash (placeholders)

---

## 🚀 Próximas Funcionalidades Sugeridas

1. **Búsqueda de recetas** (funcional)
2. **Filtros y categorías**
3. **Sistema de favoritos** (guardar recetas)
4. **Calificaciones y reseñas**
5. **Compartir en redes sociales**
6. **Modo oscuro**
7. **Responsive mobile optimizado**
8. **Internacionalización (i18n)**
9. **Backend integration (API REST)**
10. **Autenticación real (Firebase/Auth0)**

---

## 💡 Notas Técnicas

- **Framework:** Flutter 3.9.2
- **Platform:** Web (Edge, Chrome compatible)
- **Arquitectura:** StatefulWidget + Controllers
- **Gestión de estado:** setState (local)
- **Navegación:** Navigator.push/pop
- **Imágenes:** NetworkImage (Unsplash)
- **Formularios:** TextFormField + GlobalKey
- **Responsive:** Constraints y MediaQuery ready

---

## 📖 Cómo Usar

```bash
# Clonar el repositorio
git clone <repo-url>

# Instalar dependencias
cd recetas_front
flutter pub get

# Ejecutar en web
flutter run -d edge

# Ejecutar en Windows
flutter run -d windows

# Build para producción
flutter build web
```

---

**Última actualización:** 29 de Octubre, 2025
**Versión:** 1.0.0
**Desarrollado con:** Flutter & ❤️
