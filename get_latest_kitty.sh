#!/bin/bash

# Variables
KITTY_URL="https://api.github.com/repos/kovidgoyal/kitty/releases/latest"
INSTALL_DIR="/opt/kitty"
BIN_PATH="/usr/local/bin/kitty"

# Obtener la última versión del bundle
echo "Obteniendo la última versión de Kitty..."
LATEST_URL=$(curl -s $KITTY_URL | grep "browser_download_url" | grep "x86_64.txz" | cut -d '"' -f 4 | head -n 1)

# Verificar si se encontró la URL
if [[ -z "$LATEST_URL" ]]; then
    echo "No se pudo obtener la URL de descarga. Verifica la conexión a internet o la API de GitHub."
    exit 1
fi

echo "Descargando Kitty desde: $LATEST_URL"
curl -L -o kitty.txz "$LATEST_URL"
