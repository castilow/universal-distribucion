# 🤖 Configuración del Asistente ChatGPT en Klink

## ✅ Ya Configurado

La integración de ChatGPT está **completamente lista** y funcionando con Firebase Functions para mayor seguridad.

### Archivos Creados/Modificados

1. **`lib/api/chatgpt_api.dart`** - API que se comunica con Firebase Functions
2. **`lib/controllers/assistant_controller.dart`** - Controlador del asistente
3. **`lib/models/ai_assistant_user.dart`** - Modelo del usuario IA
4. **`lib/services/ai_assistant_initializer.dart`** - Inicializador del asistente en Firestore
5. **`functions/index.js`** - Cloud Function `chatWithAssistant` desplegada
6. **`lib/tabs/chats/controllers/chat_controller.dart`** - Integración en lista de chats
7. **`lib/screens/messages/controllers/message_controller.dart`** - Respuesta automática
8. **`lib/main.dart`** - Inicialización del asistente

### API Key Configurada

✅ La API key de OpenAI está configurada de forma segura en Firebase Functions
✅ La función `chatWithAssistant` está desplegada en Firebase
✅ No se expone la API key en el código de la app

## 🚀 Cómo Usar

1. **Abre la app** y ve a la pestaña de Chats
2. Verás **"Klink AI"** como primer chat
3. **Toca el chat** para abrirlo
4. **Escribe cualquier pregunta** y el asistente responderá automáticamente

## 🔧 Funcionamiento

### Flujo de Conversación

```
Usuario → Escribe mensaje
    ↓
MessageController detecta que es el asistente
    ↓
AssistantController.askAssistant()
    ↓
ChatGPTApi.sendMessage() → Firebase Functions
    ↓
Cloud Function "chatWithAssistant" → OpenAI API
    ↓
Respuesta guardada en Firestore
    ↓
Usuario ve la respuesta en el chat
```

### Características

- ✅ **Seguro**: API key oculta en Firebase Functions
- ✅ **Contexto**: Mantiene historial de los últimos 10 mensajes
- ✅ **Multiidioma**: Responde en el idioma que le hablen
- ✅ **Estado "escribiendo"**: Muestra cuando el asistente está procesando
- ✅ **Integrado**: Funciona como cualquier otro chat
- ✅ **Persistente**: Todo se guarda en Firestore

## 🛠️ Comandos Firebase (ya ejecutados)

```bash
# Configurar API key (ya hecho)
firebase functions:config:set openai.key="tu-api-key"

# Desplegar función (ya hecho)
firebase deploy --only functions:chatWithAssistant

# Ver logs (para debug)
firebase functions:log --only chatWithAssistant
```

## 💰 Costos

### OpenAI API
- **Modelo**: GPT-3.5 Turbo
- **Costo aproximado**: $0.002 por cada 1000 tokens
- **Límite por mensaje**: 800 tokens de respuesta
- **Estimado**: ~$0.001-0.003 por conversación

### Firebase Functions
- **Plan Blaze** (pago por uso)
- **Invocaciones**: Primeras 2M gratis
- **Costo adicional**: $0.40 por millón

### Recomendaciones para Reducir Costos

1. Limitar el número de mensajes en el historial (actualmente 10)
2. Reducir `max_tokens` si las respuestas son muy largas
3. Implementar rate limiting (límite de mensajes por usuario)
4. Cachear respuestas frecuentes

## 🔐 Seguridad en Producción

### ⚠️ Importante

La API key está configurada en Firebase Functions, lo cual es **mucho más seguro** que tenerla en la app, pero considera:

1. **Rate Limiting**: Implementar límites de uso por usuario
2. **Validación**: Verificar autenticación en todas las llamadas
3. **Monitoreo**: Revisar logs regularmente
4. **Presupuesto**: Establecer límites en OpenAI Dashboard

## 📊 Monitoreo

### Ver uso de la API

1. Ve a https://platform.openai.com/usage
2. Revisa el consumo diario/mensual
3. Configura alertas de gasto

### Ver logs de Firebase

```bash
# Logs en tiempo real
firebase functions:log --only chatWithAssistant

# Ver en consola
https://console.firebase.google.com/project/klink-b0358/functions
```

## 🎨 Personalización

### Cambiar el Prompt del Sistema

Edita en `functions/index.js` línea ~732:

```javascript
content: "Eres Klink AI, un asistente inteligente..."
```

### Cambiar el Modelo

En `functions/index.js` línea ~769:

```javascript
model: "gpt-3.5-turbo", // Cambiar a "gpt-4" para mejor calidad (más caro)
```

### Ajustar Parámetros

```javascript
temperature: 0.7,        // Creatividad (0-2)
max_tokens: 800,         // Longitud de respuesta
presence_penalty: 0.6,   // Penalización por repetición
frequency_penalty: 0.3,  // Penalización por frecuencia
```

## 🐛 Solución de Problemas

### El asistente no responde

1. Verificar que Firebase Functions esté desplegada:
   ```bash
   firebase functions:list
   ```

2. Ver logs de errores:
   ```bash
   firebase functions:log --only chatWithAssistant
   ```

3. Verificar API key:
   ```bash
   firebase functions:config:get
   ```

### Error de timeout

- Aumentar el timeout en `lib/api/chatgpt_api.dart` (línea 21)
- O en `functions/index.js` (línea 757)

### Error "unauthenticated"

- Asegurarse de que el usuario esté autenticado en Firebase Auth
- Verificar que `context.auth` exista en la Cloud Function

## 📝 Próximas Mejoras

- [ ] Agregar avatar personalizado para el asistente
- [ ] Implementar rate limiting
- [ ] Cachear respuestas comunes
- [ ] Agregar comandos especiales (/help, /reset, etc.)
- [ ] Soporte para imágenes (GPT-4 Vision)
- [ ] Estadísticas de uso del asistente

## ✨ ¡Listo para Usar!

El asistente ChatGPT está completamente integrado y funcionando. Solo ejecuta:

```bash
flutter run
```

Y verás a **Klink AI** en tu lista de chats. ¡Pruébalo!



