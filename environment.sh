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
    downloads_dir="$HOME/Downloads"
fi
config_dir="$HOME/.config"
walls_dir="$HOME/Pictures/Wallpapers"
kitty_dir="/opt/kitty"
repos=(
    "https://github.com/yshui/picom.git"
    "https://github.com/VaughnValle/blue-sky.git"
    "https://github.com/romkatv/powerlevel10k.git"
)

dependencias=(
    build-essential git vim bspwm sxhkd polybar rofi zsh imagemagick feh 
    libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev 
    libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev 
    libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev 
    libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson 
    ninja-build uthash-dev zsh-autocomplete zsh-autosuggestions zsh-syntax-highlighting
)

github_latest_url() {
    curl -s "https://api.github.com/repos/$1/releases/latest" | grep "browser_download_url" | grep "$2" | cut -d '"' -f 4 | head -n 1
}

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
echo "Instalando paquetes esenciales..."
sudo apt install -y "${dependencias[@]}"

# Configurar bspwm y sxhkd
mkdir -p "$config_dir/bspwm" "$config_dir/sxhkd"
cp -r ./config/bspwm/* "$config_dir/bspwm/"
cp -r ./config/sxhkd/* "$config_dir/sxhkd/"
chmod +x "$config_dir/bspwm/bspwmrc" "$config_dir/bspwm/scripts/bspwm_resize"

# Clonar y configurar repositorios
cd "$downloads_dir"
for repo in "${repos[@]}"; do
    git clone --depth=1 "$repo"
done

# Instalar y configurar Picom
cd "$downloads_dir/picom"
meson setup --buildtype=release build && ninja -C build && sudo ninja -C build install

# Descargar y configurar Kitty
k_url=$(github_latest_url "kovidgoyal/kitty" "x86_64.txz")
[ -z "$k_url" ] && { echo "Error obteniendo Kitty"; exit 1; }
curl -L -o kitty.txz "$k_url"
sudo mkdir -p "$kitty_dir"
sudo tar -xf kitty.txz -C "$kitty_dir" && rm kitty.txz

# Configurar Wallpapers
mkdir -p "$walls_dir"
cp -r ./wallpaper/* "$walls_dir/"

# Configurar Polybar
cp -r "$downloads_dir/blue-sky/polybar/*" "$config_dir/polybar/"
mkdir -p "$config_dir/picom"
cp -r ./config/picom/* "$config_dir/picom/"

# Configurar ZSH y Powerlevel10k
git clone --depth=1 "https://github.com/romkatv/powerlevel10k.git" ~/powerlevel10k
cp ./config/powerlevel10k/.10k.zsh ~/powerlevel10k
ln -s -f "$HOME/.zshrc" /root/.zshrc
sudo usermod --shell /usr/bin/zsh root
sudo usermod --shell /usr/bin/zsh "$USER"

# Instalar sudo plugin para ZSH
sudo mkdir -p /usr/share/zsh-sudo
wget -qO /usr/share/zsh-sudo/sudo.plugin.zsh "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh"

# Instalar Bat y LSD
for pkg in "sharkdp/bat" "lsd-rs/lsd"; do
    url=$(github_latest_url "$pkg" "_amd64.deb")
    [ -z "$url" ] && { echo "Error obteniendo $pkg"; exit 1; }
    curl -L -o package.deb "$url"
    sudo dpkg -i package.deb && rm package.deb

done
