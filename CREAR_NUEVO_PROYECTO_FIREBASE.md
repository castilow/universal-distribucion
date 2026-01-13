# Guía para Crear Nuevo Proyecto Firebase - Universal Distribución

## Paso 1: Crear el Proyecto en Firebase Console

1. Ve a: https://console.firebase.google.com/
2. Haz clic en **"Agregar proyecto"** o **"Create a project"**
3. **Nombre del proyecto**: `universal-distribucion` (o el nombre que prefieras)
4. Acepta los términos y haz clic en **"Continuar"**
5. **Google Analytics**: Puedes desactivarlo o activarlo (opcional)
6. Haz clic en **"Crear proyecto"** y espera a que se complete

## Paso 2: Configurar Aplicación Android

1. En el proyecto recién creado, haz clic en el ícono de **Android** (🖥️)
2. **Nombre del paquete Android**: `com.universaldist.app`
3. **Apodo de la app** (opcional): `Universal Distribución Android`
4. **Certificado de firma SHA-1** (opcional por ahora)
5. Haz clic en **"Registrar app"**
6. Descarga el archivo `google-services.json`
7. **IMPORTANTE**: Guarda el archivo en: `android/app/google-services.json`
8. Copia los valores que aparecen:
   - `apiKey`
   - `appId`
   - `messagingSenderId`
   - `projectId`
   - `storageBucket`

## Paso 3: Configurar Aplicación iOS

1. Haz clic en el ícono de **iOS** (🍎)
2. **ID del bundle de iOS**: `com.universaldist.app`
3. **Apodo de la app** (opcional): `Universal Distribución iOS`
4. **App Store ID** (opcional)
5. Haz clic en **"Registrar app"**
6. Descarga el archivo `GoogleService-Info.plist`
7. **IMPORTANTE**: Guarda el archivo en: `ios/Runner/GoogleService-Info.plist`
8. Copia los valores que aparecen (mismos que Android)

## Paso 4: Configurar Aplicación Web

1. Haz clic en el ícono de **Web** (</>)
2. **Apodo de la app**: `Universal Distribución Web`
3. Haz clic en **"Registrar app"**
4. Copia los valores que aparecen:
   - `apiKey`
   - `appId`
   - `messagingSenderId`
   - `projectId`
   - `authDomain`
   - `storageBucket`
   - `measurementId` (si está disponible)

## Paso 5: Habilitar Servicios Necesarios

En la consola de Firebase, habilita estos servicios:

1. **Firestore Database**:
   - Ve a "Firestore Database" → "Crear base de datos"
   - Modo: **Producción** o **Prueba** (según necesites)
   - Ubicación: Elige la más cercana (ej: `us-central1`)

2. **Realtime Database** (si la necesitas):
   - Ve a "Realtime Database" → "Crear base de datos"
   - Ubicación: Elige la más cercana

3. **Authentication**:
   - Ve a "Authentication" → "Comenzar"
   - Habilita los proveedores que uses (Email, Google, etc.)

4. **Storage**:
   - Ve a "Storage" → "Comenzar"
   - Modo: **Producción** o **Prueba**

5. **Cloud Messaging**:
   - Ya está habilitado automáticamente

## Paso 6: Obtener URL de Realtime Database

1. Ve a "Realtime Database"
2. Copia la URL que aparece (ej: `https://TU-PROYECTO-default-rtdb.firebaseio.com`)

## Paso 7: Actualizar Archivos del Proyecto

Una vez que tengas todas las credenciales, actualiza estos archivos:

1. `lib/firebase_options.dart` - Con las nuevas credenciales
2. `.firebaserc` - Con el nuevo projectId
3. `lib/api/user_api.dart` - Con la nueva URL de Realtime Database
4. `firebase.json` - Con el nuevo projectId
5. `functions/index.js` - Con el nuevo projectId

## Notas Importantes

- ⚠️ **NO elimines el proyecto antiguo** hasta que todo esté funcionando
- 📋 Guarda todas las credenciales en un lugar seguro
- 🔄 Después de actualizar, ejecuta: `flutter pub get`
- 🧪 Prueba la app antes de eliminar el proyecto antiguo







