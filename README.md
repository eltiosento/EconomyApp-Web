# EconomyApp Client – Frontend (Flutter)

## 📌 Descripción
Este repositorio contiene el **cliente multiplataforma de EconomyApp**, desarrollado con **Flutter**.  
Permite gestionar y visualizar la economía familiar a través de una interfaz moderna, rápida e intuitiva.

Incluye funcionalidades como:

- Inicio de sesión y registro de usuarios  
- Consulta del balance global y mensual  
- Gestión de ingresos, gastos, categorías y subcategorías  
- Visualización de gráficos  
- Generación de informes PDF  
- Edición del perfil y fotografía del usuario  

---

## 🧱 Arquitectura del Proyecto

La estructura del cliente está organizada para maximizar la modularidad:

```
lib/
├── core/                 # Estilos, colores, temas globales
├── models/               # Modelos de datos (DTOs)
├── providers/            # Gestión de estado con Riverpod
├── routes/               # Rutas y navegación
├── screens/              # Pantallas de la aplicación
├── services/             # Servicios y llamadas a la API (Dio)
├── utils/                # Funciones auxiliares, interceptores, PDF, etc.
└── widgets/              # Widgets reutilizables
```

---

## 🛠 Tecnologías utilizadas

- **Flutter 3+**
- **Dart**
- **Riverpod** (gestión de estado)
- **Dio** (cliente HTTP)
- **SharedPreferences** (almacenamiento local del token)
- **Gráficos personalizados**
- **Soporte para Web y Android**

---

## 🔐 Autenticación y Roles

El cliente trabaja con autenticación JWT proporcionada por la API:

- **ADMIN:** acceso total (crear categorías, registrar movimientos, gestionar usuarios…)  
- **USER:** acceso de consulta y creación de movimientos personales  
- **GUEST:** solo registro; sin visibilidad hasta que un admin conceda permisos  

El token se almacena de forma segura y se inyecta automáticamente con un interceptor.

---

## 📡 Configuración de la API

La URL base está definida en el provider `lib/providers/dio_provider.dart`.  
Para cambiar entre entornos (local, producción o Tailscale), solo es necesario cambiar la constante `baseUrl`.

---

## 🖥 Ejecución en modo debug

### 1️⃣ Instalar dependencias
```
flutter pub get
```

### 2️⃣ Ejecutar en navegador
```
flutter run -d chrome
```

### 3️⃣ Ejecutar en Android
```
flutter run -d android
```

---

## 🌐 Build de producción (Web)

```
flutter build web
```

Los archivos generados pueden servirse mediante Nginx o integrarse en Docker.

---

## 📌 Funcionalidades principales

- Panel general con balances  
- Gestión completa de categorías y subcategorías  
- Registro y edición de gastos e ingresos  
- Visualización de movimientos por mes, año o totales  
- Informe PDF generado desde el cliente  
- Transferencias entre categorías  
- Perfil personalizable con fotografía  
- Gráficos circulares dinámicos  

---

## 🧪 Pruebas

- Validación manual del flujo de usuario  
- Pruebas de autenticación  
- Verificación de navegación y actualización automática con Riverpod  
- Pruebas de PDF tanto en web como en Android  

---

## 🧩 Requisitos

- Flutter SDK 3+
- Chrome para versión web
- Android Studio o VS Code
- API EconomyApp funcionando

---

## 👨‍💻 Autor

Desarrollado por **Vicent Roselló**, como proyecto de final de ciclo de DAW. Aplicación educativa para la gestión económica familiar.

---

## 📄 Licencia

Uso personal y educativo.
