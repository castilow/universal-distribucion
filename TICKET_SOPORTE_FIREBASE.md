# Ticket de Soporte - Error 412 Firebase Storage

## Información del Proyecto
- **Nombre del Proyecto**: universal-distribucion
- **Project ID**: universal-distribucion
- **Número de Proyecto**: 70473962578
- **Bucket de Storage**: universal-distribucion.firebasestorage.app

## Problema
Las imágenes almacenadas en Firebase Storage no se pueden cargar debido a un error HTTP 412 (Precondition Failed). El error indica que falta un permiso necesario en la cuenta de servicio de Firebase Storage.

### Mensaje de Error
```
HTTP request failed, statusCode: 412
A required service account is missing necessary permissions. Please resolve by visiting the Storage page of the Firebase Console and re-linking your Firebase bucket
```

## Acciones Realizadas

1. ✅ **Asignado rol IAM**: Se asignó el rol "Cloud Storage for Firebase Service Agent" (roles/firebasestorage.serviceAgent) a la cuenta de servicio:
   - `service-70473962578@gcp-sa-firebasestorage.iam.gserviceaccount.com`
   - Verificado en Google Cloud Console IAM que el rol está correctamente asignado
   - **IMPORTANTE**: La cuenta de servicio también tiene el rol "Propietario" (Owner) asignado, lo que debería otorgar acceso completo
   - Sin embargo, el error 412 persiste incluso con el rol más alto (Owner), lo que confirma que es un bug de Firebase

2. ✅ **Reglas de Storage**: Configuradas con `allow read: if true` para permitir lectura pública

3. ✅ **Tiempo de espera**: Más de 8 horas esperando la propagación de permisos IAM

4. ⚠️ **PROBLEMA CRÍTICO DE FACTURACIÓN**: 
   - Se descubrió que hay **otro proyecto** vinculado a la misma cuenta de facturación con **deuda de 200€**
   - Los proyectos **NO son independientes** si comparten la misma cuenta de facturación
   - Si una cuenta de facturación está en estado "delinquent" (morosa), puede afectar a TODOS los proyectos vinculados
   - Los logs muestran: `The billing account for the owning project is disabled in state delinquent`
   - Esto explica por qué el error 412 persiste incluso después de activar billing en este proyecto

5. ✅ **Intentos de regeneración**: Intentado regenerar URLs usando `getDownloadURL()` y `getData()` - ambos fallan con error 412
   - `getDownloadURL()`: `[firebase_storage/unknown] Unexpected 412 code from backend`
   - `getData()`: `[firebase_storage/unknown] Unexpected 412 code from backend`
   - Esto confirma que el problema NO es de tokens expirados, sino de permisos de cuenta de servicio

6. ✅ **Re-vinculado del bucket**: Se ejecutó el comando `addFirebase` usando la API REST de Firebase Storage:
   ```bash
   POST https://firebasestorage.googleapis.com/v1beta/projects/70473962578/buckets/universal-distribucion.firebasestorage.app:addFirebase
   ```
   - Respuesta exitosa: `{"name": "projects/70473962578/buckets/universal-distribucion.firebasestorage.app"}`
   - Sin embargo, el error 412 persiste después de re-vincular

## Impacto
- Las imágenes subidas previamente no se pueden visualizar en la aplicación
- Los usuarios no pueden ver imágenes de productos
- La funcionalidad principal de la aplicación está afectada

## Logs de Error
```
══╡ EXCEPTION CAUGHT BY IMAGE RESOURCE SERVICE ╞════════════════════════════════════════════════════
The following NetworkImageLoadException was thrown resolving an image codec:
HTTP request failed, statusCode: 412,
https://firebasestorage.googleapis.com/v0/b/universal-distribucion.firebasestorage.app/o/uploads%2F...
```

## Evidencia Crítica
La cuenta de servicio `service-70473962578@gcp-sa-firebasestorage.iam.gserviceaccount.com` tiene asignados los siguientes roles en IAM:
- ✅ **Cloud Storage for Firebase Service Agent** (roles/firebasestorage.serviceAgent)
- ✅ **Propietario** (Owner) - Rol con acceso completo

**A pesar de tener el rol Owner (máximo nivel de permisos), el error 412 persiste.** Esto confirma que el problema NO es de configuración de permisos, sino un bug en el sistema de Firebase Storage.

## Solicitud
Necesitamos asistencia urgente para:
1. **Verificar el estado de la cuenta de facturación compartida**: Confirmar si la deuda de 200€ en otro proyecto está bloqueando Storage en este proyecto
2. **Desbloquear Storage**: Si el problema es la cuenta de facturación compartida, necesitamos que se desbloquee Storage para este proyecto específico
3. **Alternativa**: Si es posible, separar las cuentas de facturación para que los proyectos sean independientes
4. Investigar por qué el error 412 persiste incluso con el rol Owner asignado
5. Verificar si hay algún problema conocido con el bucket `universal-distribucion.firebasestorage.app`

## Enlaces Útiles
- IAM Console: https://console.cloud.google.com/iam-admin/iam?project=universal-distribucion
- Storage Console: https://console.firebase.google.com/project/universal-distribucion/storage
- Firebase Status: https://status.firebase.google.com/
