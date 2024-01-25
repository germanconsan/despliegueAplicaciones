#!/bin/bash

#by Germán Conde Sánchez

#Instalacion tomcat
# Actualizar el sistema
apt update -y
apt upgrade -y

# Instalar Java JDK
apt install openjdk-17-jdk
apt install openjdk-17-jre

# Crear usuario y grupo tomcat si no existen
if id "tomcat" >/dev/null 2>&1; then
        echo "Usuario tomcat ya existe"
else
        useradd -m -d /opt/tomcat -U -s /bin/false tomcat
fi

# Descargar Apache Tomcat
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.18/bin/apache-tomcat-10.1.18.tar.gz

# Crear directorio de instalación
mkdir -p /opt/tomcat

# Descomprimir Apache Tomcat en el directorio de instalación
tar xzvf apache-tomcat-10.1.18.tar.gz -C /opt/tomcat --strip-components=1

# Cambiar propietario y permisos del directorio de instalación
chown -R tomcat:tomcat /opt/tomcat
chmod -R u+x /opt/tomcat/bin

#Configuramos los usuarios administradores
#Añadimos los usuarios administradores
echo "<role rolename=\"manager-gui\" />
<user username=\"manager\" password=\"manager_password\" roles=\"manager-gui\" />

<role rolename=\"admin-gui\" />
<user username=\"admin\" password=\"admin_password\" roles=\"manager-gui,admin-gui\" />" >> /opt/tomcat/conf/tomcat-users.xml

#Eliminamos la restricciones por defecto


sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/, /allow="127\\.\d+\\.\d+\\.\d+\|::1\|0:0:0:0:0:0:0:1" \/>/ s/^/<!-- /; s/$/ -->/' /opt/tomcat/webapps/manager/META-INF/context.xml

# Comentamos la etiqueta Valve en context.xml de host-manager
sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/, /allow="127\\.\d+\\.\d+\\.\d+\|::1\|0:0:0:0:0:0:0:1" \/>/ s/^/<!-- /; s/$/ -->/' /opt/tomcat/webapps/host-manager/META-INF/context.xml


# Crear servicio systemd para Apache Tomcat
cat << EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF


# Obtener la ruta de instalación de Java 1.18.0
JAVA_PATH=$(sudo update-java-alternatives -l | grep '1.18.0' | awk '{print $3}')

# Reemplazar JAVA_HOME en tomcat.service
sudo sed -i "s|JAVA_HOME=/usr/lib/jvm/java-1.18.0-openjdk-amd64|JAVA_HOME=$JAVA_PATH|g" /etc/systemd/system/tomcat.service

# Recargar servicios systemd y habilitar Apache Tomcat
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat

#by Germán Conde Sánchez
