if [ "$(whoami)" == "root" ]; then
    exit 1
fi

KITTY_URL="https://api.github.com/repos/kovidgoyal/kitty/releases/latest"

chmod +x ./get_latest_kitty.sh
./get_latest_kitty.sh

sudo apt update
sudo parrot-upgrade
cd /home/saidrexxx/Downloads
sudo apt install build-essential git vim xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev -y
sudo apt install bspwm sxhkd
mkdir -p ~/.config/bspwm
mkdir -p ~/.config/sxhkd
cp -r ./config/bspwm/* ~/.config/bspwm/
cp -r ./config/sxhkd/* ~/.config/sxhkd/
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/scripts/bspwm_resize
sudo apt install polybar
sudo apt install libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev -y
git clone https://github.com/yshui/picom.git
cd picom
meson setup --buildtype=release build
ninja -C build
ninja -C build install
sudo apt install rofi
mv ./fonts/* /usr/local/share/fonts/
sudo apt install zsh

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
mkdir /opt/kitty
mv kitty.txz /opt/kitty
7z x /opt/kitty/kitty.txz
rm /opt/kitty/kitty.txz
tar -xf /opt/kitty/kitty.tar
rm /opt/kitty/kitty.tar
mkdir -p ~/.config/kitty
cp -r ./config/kitty/* ~/.config/kitty/
sudo apt install imagemagick
sudo apt install feh
mkdir /home/saidrexxx/Pictures/Wallpapers
cp -r ./wallpaper/* /home/saidrexxx/Pictures/Wallpapers/
mkdir -p /root/.config/kitty
cp -r ./config/kitty/* /root/.config/kitty/
git clone https://github.com/VaughnValle/blue-sky.git
cd blue-sky/
cd polybar/
cp -r * ~/.config/polybar/
cp fonts/* /usr/share/fonts/truetype/
fc-cache -f -v




