# SI2 Mobile 📱

Aplicación móvil Flutter para el Proyecto SI2 Grupal de Sistemas de Información II.

## 📋 Descripción

Proyecto móvil desarrollado con Flutter para Android e iOS. Este es el repositorio de la aplicación frontend móvil, complementando el backend y la aplicación web del proyecto SI2.

## 🛠️ Requisitos Previos

- **Flutter**: 3.35.4 o superior
- **Dart**: 3.9.2 o superior
- **Android Studio** o **Xcode** (para emuladores)
- **Git**: Para control de versiones

### Verificar instalación

```bash
flutter --version
flutter doctor
```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── app/
│   └── app.dart             # Configuración de la aplicación (MaterialApp)
├── core/
│   ├── constants/           # Constantes de la aplicación
│   ├── errors/              # Manejo de errores
│   └── network/             # Configuración de red/API
├── shared/
│   ├── widgets/             # Widgets reutilizables
│   ├── utils/               # Utilidades generales
│   └── theme/               # Temas y estilos
├── features/
│   ├── auth/                # Feature de autenticación
│   ├── home/                # Feature de inicio
│   └── [otros features]/    # Otros features según sea necesario
└── README.md

```

## 🚀 Empezar

### 1. Clonar el repositorio

```bash
cd [ruta-del-proyecto]
git clone [url-repositorio]
cd mobile
```

### 2. Obtener dependencias

```bash
flutter pub get
```

### 3. Ejecutar la aplicación

**En un emulador Android:**
```bash
flutter run
```

**En un dispositivo iOS:**
```bash
flutter run -d ios
```

**En web (desarrollo):**
```bash
flutter run -d chrome
```

## 🔧 Desarrollo

### Hot Reload

Durante el desarrollo, usa hot reload para ver cambios sin reiniciar:
```bash
r    # Hot reload
R    # Hot restart
q    # Quit
```

### Análisis de código

```bash
flutter analyze
```

### Formateo de código

```bash
flutter format lib/
```

## 📦 Dependencias

Las dependencias principales están en `pubspec.yaml`. Para agregar nuevas:

```bash
flutter pub add nombre_del_paquete
```

Para versión específica:
```bash
flutter pub add nombre_del_paquete:^1.0.0
```

## 🧪 Testing (Futuro)

```bash
flutter test
```

## 📱 Construcción

### Android Release

```bash
flutter build apk
flutter build appbundle
```

### iOS Release

```bash
flutter build ios
```

## 🚀 Deployment

Instrucciones de despliegue a App Store y Google Play (próximamente).

## 📝 Convenciones de Código

- **Nombres de archivos**: `snake_case` (ej: `home_page.dart`)
- **Nombres de clases**: `PascalCase` (ej: `HomePage`)
- **Nombres de variables**: `camelCase` (ej: `userName`)
- **Constantes**: `camelCase` (ej: `apiBaseUrl`)

## 🔐 Variables de Entorno

Usa `.env` para configuraciones sensibles (no se sube a Git):
```bash
cp .env.example .env
```

Edita `.env` con tus valores específicos.

## 📚 Recursos

- [Documentación oficial de Flutter](https://flutter.dev/docs)
- [Guía de estilo Dart](https://dart.dev/guides/language/effective-dart/style)
- [Recetas de Flutter](https://flutter.dev/docs/cookbook)

## 👥 Equipo

Proyecto SI2 Grupal - Sistemas de Información II

## 📄 Licencia

Proyecto académico - Universidad [Tu Universidad]

## 📞 Contacto

Para dudas o reportar issues, contáctate con el equipo de desarrollo.

---

**Última actualización**: 13 de marzo de 2026
