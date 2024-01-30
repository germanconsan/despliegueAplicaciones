#!/bin/bash

# Nombre de la pila a eliminar
stack_name="pila2"

# Región de AWS
region="us-east-1"

# Comando para eliminar la pila
aws cloudformation delete-stack --stack-name $stack_name --region $region

# Esperar hasta que la pila se haya eliminado completamente
aws cloudformation wait stack-delete-complete --stack-name $stack_name --region $region

echo "Pila eliminada exitosamente: $stack_name"

