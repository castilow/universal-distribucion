#!/bin/bash

# Script para re-vincular el bucket de Firebase Storage
# Ejecutar en Cloud Shell: bash re_link_bucket.sh

PROJECT_ID="universal-distribucion"
PROJECT_NUMBER="70473962578"
BUCKET_NAME="universal-distribucion.firebasestorage.app"

echo "🔧 Re-vinculando bucket de Firebase Storage..."
echo "📦 Proyecto: $PROJECT_ID"
echo "🔢 Número de proyecto: $PROJECT_NUMBER"
echo "🪣 Bucket: $BUCKET_NAME"
echo ""

# Verificar que gcloud está instalado
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud no está instalado"
    echo "💡 Ejecuta este script en Cloud Shell"
    exit 1
fi

# Obtener token de acceso
echo "🔑 Obteniendo token de acceso..."
ACCESS_TOKEN=$(gcloud auth print-access-token)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ Error: No se pudo obtener el token de acceso"
    echo "💡 Asegúrate de estar autenticado: gcloud auth login"
    exit 1
fi

echo "✅ Token obtenido"
echo ""

# Llamar a la API REST de Firebase para re-vincular el bucket
echo "🔄 Re-vinculando bucket..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "https://firebasestorage.googleapis.com/v1beta/projects/$PROJECT_NUMBER/buckets/$BUCKET_NAME:addFirebase" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{}")

# Separar el cuerpo de la respuesta del código HTTP
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "📊 Código HTTP: $HTTP_CODE"
echo "📄 Respuesta:"
echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo "✅ ¡Bucket re-vinculado exitosamente!"
    echo "⏳ Espera 2-3 minutos para que los cambios se propaguen"
    echo "🧪 Prueba cargar una imagen en la app después de esperar"
elif [ "$HTTP_CODE" = "403" ]; then
    echo "❌ Error 403: Permisos insuficientes"
    echo "💡 Asegúrate de tener rol 'Owner' o 'Editor' en el proyecto"
elif [ "$HTTP_CODE" = "404" ]; then
    echo "❌ Error 404: Bucket o proyecto no encontrado"
    echo "💡 Verifica que el nombre del bucket y el número de proyecto sean correctos"
else
    echo "⚠️  Respuesta inesperada (código $HTTP_CODE)"
    echo "💡 Esto puede indicar que el bucket ya está vinculado o hay otro problema"
fi
