# 🌟 Trapani's Dotfiles

A comprehensive dotfiles collection built on top of [omarchy](https://github.com/LeonardoTrapani/omarchy) - an opinionated Arch + Hyprland setup. These dotfiles extend and customize the omarchy base configuration with personal preferences and additional tools.

## 📦 What's Included

### 🖥️ **Desktop Environment**
- **Hyprland** - Modern Wayland compositor with custom keybindings and window rules
- **Hyprlock** - Screen locking with custom styling
- **Hypridle** - Idle management and auto-lock configuration

### 🛠️ **Development Tools**
- **Neovim** - LazyVim-based configuration with custom Lua modules
- **Git** - Comprehensive aliases and workflow optimizations
- **Tmux** - Feature-rich terminal multiplexer with plugins and custom layouts
- **Bash** - Enhanced shell with aliases, Starship prompt integration

### 🎨 **Theming & Customization**
- **Built on Omarchy** - Extends the opinionated Arch + Hyprland base setup
- **Multiple Themes** - Catppuccin, Nord, Tokyo Night, Gruvbox, Rose Pine, Kanagawa, Everforest, and more
- **Coordinated Styling** - Consistent colors across terminal, editor, and desktop
- **Personal Overrides** - Custom configurations on top of omarchy defaults

### ☁️ **Cloud & Tools**
- **AWS CLI** - Preconfigured settings and profiles

## 🚀 Installation

### Prerequisites
- **Arch Linux** (or Arch-based distribution)
- [Omarchy](https://github.com/LeonardoTrapani/omarchy) - The opinionated Arch + Hyprland setup (install first)
- [GNU Stow](https://www.gnu.org/software/stow/) for symlink management

### Quick Setup

1. **Install omarchy first:**
   ```bash
   # Clone and install the omarchy base setup
   git clone https://github.com/LeonardoTrapani/omarchy.git
   cd omarchy
   # Follow omarchy installation instructions to get base Arch + Hyprland setup
   ```

2. **Clone this dotfiles repository:**
   ```bash
   git clone https://github.com/yourusername/trapani-os.git ~/.dotfiles
   cd ~/.dotfiles
   ```

3. **Stow the configurations you want:**
   ```bash
   # Install all configurations
   stow aws bash git hypr nvim omarchy tmux

   # Or install selectively
   stow nvim tmux bash git
   ```

## 🚀 Automated Installation Script

**Next Step: Create a comprehensive installation script that automates the entire setup process.**

The planned installation script will:

1. **Check omarchy installation** - Verify the base Arch + Hyprland setup is installed
2. **Install dependencies** - Install additional packages needed for these dotfiles  
3. **Stow dotfiles** - Automatically symlink all configuration files using GNU Stow
4. **Apply personal configurations** - Layer personal configs over omarchy defaults
5. **Configure themes** - Set up theme selection and switching capabilities
6. **Shell integration** - Enhance bash/zsh with additional aliases and starship integration

### Planned Usage:
```bash
# One-command installation
curl -fsSL https://raw.githubusercontent.com/yourusername/trapani-os/main/install.sh | bash

# Or clone and run locally
git clone https://github.com/yourusername/trapani-os.git
cd trapani-os
./install.sh
```

### Script Features:
- **Interactive prompts** for customization options
- **Dependency checking** and automatic installation
- **Backup existing configs** before overwriting
- **Theme selection** during setup
- **Post-install verification** and troubleshooting
- **Rollback capability** if installation fails

## 📂 Configuration Details

### **Bash** (`bash/`)
- Custom aliases for common commands (`v` for nvim, `g` for git, etc.)
- Starship prompt integration
- Omarchy bash configuration sourcing
- Pyenv setup and PATH configuration

### **Git** (`git/`)
- User configuration (name and email)
- Useful aliases: `st`, `br`, `ps`, `pl`, `c`, `a`, `hist`, `llog`
- Git LFS support
- Neovim as default editor

### **Hyprland** (`hypr/`)
- **Main config** - Sources omarchy defaults with personal overrides
- **Monitor setup** - Separate `monitors.conf` for portability
- **Lock screen** - Custom hyprlock configuration
- **Idle management** - Auto-lock and power management
- **Keybindings** - Terminal, browser, file manager, and media controls

### **Neovim** (`nvim/`)
- **LazyVim** - Based on the popular Neovim distribution
- **Custom Lua modules** - Personal configurations in `lua/trapani/`
- **Plugin management** - Lazy.nvim with locked versions
- **Theme integration** - Works with omarchy theme system

### **Tmux** (`tmux/`)
- **Rich plugin ecosystem** - TPM with curated plugins
- **Custom layouts** - Predefined session layouts for different workflows
- **Theme integration** - Multiple theme options matching omarchy
- **Enhanced navigation** - Vim-style pane navigation
- **Productivity features** - Session management, URL handling, copy/paste improvements

### **Omarchy Extensions** (`omarchy/`)
- **Theme Configurations** - Multiple color schemes (Catppuccin, Nord, Tokyo Night, etc.)
- **Personal Overrides** - Custom theme files that extend omarchy's base setup
- **Theme Switching** - Easy switching between different color schemes
- **Application Integration** - Coordinated theming for Hyprland, Tmux, Neovim, and terminal

## 🎯 Key Features

- **🔄 Unified Theming** - Single theme change affects all applications
- **⚡ Performance Optimized** - Lightweight configurations focused on speed
- **🛠️ Developer Friendly** - Optimized for coding workflows and productivity
- **🎨 Aesthetic Focus** - Clean, modern appearance across all components
- **📱 Modular Design** - Use only what you need via selective stowing

## 🔧 Customization

### Adding New Themes
Create additional themes that work with the omarchy base setup by adding theme configs:
```bash
# Create a new theme extension
mkdir -p omarchy/.config/omarchy/themes/mytheme
# Add theme-specific configs (tmux.conf, neovim.lua, hyprland.conf, etc.)
# These extend/override omarchy's default theming
```

### Personal Overrides
- **Hyprland**: Edit `hypr/.config/hypr/monitors.conf` for display setup
- **Bash**: Add personal aliases to `bash/.bashrc`
- **Git**: Update user information in `git/.gitconfig`
- **Tmux**: Add custom layouts to `tmux/.config/tmux/layouts/`

## 🤝 Related Projects

- **[Omarchy](https://github.com/LeonardoTrapani/omarchy)** - The theme management system powering this setup

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Built for productivity, designed for aesthetics* ✨
