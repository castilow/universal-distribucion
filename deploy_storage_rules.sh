#!/bin/bash

# Script para desplegar reglas de Firebase Storage
# Ejecuta este script después de autenticarte con la cuenta correcta

echo "🔥 Desplegando reglas de Firebase Storage..."

# Verificar que Firebase CLI esté instalado
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI no está instalado. Instálalo con: npm install -g firebase-tools"
    exit 1
fi

# Verificar autenticación
echo "📋 Verificando autenticación..."
firebase projects:list | grep -q "universal-distribucion"
if [ $? -ne 0 ]; then
    echo "⚠️  El proyecto 'universal-distribucion' no está disponible en tu cuenta actual."
    echo "🔐 Por favor, autentícate con la cuenta correcta:"
    echo "   firebase login"
    echo ""
    echo "Luego ejecuta este script de nuevo."
    exit 1
fi

# Desplegar reglas de Storage
echo "🚀 Desplegando reglas de Firebase Storage..."
firebase deploy --only storage --project universal-distribucion

if [ $? -eq 0 ]; then
    echo "✅ ¡Reglas de Firebase Storage desplegadas exitosamente!"
else
    echo "❌ Error al desplegar las reglas. Verifica los permisos."
    exit 1
fi






