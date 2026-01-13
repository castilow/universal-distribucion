# Pasos Rápidos para Crear Nuevo Proyecto Firebase

## ⚡ Opción Rápida (Recomendada)

### Paso 1: Crear Proyecto en Firebase Console
1. Ve a: https://console.firebase.google.com/
2. Clic en **"Agregar proyecto"**
3. Nombre: `universal-distribucion` (o el que prefieras)
4. Crea el proyecto

### Paso 2: Configurar con FlutterFire CLI
Una vez creado el proyecto, ejecuta en la terminal:

```bash
cd /Users/castilow/Downloads/UniversalDistribucion
flutterfire configure
```

Este comando te pedirá:
- Seleccionar el proyecto de Firebase que acabas de crear
- Seleccionar las plataformas (Android, iOS, Web, macOS, Windows)
- Automáticamente actualizará `firebase_options.dart` y descargará los archivos de configuración

### Paso 3: Actualizar Referencias Manuales
Después de `flutterfire configure`, actualiza estos archivos:

1. **`.firebaserc`** - Cambia `"prod": "klink-b0358"` por tu nuevo projectId
2. **`lib/api/user_api.dart`** (línea 36) - Actualiza la URL de Realtime Database
3. **`firebase.json`** - Actualiza los projectId
4. **`functions/index.js`** - Actualiza projectId y storageBucket

### Paso 4: Habilitar Servicios en Firebase Console
1. **Firestore Database**: Crear base de datos
2. **Realtime Database**: Crear base de datos (si la necesitas)
3. **Authentication**: Habilitar proveedores
4. **Storage**: Habilitar

### Paso 5: Limpiar y Reconstruir
```bash
flutter clean
flutter pub get
```

## 📝 Notas
- El comando `flutterfire configure` hace la mayor parte del trabajo automáticamente
- Solo necesitas actualizar las referencias manuales en los archivos mencionados
- NO elimines el proyecto antiguo hasta que todo funcione







