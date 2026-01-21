# Pasos para Verificar y Resolver Problema de Facturación

## Problema Detectado
- Banner de "Actividad sospechosa" en Google Cloud Console
- No se ven cuentas de facturación (puede ser por el filtro "Activo")
- Error 412 en Firebase Storage

## Pasos Inmediatos

### 1. Resolver Banner de Actividad Sospechosa
1. Haz clic en **"Corregir ahora"** en el banner naranja
2. Sigue las instrucciones para verificar tu cuenta
3. Esto puede requerir:
   - Verificar tu identidad
   - Confirmar método de pago
   - Actualizar información de facturación

### 2. Ver TODAS las Cuentas de Facturación
1. En la página de Billing, **quita el filtro "Estado: Activo"**
   - Haz clic en la "X" del filtro azul
2. Ahora deberías ver TODAS las cuentas, incluyendo:
   - Suspendidas
   - Morosas (Delinquent)
   - Cerradas
   - Activas

### 3. Verificar Estado de Cada Cuenta
Busca en la columna "Estado" y verifica:
- ✅ **Activo** = OK
- ⚠️ **Delinquent** = Morosa (necesita pago)
- ❌ **Suspended** = Suspendida (bloqueada)
- ❌ **Closed** = Cerrada

### 4. Ver Proyectos Vinculados
1. Haz clic en el nombre de cada cuenta de facturación
2. Ve a la pestaña **"Proyectos vinculados"**
3. Verifica qué proyectos están vinculados a cada cuenta
4. Identifica cuál tiene la deuda de 200€

### 5. Opciones de Solución

#### Opción A: Pagar la Deuda
1. Identifica la cuenta con estado "Delinquent"
2. Haz clic en "Pagar" o "Actualizar método de pago"
3. Completa el pago
4. Espera 10-30 minutos para que se actualice el estado

#### Opción B: Desvincular Proyectos
1. Si quieres separar los proyectos:
   - Ve a cada proyecto individual
   - Cambia su cuenta de facturación
   - O desvincula el proyecto con deuda

#### Opción C: Crear Nueva Cuenta de Facturación
1. Si no puedes pagar la deuda ahora:
   - Crea una nueva cuenta de facturación
   - Vincula solo el proyecto "universal-distribucion" a la nueva cuenta
   - Esto separará los proyectos

## Enlaces Útiles
- Billing Console: https://console.cloud.google.com/billing
- Firebase Console: https://console.firebase.google.com/project/universal-distribucion
- Google Cloud Support: https://cloud.google.com/support
