# Solución para Error 412 - Permisos de Storage

## El Problema
Error 412: "A required service account is missing necessary permissions"

Este error indica que la cuenta de servicio de Firebase Storage no tiene los permisos necesarios para acceder al bucket.

## Solución Rápida (5 minutos)

### Opción 1: Google Cloud Console (Recomendado)

1. **Abre este enlace:**
   https://console.cloud.google.com/iam-admin/iam?project=universal-distribucion

2. **Busca esta cuenta de servicio:**
   ```
   service-70473962578@gcp-sa-firebasestorage.iam.gserviceaccount.com
   ```
   O busca cualquier cuenta que contenga "firebasestorage"

3. **Si NO existe la cuenta:**
   - Haz clic en "GRANT ACCESS" / "CONCEDER ACCESO"
   - En "New principals", pega: `service-70473962578@gcp-sa-firebasestorage.iam.gserviceaccount.com`
   - En "Role", selecciona: `Cloud Storage for Firebase Service Agent`
   - Haz clic en "SAVE"

4. **Si la cuenta SÍ existe pero NO tiene el rol correcto:**
   - Haz clic en el ícono de editar (✏️) junto a la cuenta
   - Haz clic en "ADD ANOTHER ROLE"
   - Selecciona: `Cloud Storage for Firebase Service Agent`
   - Haz clic en "SAVE"

5. **Espera 2-3 minutos** para que los cambios se propaguen

### Opción 2: Firebase Console - Settings

1. Ve a: https://console.firebase.google.com/project/universal-distribucion/storage/settings

2. Busca cualquier botón o mensaje que diga:
   - "Re-link bucket"
   - "Vincular bucket"
   - Mensaje de alerta sobre permisos

3. Si encuentras alguna opción de re-vincular, úsala.

## Verificar que Funcionó

Después de hacer los cambios, espera 2-3 minutos y luego:
1. Intenta cargar una imagen en la app
2. Las imágenes deberían aparecer correctamente

## Notas Importantes

- Este problema NO es de código, es de configuración de Firebase/Google Cloud
- Las imágenes existen en Storage (ya las verificaste)
- Una vez arreglados los permisos, las imágenes deberían funcionar automáticamente
