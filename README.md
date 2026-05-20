# voltdots
Hyprland vanilla dotfiles — BKPView theme

---

## Dependencies

### Arch

```bash
# Core
sudo pacman -S hyprland waybar rofi-wayland swaync swww \
    hyprlock hypridle swayosd

# Capture
sudo pacman -S grim slurp wl-clipboard cliphist
yay -S gpu-screen-recorder
#or  you can install an use auro https://github/wypifu/auro.git
auro -S gpu-screen-recorder

# Apps
sudo pacman -S thunar nautilus firefox \
    fcitx5 fcitx5-gtk fcitx5-qt \
    blueman network-manager-applet \
    polkit-gnome celluloid zathura \
    loupe gthumb

# Fonts & icons
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts \
    papirus-icon-theme

# CLI tools
sudo pacman -S jq curl brightnessctl playerctl \
    libnotify

# Optional
sudo pacman -S codium neovim ghostty foot
```

### Notes
- `gpu-screen-recorder` — AUR, required for AMD/Nvidia screen recording
- `ghostty` — AUR
- `codium` — AUR
- `yandex-browser` — AUR
