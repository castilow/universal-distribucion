# 🔥 Desplegar Reglas de Firestore

## Opción 1: Usando el script (Recomendado)

1. Asegúrate de estar autenticado con la cuenta correcta:
   ```bash
   firebase login
   ```

2. Ejecuta el script:
   ```bash
   ./deploy_firestore_rules.sh
   ```

## Opción 2: Comando directo

Ejecuta este comando directamente:

```bash
firebase deploy --only firestore:rules --project universal-distribucion
```

## Opción 3: Desde Firebase Console (Manual)

Si no tienes acceso desde CLI, copia las reglas manualmente:

1. Ve a: https://console.firebase.google.com/project/universal-distribucion/firestore/rules
2. Copia el contenido de `firestore.rules`
3. Pega en el editor de reglas
4. Haz clic en "Publicar"






