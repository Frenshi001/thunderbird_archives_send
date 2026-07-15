#!/bin/bash

# contiene la fecha del día del equipo
today=$(date | awk '{print $2,$3,$4}')

# Función encargada de todo el proceso para listar y enviar los archivos
function process_send (){

	# Directorio a monitorear
	WATCH_DIR="$HOME/Documentos/Inventarios"

	# Archivo de estado con la fecha del último envío
	STATE_FILE="$HOME/.last_sent_docs_thunderbird"

	# Archivo temporal para lista de archivos modificados
	MODIFIED_LIST="/tmp/modified_files_thunderbird_$$.txt"

	# Fecha actual (para actualizar estado)
	CURRENT_DATE=$(date +"%Y%m%d%H%M.%S")

	# Destinatario
	TO="melemetrix@gmail.com"

	# Asunto del correo
	SUBJECT="Documentos modificados el $(date '+%d/%m/%Y')"

	# Cuerpo del mensaje (se mostrará junto con los archivos adjuntos)
	BODY="Se adjuntan los documentos que han cambiado desde el último envío:
	
	"
	# --- Determinar fecha del último envío ---
	if [ -f "$STATE_FILE" ]; then
	    LAST_SENT=$(cat "$STATE_FILE")  # No se usa directamente, pero lo guardamos por si acaso
	else
	    # Si no existe, creamos uno con fecha antigua para enviar todos los archivos
	    touch -t "197001010000.00" "$STATE_FILE"
	fi

	#Buscar archivos modificados después del último envío ---
	# Usamos -newer con el archivo de estado (su timestamp indica cuándo se envió la última vez)
	find "$WATCH_DIR" -type f -newer "$STATE_FILE" 2>/dev/null > "$MODIFIED_LIST"

	# Contar archivos
	COUNT=$(wc -l < "$MODIFIED_LIST")

	if [ "$COUNT" -eq 0 ]; then
	    echo "No hay documentos nuevos o modificados. No se envía nada."
	    # Actualizar estado para no re-evaluar los mismos archivos
	    touch -t "$CURRENT_DATE" "$STATE_FILE"
	    rm -f "$MODIFIED_LIST"
	    exit 0
	fi

	# Preparar lista de adjuntos para Thunderbird ---
	# Thunderbird espera los adjuntos separados por comas y entre comillas simples
	ATTACHMENTS=$(cat "$MODIFIED_LIST" | paste -sd ',' -)

	# Completar el cuerpo con la lista de archivos
	BODY+=$(awk -F/ '{print $NF}' "$MODIFIED_LIST")
	thunderbird -compose "to='$TO',subject='$SUBJECT',body='$BODY',attachment='$ATTACHMENTS'" &

	touch -t "$CURRENT_DATE" "$STATE_FILE"

	# --- Limpieza ---
	rm -f "$MODIFIED_LIST"

	exit 0
}

# multiples fechas del mes para confirmar y enviar; el formato es "dd mm yy"
fechas=("31 jul 2026" "16 jul 2026" "31 ago 2026" "30 sep 2026" "30 oct 2026" "30 nov 2026" "15 dic 2026" "15 ene 2027" "29 ene 2027" "26 feb 2027" "31 mar 2027" "30 abr 2027")

# Itera dentro del arreglo de "fechas" si alguna hace match procede a ejecutar la función "process_send" 
for test in "${fechas[@]}"; do
	if [[ "$test" == "$today" ]]; then
		process_send	
	fi
	done
