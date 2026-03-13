# CONTRIBUTING.md

## 📋 Guía de Contribución

Gracias por tu interés en contribuir al proyecto SI2 Mobile. Por favor, sigue las siguientes pautas para mantener la calidad del código.

### 🔧 Configuración del Ambiente

1. Clona el repositorio
2. Instala las dependencias: `flutter pub get`
3. Verifica que todo funcione: `flutter doctor`

### 📝 Convenciones de Código

- **Archivos**: `snake_case.dart`
- **Clases**: `PascalCase`
- **Variables/Métodos**: `camelCase`
- **Constantes**: `camelCase`

### ✅ Antes de Hacer Commit

```bash
# Formato de código
flutter format lib/

# Análisis de código
flutter analyze

# Pruebas (si existen)
flutter test
```

### 🌿 Flujo de Ramas

- `main` - Producción (release)
- `develop` - Desarrollo
- `feature/nombre-feature` - Nuevas características
- `fix/nombre-fix` - Correcciones de bugs

### 📋 Pasos para Contribuir

1. Crea una rama: `git checkout -b feature/mi-feature`
2. Haz tus cambios
3. Asegúrate de pasar `flutter analyze`
4. Formatea el código: `flutter format`
5. Haz commit: `git commit -m "feat: descripción clara"`
6. Push: `git push origin feature/mi-feature`
7. Abre un Pull Request

### 💬 Mensajes de Commit

Usa el estándar [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` Nueva característica
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `style:` Formato de código
- `refactor:` Refactorización sin cambios funcionales
- `test:` Agregar/modificar tests
- `chore:` Tareas de mantenimiento

Ejemplo:
```
feat: agregar pantalla de login
fix: corregir error de validación en email
docs: actualizar README con instrucciones
```

### 🐛 Reportar Bugs

Describe claramente:
- Qué esperabas que pasara
- Qué pasó realmente
- Pasos para reproducir
- Versión de Flutter y dispositivo

---

¡Gracias por contribuir! 🙌
