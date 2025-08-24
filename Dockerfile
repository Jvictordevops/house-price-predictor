# Usar imagen base Python slim para reducir tamaño
FROM python:3.11-slim

# Establecer directorio de trabajo
WORKDIR /app

# Copiar todo el código fuente
COPY src/api/ .

COPY models/trained/*.pkl ./models/trained/

# Instalar dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Crear usuario no-root para seguridad
#RUN useradd --create-home --shell /bin/bash app \
#    && chown -R app:app /app
#USER app

# Exponer puerto 8000
EXPOSE 8000

# Comando de lanzamiento
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]