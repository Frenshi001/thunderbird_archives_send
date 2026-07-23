#!/bin/bash

# Otorga permisos de ejecucion a la aplicacion
sudo chmod +x thunderbird_archives_send.sh

# Copia el script a la ruta "usr/local/bin" conservando los permisos, usuario y grupo del script 
sudo cp -p thunderbird_archives_send.sh /usr/local/bin/

# Muestra un cuestionario para colocar la configuracion de ejecucion del "cron"
read -p "ingresa los parametros para el cron (* * * * *):" info_cron

# Crea un archivo temporal dentro de "tmp"
touch /tmp/crontemp

# Vacia la informacion dentro del crontab
crontab -l > /tmp/crontemp

# Agrega los parametros para el cron,la ejecucion de bash y la ruta absoluta del script en la ultima linea
echo "$info_cron /bin/bash /usr/local/bin/thunderbird_archives_send.sh" >> /tmp/crontemp

# Actualiza las configuraciones dentro del crontab utilizando toda la informacion del archivo temporal
crontab /tmp/crontemp

# Elimina el archivo temporal
rm /tmp/crontemp

# Reinicia el servicio de crontab seguido de un mensaje de éxito
systemctl restart cron.service && echo "Instalacion exitosa"
