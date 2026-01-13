# Plantilla para Actualizar Credenciales de Firebase

Una vez que tengas el nuevo proyecto de Firebase creado, actualiza estos archivos con las nuevas credenciales:

## Archivos a Actualizar:

### 1. `lib/firebase_options.dart`
Reemplaza los valores en las secciones `android`, `ios`, `web`, `macos`, y `windows` con las nuevas credenciales.

### 2. `.firebaserc`
```json
{
  "projects": {
    "prod": "TU-NUEVO-PROJECT-ID"
  },
  "targets": {},
  "etags": {}
}
```

### 3. `lib/api/user_api.dart` (línea 36)
```dart
_realtime.databaseURL = 'https://TU-NUEVO-PROJECT-ID-default-rtdb.firebaseio.com';
```

### 4. `firebase.json`
Actualiza todos los `projectId` con el nuevo ID del proyecto.

### 5. `functions/index.js` (líneas 14, 15, 20)
```javascript
admin.initializeApp({
  projectId: 'TU-NUEVO-PROJECT-ID',
  storageBucket: 'TU-NUEVO-PROJECT-ID.appspot.com',
});

const PROJECT_ID = admin.app().options.projectId || process.env.GCLOUD_PROJECT || 'TU-NUEVO-PROJECT-ID';
```

### 6. Archivos de configuración nativos:
- `android/app/google-services.json` (descargar del nuevo proyecto)
- `ios/Runner/GoogleService-Info.plist` (descargar del nuevo proyecto)

## Después de Actualizar:

1. Ejecuta: `flutter pub get`
2. Ejecuta: `flutter clean`
3. Ejecuta: `flutter pub get` nuevamente
4. Prueba la aplicación







