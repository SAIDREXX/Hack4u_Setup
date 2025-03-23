#!/bin/bash

# Verificar que el script no se ejecute como root
if [ "$(id -u)" -eq 0 ]; then
    echo "No ejecutes este script como root. Usa un usuario normal con sudo."
    exit 1
fi

# Definir variables
if [ -d "$HOME/Downloads" ]; then
    downloads_dir="$HOME/Downloads"
elif [ -d "$HOME/Descargas" ]; then
    downloads_dir="$HOME/Descargas"
else
    downloads_dir="$HOME/Downloads" # Por defecto, en caso de que no exista ninguna
fi
config_dir="$HOME/.config"
walls_dir="$HOME/Pictures/Wallpapers"
kitty_dir="/opt/kitty"
kitty_url="https://api.github.com/repos/kovidgoyal/kitty/releases/latest"
BAT_URL="https://api.github.com/repos/sharkdp/bat/releases/latest"
LSD_URL="https://api.github.com/repos/lsd-rs/lsd/releases/latest"

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependencias necesarias
echo "Instalando paquetes esenciales..."
sudo apt install -y build-essential git vim bspwm sxhkd polybar rofi zsh imagemagick feh \
    libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev \
    libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev \
    libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev \
    libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev zsh-autocomplete \
    zsh-autosuggestions zsh-syntax-highlighting

# Configurar bspwm y sxhkd
echo "Configurando bspwm y sxhkd..."
mkdir -p "$config_dir/bspwm" "$config_dir/sxhkd"
cp -r ./config/bspwm/* "$config_dir/bspwm/"
cp -r ./config/sxhkd/* "$config_dir/sxhkd/"
chmod +x "$config_dir/bspwm/bspwmrc" "$config_dir/bspwm/scripts/bspwm_resize"

# Instalar y configurar Picom
echo "Instalando Picom..."
cd "$downloads_dir"
git clone https://github.com/yshui/picom.git && cd picom
meson setup --buildtype=release build && ninja -C build && sudo ninja -C build install
cd ..

# Descargar y configurar Kitty
echo "Descargando la última versión de Kitty..."
k_url=$(curl -s "$kitty_url" | grep "browser_download_url" | grep "x86_64.txz" | cut -d '"' -f 4 | head -n 1)

if [[ -n "$k_url" ]]; then
    echo "Descargando Kitty desde: $k_url"
    curl -L -o kitty.txz "$k_url"
    sudo mkdir -p "$kitty_dir"
    sudo mv kitty.txz "$kitty_dir"
    cd "$kitty_dir"
    sudo 7z x kitty.txz && sudo rm kitty.txz
    sudo tar -xf kitty.tar && sudo rm kitty.tar
else
    echo "Error: No se pudo obtener la URL de Kitty."
    exit 1
fi

mkdir -p "$config_dir/kitty"
cp -r "$downloads_dir/Hack4u_Setup/config/kitty/"* "$config_dir/kitty/"

# Configurar Wallpapers
echo "Configurando fondos de pantalla..."
mkdir -p "$walls_dir"
cp -r "$downloads_dir/Hack4u_Setup/wallpaper/"* "$walls_dir/"

# Instalar y configurar Polybar
echo "Instalando y configurando Polybar..."
git clone https://github.com/VaughnValle/blue-sky.git "$downloads_dir/blue-sky"
sudo cp -r "$downloads_dir/blue-sky/polybar/"* "$config_dir/polybar/"
sudo cp "$downloads_dir/blue-sky/polybar/fonts/"* /usr/share/fonts/truetype/
fc-cache -f -v

mkdir -p "$config_dir/picom"
cp -r "$downloads_dir/Hack4u_Setup/config/picom/"* "$config_dir/picom/"

# Cambiar shell solo si no es Zsh
if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
    echo "Cambiando shell a Zsh..."
    sudo usermod --shell /usr/bin/zsh "$USER"
fi

# Configurar Powerlevel10k
echo "Configurando Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
cp -r "$downloads_dir/Hack4u_Setup/config/powerlevel10k/.10k.zsh" ~/powerlevel10k

sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
sudo cp -r "$downloads_dir/Hack4u_Setup/config/powerlevel10k/.10k.zsh-root" /root/powerlevel10k/.p10k.zsh

# Crear enlace simbólico en /root/.zshrc con permisos adecuados
if [[ ! -L /root/.zshrc ]]; then
    echo "Creando enlace simbólico en /root/.zshrc..."
    sudo ln -s -f "$HOME/.zshrc" /root/.zshrc
else
    echo "El enlace simbólico /root/.zshrc ya existe."
fi

# Instalar complemento sudo para Zsh
echo "Instalando complemento sudo para Zsh..."
sudo mkdir -p /usr/share/zsh-sudo
sudo wget -q -O /usr/share/zsh-sudo/sudo.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh

# Descargar e instalar bat
echo "Obteniendo la última versión de bat..."
LATEST_BAT_URL=$(curl -s $BAT_URL | grep "browser_download_url" | grep "_amd64.deb" | cut -d '"' -f 4 | head -n 1)

if [[ -n "$LATEST_BAT_URL" ]]; then
    echo "Descargando bat desde: $LATEST_BAT_URL"
    curl -L -o bat.deb "$LATEST_BAT_URL"
    sudo dpkg -i bat.deb
else
    echo "Error: No se pudo obtener la URL de bat."
fi

# Descargar e instalar lsd
echo "Obteniendo la última versión de lsd..."
LATEST_LSD_URL=$(curl -s $LSD_URL | grep "browser_download_url" | grep "_amd64.deb" | cut -d '"' -f 4 | head -n 1)

if [[ -n "$LATEST_LSD_URL" ]]; then
    echo "Descargando lsd desde: $LATEST_LSD_URL"
    curl -L -o lsd.deb "$LATEST_LSD_URL"
    sudo dpkg -i lsd.deb
else
    echo "Error: No se pudo obtener la URL de lsd."
fi

# Eliminar archivos temporales solo al final
echo "Eliminando archivos temporales..."
rm -rf "$downloads_dir/picom"
rm -rf "$downloads_dir/blue-sky"
rm -rf "$kitty_dir/kitty.txz"
rm -rf bat.deb lsd.deb

echo "Instalación y configuración completadas con éxito."
