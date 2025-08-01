```bash
wget -qO- https://os.trapani.sh | bash
```

# Trapani's OS Configuration

A meticulously crafted dotfiles ecosystem built on GNU Stow and seamlessly integrated with [Omarchy](https://github.com/leonardotrapani/omarchy) - delivering a cohesive, high-performance development environment for Arch Linux.

## Architecture Overview

This configuration system employs a modular architecture using GNU Stow for symlink management, enabling atomic installation and removal of configuration modules. Each configuration is self-contained within its own directory, following XDG Base Directory specifications where applicable.

```
├── aws/           # AWS CLI profiles and configuration
├── bash/          # Shell configuration with Starship integration
├── git/           # Git workflow optimizations and aliases
├── hypr/          # Hyprland compositor configuration
├── nvim/          # LazyVim-based Neovim setup
├── tmux/          # Terminal multiplexer with plugin ecosystem
├── scripts/       # Additional utility scripts
└── boot.sh       # Automated installation orchestrator
```

## Technical Stack

- **Configuration Management**: GNU Stow for atomic symlink operations
- **Base System**: Omarchy (Arch Linux + Hyprland + coordinated theming)
- **Editor**: Neovim with LazyVim framework and Lua-based configuration
- **Terminal Multiplexer**: Tmux with TPM plugin management
- **Shell**: Bash with Starship prompt and performance optimizations
- **Version Control**: Git with workflow-optimized aliases and LFS support
- **Window Manager**: Hyprland with custom keybindings and monitor configurations

## Installation Methods

### Primary Installation (Recommended)

```bash
wget -qO- https://os.trapani.sh | bash
```

### Alternative Methods

```bash
# Using curl
curl -fsSL https://os.trapani.sh | bash

# Local installation
git clone https://github.com/leonardotrapani/os.git
cd os
./boot.sh
```

### Installation Features

The `boot.sh` installer provides:

- **Automatic Installation** - Installs all available configurations and scripts automatically
- **Dependency Resolution** - Automatic installation of required packages via pacman
- **Configuration Backup** - Automatic backup of existing dotfiles with timestamps
- **Omarchy Integration** - Seamless installation of the base Arch + Hyprland system
- **Error Recovery** - Comprehensive error handling with rollback capabilities
- **Progress Visualization** - Real-time installation progress with colored output

### Advanced Installation Options

```bash
# Install with custom Omarchy branch
OMARCHY_REF=custom-branch wget -qO- https://os.trapani.sh | bash

# Environment variables for customization
export OMARCHY_REF="develop"        # Use specific Omarchy branch
export INSTALL_DIR="$HOME/dotfiles" # Custom installation directory
```

## Configuration Modules

### Bash (`bash/`)

Advanced shell configuration featuring:

- **Performance Optimizations** - Lazy loading of expensive operations
- **Starship Prompt Integration** - Git-aware, customizable prompt
- **Intelligent Aliases** - Context-aware shortcuts and workflow enhancements
- **Pyenv Integration** - Python version management with PATH optimization

**Key Files:**

- `.bashrc` - Main configuration with omarchy sourcing
- `.bash_profile` - Login shell initialization

### Git (`git/`)

Workflow-optimized Git configuration:

- **Productivity Aliases** - `st` (status), `br` (branch), `ps` (push), `pl` (pull)
- **Advanced Aliases** - `hist` (formatted history), `llog` (graph log)
- **LFS Support** - Large file storage configuration
- **Editor Integration** - Neovim as default editor with diff tools

**Aliases Overview:**

```bash
git st    # git status
git c     # git commit
git a     # git add
git br    # git branch
git hist  # formatted commit history
```

### Hyprland (`hypr/`)

Modern Wayland compositor configuration:

- **Modular Architecture** - Separate monitor configuration for portability
- **Custom Keybindings** - Optimized for development workflows
- **Lock Screen Integration** - Hyprlock with custom styling
- **Idle Management** - Hypridle for power management
- **Omarchy Theme Integration** - Coordinated theming system

**Configuration Structure:**

- `hyprland.conf` - Main configuration sourcing omarchy defaults
- `monitors.conf` - Portable monitor setup
- `hyprlock.conf` - Lock screen styling
- `hypridle.conf` - Idle management rules

### Neovim (`nvim/`)

LazyVim-based configuration with custom extensions:

- **LazyVim Framework** - Modern plugin management and sensible defaults
- **Custom Lua Modules** - Personal configurations in `lua/trapani/`
- **Performance Tuned** - Lazy loading and optimized startup times
- **Theme Integration** - Synchronized with omarchy theme system
- **Language Support** - LSP, treesitter, and formatter configurations

**Architecture:**

```
.config/nvim/
├── init.lua              # Entry point
├── lua/config/           # LazyVim configuration
└── lua/trapani/          # Personal customizations
```

### Tmux (`tmux/`)

Feature-rich terminal multiplexer setup:

- **Plugin Ecosystem** - Curated plugins via TPM (Tmux Plugin Manager)
- **Custom Layouts** - Predefined session layouts for different workflows
- **Vim Integration** - Seamless pane navigation with vim keybindings
- **Theme Coordination** - Multiple themes matching omarchy system
- **Productivity Features** - URL handling, enhanced copy/paste, session management

**Plugin Stack:**

- `tmux-sensible` - Sensible default configurations
- `tmux-yank` - Enhanced clipboard integration
- Custom themes with omarchy coordination

### AWS (`aws/`)

AWS CLI configuration for cloud development:

- **Profile Management** - Multiple AWS profiles for different environments
- **CLI Optimizations** - Enhanced output formatting and shortcuts
- **Integration Ready** - Compatible with AWS development workflows

### Scripts (`scripts/`)

Additional utility scripts that can be optionally installed:

- **SSH Configuration** - Sets up 1Password identity agent integration
- **Extensible** - Easy to add custom automation scripts

## System Integration

### Automated Installation Process

The installation script automatically:

1. **Installs All Configurations** - No user interaction required for selection
2. **Runs All Available Scripts** - Executes any utility scripts found in the scripts/ directory
3. **Handles Dependencies** - Automatically installs git, stow, and other requirements
4. **Manages Backups** - Creates timestamped backups of existing configurations

### Omarchy Integration

This configuration system extends Omarchy's base setup:

1. **Theme Coordination** - All configurations respect omarchy's theme system
2. **Non-Conflicting** - Designed to layer over omarchy without conflicts
3. **Base Dependency** - Requires omarchy for full functionality
4. **Automatic Installation** - `boot.sh` handles omarchy setup automatically

### Stow Management

GNU Stow creates symbolic links from the configuration directories to their target locations:

```bash
# Manual stow operations
stow nvim     # Links nvim/.config/nvim -> ~/.config/nvim
stow tmux     # Links tmux/.config/tmux -> ~/.config/tmux
stow bash     # Links bash/.bashrc -> ~/.bashrc

# Remove configurations
stow -D nvim  # Removes nvim symlinks
```

### Backup and Recovery

The installation system automatically creates timestamped backups:

```
~/.config-backup-20240801-143022/
├── .bashrc           # Original bash configuration
├── .config/nvim/     # Original neovim setup
└── .config/tmux/     # Original tmux configuration
```

## Customization

### Adding Custom Configurations

1. Create a new directory following stow conventions:

```bash
mkdir -p custom/.config/custom
echo "# Custom config" > custom/.config/custom/config.conf
```

2. Install using stow:

```bash
stow custom
```

### Theme Customization

Themes are managed through the omarchy integration. Custom themes can be added by:

1. Creating theme files in the omarchy theme directory
2. Extending configurations in each module to support the new theme
3. Using omarchy's theme switching mechanism

### Per-Module Customization

Each configuration module can be customized independently:

- **Hyprland**: Edit `monitors.conf` for display-specific settings
- **Bash**: Add personal aliases to `.bashrc`
- **Git**: Update user information in `.gitconfig`
- **Tmux**: Add custom layouts in `.config/tmux/layouts/`

## Requirements

- **Operating System**: Arch Linux or Arch-based distribution
- **Package Manager**: pacman
- **Dependencies**: git, stow (automatically installed)
- **Base System**: Omarchy (automatically installed)
- **Privileges**: sudo access for package installation

## Security Considerations

- All configurations follow security best practices
- No hardcoded credentials or sensitive information
- Automatic backup system prevents data loss
- Modular installation allows minimal surface area
- Open source and auditable codebase

## Contributing

This is a personal dotfiles repository, but contributions are welcome:

1. Fork the repository
2. Create a feature branch
3. Test configurations in a clean environment
4. Submit a pull request with detailed description

## License

MIT License - see [LICENSE](LICENSE) for details.

---

_Engineered for performance, designed for productivity_ ⚡
