#!/usr/bin/env bash
# voltdots — install.sh
# Creates symlinks from ~/.voltdots to ~/.config
# Safe to run multiple times — existing symlinks are updated

DOTFILES="$HOME/.voltdots"
CONFIG="$HOME/.config"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[info]${NC} $1"; }
success() { echo -e "${GREEN}[ok]${NC} $1"; }
warning() { echo -e "${YELLOW}[warn]${NC} $1"; }
error()   { echo -e "${RED}[error]${NC} $1"; }

# --- Create symlink ---
link() {
    local src="$1"
    local dst="$2"

    # Create parent dir if needed
    mkdir -p "$(dirname "$dst")"

    if [[ -L "$dst" ]]; then
        rm "$dst"
    elif [[ -e "$dst" ]]; then
        warning "Backing up existing $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi

    ln -s "$src" "$dst"
    success "Linked $dst → $src"
}

# --- Create custom dirs if not exist ---
init_custom() {
    info "Initializing custom dirs..."

    local dirs=(
        "$DOTFILES/hypr/custom"
        "$DOTFILES/waybar/custom"
        "$DOTFILES/rofi/custom"
        "$DOTFILES/swaync/custom"
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            success "Created $dir"
        fi
    done

    # Create empty custom files if not exist
    local custom_files=(
        "$DOTFILES/hypr/custom/env.conf"
        "$DOTFILES/hypr/custom/monitors.conf"
        "$DOTFILES/hypr/custom/keybinds.conf"
        "$DOTFILES/hypr/custom/rules.conf"
        "$DOTFILES/hypr/custom/execs.conf"
        "$DOTFILES/hypr/custom/defaults.conf"
    )

    for file in "${custom_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "# Machine-specific override — $(basename "$file")" > "$file"
            success "Created empty $file"
        fi
    done
}

# --- Symlinks ---
create_links() {
    info "Creating symlinks..."

    link "$DOTFILES/hypr/default/hyprland.conf" "$CONFIG/hypr/hyprland.conf"
    link "$DOTFILES/waybar/default"              "$CONFIG/waybar"
    link "$DOTFILES/rofi/default"                "$CONFIG/rofi"
    link "$DOTFILES/swaync/default"              "$CONFIG/swaync"
    link "$DOTFILES/hyprlock/hyprlock.conf"      "$CONFIG/hypr/hyprlock.conf"
    link "$DOTFILES/hypridle/hypridle.conf"      "$CONFIG/hypr/hypridle.conf"
    link "$DOTFILES/swayosd"                     "$CONFIG/swayosd"
    link "$DOTFILES/matugen"                     "$CONFIG/matugen"
}

# --- Make scripts executable ---
make_executable() {
    info "Setting script permissions..."
    chmod +x "$DOTFILES/scripts/"*.sh
    success "Scripts are executable"
}

# --- Main ---
echo -e "${BLUE}"
echo "  ██╗   ██╗ ██████╗ ██╗  ████████╗██████╗  ██████╗ ████████╗███████╗"
echo "  ██║   ██║██╔═══██╗██║  ╚══██╔══╝██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝"
echo "  ██║   ██║██║   ██║██║     ██║   ██║  ██║██║   ██║   ██║   ███████╗"
echo "  ╚██╗ ██╔╝██║   ██║██║     ██║   ██║  ██║██║   ██║   ██║   ╚════██║"
echo "   ╚████╔╝ ╚██████╔╝███████╗██║   ██████╔╝╚██████╔╝   ██║   ███████║"
echo "    ╚═══╝   ╚═════╝ ╚══════╝╚═╝   ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝"
echo -e "${NC}"
echo "  BKPView theme — Hyprland vanilla dotfiles"
echo ""

init_custom
create_links
make_executable

echo ""
success "voltdots installed successfully!"
info "Next steps:"
echo "  1. Edit ~/.voltdots/hypr/custom/monitors.conf for your display setup"
echo "  2. Edit ~/.voltdots/hypr/custom/defaults.conf for your preferred apps"
echo "  3. Edit ~/.voltdots/hypr/custom/env.conf for machine-specific env vars"
echo "  4. Add wallpapers to ~/Pictures/Wallpapers"
echo "  5. Restart Hyprland"
