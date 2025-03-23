#!/bin/bash

# Verificar que el script no se ejecute como root
if [ "$(id -u)" -eq 0 ]; then
    echo "No ejecutes este script como root. Usa un usuario normal con sudo."
    exit 1
fi

# Definir variables
downloads_dir="$HOME/Downloads"
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
cd .. && rm -rf picom

# Descargar y configurar Kitty
echo "Descargando la última versión de Kitty..."
k_url=$(curl -s "$kitty_url" | grep "browser_download_url" | grep "x86_64.txz" | cut -d '"' -f 4 | head -n 1)
if [[ -z "$k_url" ]]; then
    echo "No se pudo obtener la URL de Kitty. Verifica tu conexión a Internet."
    exit 1
fi

echo "Descargando Kitty desde: $k_url"
curl -L -o kitty.txz "$k_url"
sudo mkdir -p "$kitty_dir"
sudo mv kitty.txz "$kitty_dir"
cd "$kitty_dir"
7z x kitty.txz && rm kitty.txz
tar -xf kitty.tar && rm kitty.tar

mkdir -p "$config_dir/kitty"
cp -r ./config/kitty/* "$config_dir/kitty/"

# Configurar Wallpapers
echo "Configurando fondos de pantalla..."
mkdir -p "$walls_dir"
cp -r ./wallpaper/* "$walls_dir/"

# Instalar y configurar Polybar
echo "Instalando y configurando Polybar..."
git clone https://github.com/VaughnValle/blue-sky.git "$downloads_dir/blue-sky"
cp -r "$downloads_dir/blue-sky/polybar/*" "$config_dir/polybar/"
cp "$downloads_dir/blue-sky/polybar/fonts"/* /usr/share/fonts/truetype/
fc-cache -f -v

mkdir -p "$config_dir/picom" 
cp -r ./config/picom/* "$config_dir/picom/"
usermod --shell /usr/bin/zsh root
usermod --shell /usr/bin/zsh "$USER"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
cp -r ./config/powerlevel10k/.10k.zsh ~/powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
cp -r ./config/powerlevel10k/.10k.zsh-root /root/powerlevel10k/.p10k.zsh
ln -s -f "$HOME/.zshrc" /root/.zshrc
chown root:root /usr/local/share/zsh/site-functions/_bspc
mkdir /usr/share/zsh-sudo
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
mv sudo.plugin.zsh /usr/share/zsh-sudo

echo "Obteniendo la última versión de bat..."
LATEST_URL=$(curl -s $BAT_URL | grep "browser_download_url" | grep "_amd64.deb" | cut -d '"' -f 4 | head -n 1)

# Verificar si se encontró la URL
if [[ -z "$LATEST_URL" ]]; then
    echo "No se pudo obtener la URL de descarga. Verifica la conexión a internet o la API de GitHub."
    exit 1
fi

echo "Descargando bat desde: $LATEST_URL"
curl -L -o bat.deb "$LATEST_URL"

# Obtener la última versión del paquete .deb para AMD64
echo "Obteniendo la última versión de lsd..."
LATEST_URL=$(curl -s $LSD_URL | grep "browser_download_url" | grep "_amd64.deb" | cut -d '"' -f 4 | head -n 1)

# Verificar si se encontró la URL
if [[ -z "$LATEST_URL" ]]; then
    echo "No se pudo obtener la URL de descarga. Verifica la conexión a internet o la API de GitHub."
    exit 1
fi

echo "Descargando lsd desde: $LATEST_URL"
curl -L -o lsd.deb "$LATEST_URL"

# Instalar bat y lsd
dpkg -i bat.deb lsd.deb
rm bat.deb lsd.deb



