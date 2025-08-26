#!/bin/bash

# test-ingress.sh - Diagnóstico completo del Ingress

echo "🔍 Diagnosticando Ingress para Streamlit..."

echo "1️⃣ Estado del Ingress:"
kubectl get ingress -n hpp streamlit-ingress

echo -e "\n2️⃣ Detalles del Ingress:"
kubectl describe ingress -n hpp streamlit-ingress | grep -E "(Host|Path|Address|Backend)"

echo -e "\n3️⃣ Service backend:"
kubectl get svc -n hpp streamlit-service

echo -e "\n4️⃣ Endpoints del service:"
kubectl get endpoints -n hpp streamlit-service

echo -e "\n5️⃣ Pods corriendo:"
kubectl get pods -n hpp -l app=streamlit

echo -e "\n6️⃣ Nginx Controller:"
kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller

echo -e "\n🧪 PRUEBAS DE ACCESO:"

echo -e "\n📡 Prueba 1 - Directo a localhost:"
if curl -s --max-time 5 http://localhost >/dev/null 2>&1; then
    echo "✅ localhost responde"
else
    echo "❌ localhost no responde"
fi

echo -e "\n📡 Prueba 2 - Con header Host:"
if curl -s --max-time 5 -H "Host: localhost" http://localhost >/dev/null 2>&1; then
    echo "✅ localhost con header responde"
else
    echo "❌ localhost con header no responde"
fi

echo -e "\n📡 Prueba 3 - Puerto directo del nginx:"
NGINX_PORT=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[0].nodePort}')
if curl -s --max-time 5 http://localhost:$NGINX_PORT >/dev/null 2>&1; then
    echo "✅ Puerto directo nginx ($NGINX_PORT) responde"
else
    echo "❌ Puerto directo nginx ($NGINX_PORT) no responde"
fi

echo -e "\n📡 Prueba 4 - Service interno (port-forward):"
echo "Iniciando port-forward temporal..."
kubectl port-forward -n hpp service/streamlit-service 8502:8501 >/dev/null 2>&1 &
PF_PID=$!
sleep 2

if curl -s --max-time 3 http://localhost:8502 >/dev/null 2>&1; then
    echo "✅ Service interno funciona"
else
    echo "❌ Service interno no funciona"
fi

kill $PF_PID 2>/dev/null

echo -e "\n🎯 Recomendación:"
echo "Si solo funciona el Service interno, el problema está en el Ingress"
echo "Si nada funciona, el problema está en el Pod/Service"