#!/bin/bash

# Script para desplegar reglas usando la API REST de Firebase
PROJECT_ID="universal-distribucion"
RULES_FILE="firestore.rules"

echo "🔥 Obteniendo token de acceso..."
TOKEN=$(gcloud auth print-access-token --project=$PROJECT_ID)

if [ -z "$TOKEN" ]; then
    echo "❌ Error: No se pudo obtener el token de acceso"
    exit 1
fi

echo "📄 Leyendo reglas desde $RULES_FILE..."
RULES_CONTENT=$(cat "$RULES_FILE")

echo "🚀 Desplegando reglas a Firebase..."
RESPONSE=$(curl -s -X POST \
  "https://firebaserules.googleapis.com/v1/projects/$PROJECT_ID/rulesets" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"source\": {
      \"files\": [{
        \"name\": \"firestore.rules\",
        \"content\": $(echo "$RULES_CONTENT" | python3 -c "import sys, json; print(json.dumps(sys.stdin.read()))")
      }]
    }
  }")

echo "$RESPONSE" | python3 -m json.tool

if echo "$RESPONSE" | grep -q '"name"'; then
    echo "✅ ¡Reglas desplegadas exitosamente!"
    RULESET_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['name'])")
    echo "📋 Ruleset creado: $RULESET_NAME"
    
    # Intentar publicar las reglas
    echo "📤 Publicando reglas..."
    RELEASE_RESPONSE=$(curl -s -X POST \
      "https://firebaserules.googleapis.com/v1/projects/$PROJECT_ID/releases" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{
        \"name\": \"projects/$PROJECT_ID/releases/cloud.firestore\",
        \"rulesetName\": \"$RULESET_NAME\"
      }")
    
    echo "$RELEASE_RESPONSE" | python3 -m json.tool
    
    if echo "$RELEASE_RESPONSE" | grep -q '"name"'; then
        echo "✅ ¡Reglas publicadas exitosamente!"
    else
        echo "⚠️  Reglas creadas pero no publicadas. Publica manualmente desde Firebase Console."
    fi
else
    echo "❌ Error al desplegar reglas:"
    echo "$RESPONSE"
    exit 1
fi






