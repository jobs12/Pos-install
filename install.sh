#!/bin/bash
# Script de pós-instalação para Ubuntu
# Autor: Joab
# Data: 2026-01-06

set -euxo pipefail  # encerra se algum comando falhar e mostra os comandos

echo "🚀 Iniciando pós-instalação..."

# -----------------------------
# 1. Atualizar sistema e instalar pacotes via APT
# -----------------------------
echo "📦 Instalando pacotes básicos via APT..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  git \
  nodejs \
  python3 \
  gnome-tweaks \
  flatpak \
  qbittorrent \
  wget \
  curl \
  zsh \
  snapd \
  gnome-themes-extra

# -----------------------------
# 2. Configurar Flathub e instalar apps Flatpak
# -----------------------------
echo "📦 Adicionando Flathub e instalando Flatpaks..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub -y \
  org.libreoffice.LibreOffice \
  com.bitwarden.desktop \
  org.qbittorrent.qBittorrent \
  org.gimp.GIMP \
  org.inkscape.Inkscape \
  org.kde.krita \
  org.darktable.Darktable \
  com.valvesoftware.Steam \
  net.lutris.Lutris \
  com.brave.Browser \
  io.gitlab.librewolf-community \
  org.torproject.torbrowser-launcher \
  com.google.Chrome \
  com.discordapp.Discord \
  org.telegram.desktop \
  com.visualstudio.code \
  md.obsidian.Obsidian \
  com.calibre_ebook.calibre \
  io.github.antimicrox.antimicrox

# -----------------------------
# 3. Instalar Pear Desktop (AppImage)
# -----------------------------
echo "🖥️ Instalando Pear Desktop v3.11.0..."

CURRENT_USER="${SUDO_USER:-$USER}"
USER_HOME="$(eval echo ~"$CURRENT_USER")"

mkdir -p "${USER_HOME}/Applications"

curl -fL \
  -o "${USER_HOME}/Applications/pear-desktop-v3.11.0-x86_64.AppImage" \
  "https://github.com/pear-devs/pear-desktop/releases/download/v3.11.0/pear-desktop-v3.11.0-x86_64.AppImage"

chmod +x "${USER_HOME}/Applications/pear-desktop-v3.11.0-x86_64.AppImage"
sudo ln -sf "${USER_HOME}/Applications/pear-desktop-v3.11.0-x86_64.AppImage" /usr/local/bin/pear-desktop
sudo chown -R "${CURRENT_USER}:${CURRENT_USER}" "${USER_HOME}/Applications"

echo "✅ Pear Desktop instalado! Rode com: pear-desktop"

# -----------------------------
# 4. Instalar Pomotroid (Snap)
# -----------------------------
echo "⏱️ Instalando Pomotroid via Snap..."

sudo systemctl enable --now snapd.socket snapd.service || true
sudo snap wait system seed.loaded || true
sudo snap install pomotroid

echo "✅ Pomotroid instalado! Rode com: pomotroid"

# -----------------------------
# 5. Instalar e aplicar tema Flat-Remix GTK Black
# -----------------------------
echo "🌑 Instalando tema Flat-Remix GTK Black..."

wget -O /tmp/flat-remix-gtk.tar.gz https://github.com/daniruiz/flat-remix-gtk/archive/refs/tags/20220115.tar.gz
tar -xvf /tmp/flat-remix-gtk.tar.gz -C /tmp
mkdir -p ~/.themes
mv /tmp/flat-remix-gtk-20220115 ~/.themes/Flat-Remix-GTK-Black

gsettings set org.gnome.desktop.interface gtk-theme 'Flat-Remix-GTK-Black'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo "✅ Tema Flat-Remix GTK Black aplicado no Ubuntu."

# -----------------------------
# 6. Instalar tema FF-ULTIMA no Firefox
# -----------------------------
echo "🌑 Instalando tema FF-ULTIMA para Firefox..."

git clone https://github.com/soulhotel/FF-ULTIMA.git /tmp/FF-ULTIMA

FIREFOX_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default*" | head -n 1)

if [ -n "$FIREFOX_PROFILE" ]; then
  mkdir -p "$FIREFOX_PROFILE/chrome"
  cp -r /tmp/FF-ULTIMA/* "$FIREFOX_PROFILE/chrome/"
  echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$FIREFOX_PROFILE/user.js"
  echo "✅ Tema FF-ULTIMA instalado no Firefox!"
else
  echo "⚠️ Não foi possível encontrar o perfil do Firefox."
fi

# -----------------------------
# 7. Atualizar Flatpak e Snap apps
# -----------------------------
echo "🔄 Atualizando Flatpak e Snap apps..."
flatpak update -y
sudo snap refresh

# -----------------------------
# 8. Instalar Oh My Zsh (não-interativo)
# -----------------------------
echo "💻 Instalando Oh My Zsh..."
export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "✅ Pós-instalação concluída!"
echo "👉 Reinicie o sistema para aplicar todas as mudanças."

