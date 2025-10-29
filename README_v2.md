# 🍳 RecipeBrand - Aplicación de Recetas

Aplicación web de recetas desarrollada con Flutter, siguiendo **Clean Architecture** y con un diseño elegante y minimalista estilo Apple.

## 🏗️ Arquitectura

Este proyecto utiliza **Clean Architecture** para mantener el código organizado, escalable y fácil de mantener.

### Estructura del Proyecto

```
lib/
├── main.dart                           # Punto de entrada
├── core/                               # Núcleo de la aplicación
│   ├── constants/
│   │   └── app_colors.dart            # Constantes de colores
│   └── theme/
│       └── app_theme.dart             # Tema de la aplicación
└── presentation/                       # Capa de presentación
    ├── screens/                        # Pantallas principales
    │   ├── login_screen.dart          # Login
    │   ├── signup_screen.dart         # Registro
    │   ├── home_screen.dart           # Home con Recipe Detail
    │   └── profile_screen.dart        # Perfil con Create Recipe
    └── widgets/                        # Widgets reutilizables
        ├── custom_button.dart         # Botón personalizado
        ├── recipe_card.dart           # Tarjeta de receta
        ├── recipe_detail_widget.dart  # Widget de detalle de receta
        └── create_recipe_widget.dart  # Widget de crear receta
```

## 📱 Características

### Pantallas Implementadas

1. **Login** - Pantalla de inicio de sesión

   - Diseño limpio y minimalista
   - Validación de campos
   - Loading state
   - Navegación a Signup y Home

2. **Signup** - Pantalla de crear cuenta ✨ MEJORADA

   - Tarjeta blanca centrada con fondo gris claro
   - Validación completa de formularios
   - Confirmación de contraseña
   - Link de regreso a Login
   - Diseño según mockup proporcionado

3. **Home** - Pantalla principal (con Recipe Detail integrado)

   - Header con logo, búsqueda y navegación
   - Receta destacada del día
   - Grid de recetas populares
   - **Toggle para mostrar Recipe Detail Widget**
   - Footer con links y redes sociales

4. **Profile** - Perfil de usuario (con Create Recipe integrado)
   - Banner con avatar y nombre
   - Botón "Crear Nueva Receta"
   - Grid 3x2 de "Mis Recetas"
   - **Toggle para mostrar Create Recipe Widget**

### Widgets Reutilizables

5. **Recipe Detail Widget** ⭐ NUEVO

   - Se muestra dentro del Home Screen
   - Imagen hero grande
   - Info cards: Tiempo/Porciones/Dificultad
   - Columnas: Ingredientes | Preparación
   - Pasos numerados con círculos naranjas
   - Botón "Volver" para regresar

6. **Create Recipe Widget** ⭐ NUEVO

   - Se muestra dentro del Profile Screen
   - Formulario completo centrado
   - Drag & drop para fotos
   - Listas dinámicas de ingredientes
   - Listas dinámicas de pasos numerados
   - Validación y confirmación
   - Botón "Volver" para regresar

7. **Custom Button** - Botón reutilizable

   - Variantes: filled, outlined
   - Con/sin icono
   - Loading state
   - Colores personalizables

8. **Recipe Card** - Tarjeta de receta
   - Imagen, título y descripción
   - Sombra elegante
   - OnTap handler

## 🎨 Diseño

### Paleta de Colores (App Colors)

```dart
Primary: #007AFF (Azul iOS)
Secondary: #FF9500 (Naranja)
Background: #FFFFFF (Blanco)
Background Secondary: #F5F5F5 (Gris claro)
Text Primary: #000000
Text Secondary: #6B7280
Borders: #D1D5DB
```

### Tema Unificado (App Theme)

- Material Design 3
- Input Decoration consistente
- Button themes globales
- Tipografía estandarizada
- Colores y estilos reutilizables

## 🚀 Cómo ejecutar

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en navegador Edge
flutter run -d edge

# O en Windows desktop
flutter run -d windows
```

## 🔄 Flujo de Navegación

```
Login → Home (con Recipe Detail widget como overlay)
  ↓       ↓
Signup   Profile (con Create Recipe widget como overlay)
```

### Características de Navegación:

- **Home Screen:** Botón "Preparar Ahora" muestra RecipeDetailWidget
- **Home Screen:** Click en tarjetas muestra RecipeDetailWidget
- **Profile Screen:** Botón "Crear Nueva Receta" muestra CreateRecipeWidget
- **Botón "Volver":** Regresa a la vista principal en cada pantalla
- **Sin navegación de rutas:** Los widgets se muestran/ocultan con setState

## 🛠️ Tecnologías

- **Flutter** 3.9.2
- **Dart** 3.9.2
- Material Design 3
- Clean Architecture
- Stateful Widgets
- Custom Themes

## 📝 Principios de Clean Architecture

### Core Layer

- Contiene constantes y configuraciones compartidas
- No depende de otras capas
- Define el tema y colores de la aplicación

### Presentation Layer

- **Screens:** Pantallas completas de la aplicación
- **Widgets:** Componentes reutilizables
- Manejo de estado local con setState
- Navegación entre pantallas

### Ventajas de esta arquitectura:

✅ **Separación de responsabilidades**  
✅ **Código reutilizable**  
✅ **Fácil de testear**  
✅ **Escalable**  
✅ **Mantenible**

## 🎯 Decisiones de Diseño

### ¿Por qué widgets en lugar de pantallas separadas?

**Recipe Detail Widget en Home:**

- ✅ Transición instantánea sin navegación
- ✅ Mantiene el contexto del usuario
- ✅ Experiencia más fluida (no push/pop)
- ✅ Ahorro de memoria (no crea nueva ruta)
- ✅ Mejor UX para consulta rápida

**Create Recipe Widget en Profile:**

- ✅ Formulario contextual al perfil
- ✅ No interrumpe el flujo de trabajo
- ✅ Fácil retorno a "Mis Recetas"
- ✅ Modal-like experience
- ✅ Mantiene estado del perfil

## 📊 Mejoras Implementadas

### v2.0.0 - Clean Architecture

- ✅ Separación en capas (core, presentation)
- ✅ Widgets reutilizables (CustomButton, RecipeCard)
- ✅ Tema centralizado (AppTheme)
- ✅ Constantes de colores (AppColors)
- ✅ Recipe Detail como widget en Home
- ✅ Create Recipe como widget en Profile
- ✅ Validación mejorada en formularios
- ✅ Loading states en botones
- ✅ Signup screen según mockup

## 💡 Próximas Mejoras

### Arquitectura

- [ ] Implementar BLoC/Provider para estado global
- [ ] Agregar capa de Data (repositorios)
- [ ] Agregar capa de Domain (use cases)
- [ ] Implementar dependency injection

### Funcionalidades

- [ ] Backend integration (API REST)
- [ ] Autenticación real (Firebase/Auth0)
- [ ] Base de datos local (Hive/SQLite)
- [ ] Upload de imágenes real
- [ ] Sistema de favoritos funcional
- [ ] Búsqueda en tiempo real

---

**Última actualización:** 29 de Octubre, 2025  
**Versión:** 2.0.0 (Clean Architecture)  
**Desarrollado con:** Flutter & ❤️
