#!/bin/bash

# Nombre del stack
stack_name="pilaTomCat"

# Nombre del archivo YAML de la plantilla
template_file="ubuntu.yml"

# Parámetros (si es necesario)
# parameters="--parameter-overrides ParameterKey1=Value1 ParameterKey2=Value2"

# Región de AWS
region="us-east-1"

# Configurar formato de salida predeterminado
aws configure set default.output json

# Comando para crear el stack
aws cloudformation create-stack \
    --stack-name $stack_name \
    --template-body file://$template_file \
    --region $region $parameters \
    --profile default  # Agrega esta línea

# Esperar hasta que la pila esté completa
aws cloudformation wait stack-create-complete \
    --stack-name $stack_name \
    --region $region \
    --profile default  # Agrega esta línea


if [ $? -eq 0 ]; then
	aws cloudformation list-exports \
        --query "Exports[?Name=='TomcatManagementConsoleURL'].Value"
fi

echo "Stack desplegado exitosamente."

