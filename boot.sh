#!/bin/bash

set -euo pipefail
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'
readonly SCRIPT_NAME="boot.sh"
readonly REPO_URL="https://github.com/leonardotrapani/os.git"
readonly OMARCHY_REPO="https://github.com/leonardotrapani/omarchy.git"
readonly INSTALL_DIR="$HOME/.local/share/trapani-os"
readonly OMARCHY_DIR="$HOME/.local/share/omarchy"
readonly BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
OMARCHY_BARE="${OMARCHY_BARE:-false}"

readonly CONFIGS=("aws" "bash" "git" "hypr" "nvim" "tmux")

# Initialize arrays to prevent unbound variable errors
AVAILABLE_SCRIPTS=()
SELECTED_SCRIPTS=()
ansi_art='
    ███        ▄████████    ▄████████    ▄███████▄    ▄████████ ███▄▄▄▄    ▄█  
▀█████████▄   ███    ███   ███    ███   ███    ███   ███    ███ ███▀▀▀██▄ ███  
   ▀███▀▀██   ███    ███   ███    ███   ███    ███   ███    ███ ███   ███ ███▌ 
    ███   ▀  ▄███▄▄▄▄██▀   ███    ███   ███    ███   ███    ███ ███   ███ ███▌ 
    ███     ▀▀███▀▀▀▀▀   ▀███████████ ▀█████████▀  ▀███████████ ███   ███ ███▌ 
    ███     ▀███████████   ███    ███   ███          ███    ███ ███   ███ ███  
    ███       ███    ███   ███    ███   ███          ███    ███ ███   ███ ███  
   ▄████▀     ███    ███   ███    █▀   ▄████▀        ███    █▀   ▀█   █▀  █▀   
              ███    ███                                                       '
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_header() {
    echo -e "\n${BOLD}${BLUE}━━━ $1 ━━━${NC}\n"
}
show_progress() {
    local msg="$1"
    echo -ne "${YELLOW}⏳${NC} $msg..."
}

show_done() {
    echo -e " ${GREEN}✓${NC}"
}

show_failed() {
    echo -e " ${RED}✗${NC}"
}
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Installation failed! Check the logs above for details."
        if [[ -d "$BACKUP_DIR" ]] && [[ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
            log_info "Your original configurations have been backed up to: $BACKUP_DIR"
        fi
    fi
    exit $exit_code
}

trap cleanup EXIT

discover_scripts() {
    local scripts_dir="$INSTALL_DIR/scripts"
    AVAILABLE_SCRIPTS=()
    
    if [[ -d "$scripts_dir" ]]; then
        while IFS= read -r -d '' script; do
            if [[ -f "$script" ]]; then
                local script_name=$(basename "$script" .sh)
                AVAILABLE_SCRIPTS+=("$script_name")
            fi
        done < <(find "$scripts_dir" -name "*.sh" -type f -print0)
    fi
}

check_system() {
    log_header "System Compatibility Check"
    if ! command -v pacman &> /dev/null; then
        log_error "This script requires Arch Linux or an Arch-based distribution"
        exit 1
    fi
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
    
    log_success "System compatibility verified"
}
install_dependencies() {
    log_header "Installing Dependencies"
    
    local deps=("git" "stow")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_info "Installing missing dependencies: ${missing_deps[*]}"
        if sudo pacman -Sy --noconfirm --needed "${missing_deps[@]}"; then
            log_success "Dependencies installed successfully"
        else
            log_error "Failed to install dependencies"
            exit 1
        fi
    else
        log_success "All dependencies already installed"
    fi
}
setup_configurations() {
    log_header "Setting Up All Configurations"
    log_info "Installing all available configurations: ${CONFIGS[*]}"
    echo
}

setup_scripts() {
    discover_scripts
    
    if [[ ${#AVAILABLE_SCRIPTS[@]} -eq 0 ]]; then
        log_info "No additional scripts found to run"
        SELECTED_SCRIPTS=()
        return
    fi
    
    log_header "Setting Up All Scripts"
    log_info "Running all available scripts: ${AVAILABLE_SCRIPTS[*]}"
    SELECTED_SCRIPTS=("${AVAILABLE_SCRIPTS[@]}")
    echo
}

backup_configs() {
    log_header "Backing Up Existing Configurations"
    
    local backed_up=false
    
    for config in "${CONFIGS[@]}"; do
        local config_paths=()
        
        case "$config" in
            "aws")
                [[ -d "$HOME/.aws" ]] && config_paths+=("$HOME/.aws")
                ;;
            "bash")
                [[ -f "$HOME/.bashrc" ]] && config_paths+=("$HOME/.bashrc")
                [[ -f "$HOME/.bash_profile" ]] && config_paths+=("$HOME/.bash_profile")
                ;;
            "git")
                [[ -f "$HOME/.gitconfig" ]] && config_paths+=("$HOME/.gitconfig")
                ;;
            "hypr")
                [[ -d "$HOME/.config/hypr" ]] && config_paths+=("$HOME/.config/hypr")
                ;;
            "nvim")
                [[ -d "$HOME/.config/nvim" ]] && config_paths+=("$HOME/.config/nvim")
                ;;
            "tmux")
                [[ -d "$HOME/.config/tmux" ]] && config_paths+=("$HOME/.config/tmux")
                [[ -f "$HOME/.tmux.conf" ]] && config_paths+=("$HOME/.tmux.conf")
                ;;
        esac
        
        for path in "${config_paths[@]}"; do
            if [[ -e "$path" ]]; then
                if [[ ! -d "$BACKUP_DIR" ]]; then
                    mkdir -p "$BACKUP_DIR"
                fi
                
                show_progress "Backing up $(basename "$path")"
                if cp -r "$path" "$BACKUP_DIR/" 2>/dev/null; then
                    show_done
                    backed_up=true
                else
                    show_failed
                    log_warning "Failed to backup $path"
                fi
            fi
        done
    done
    
    if [[ "$backed_up" = true ]]; then
        log_success "Configurations backed up to: $BACKUP_DIR"
    else
        log_info "No existing configurations found to backup"
    fi
}
clone_repository() {
    log_header "Cloning Configuration Repository"
    
    if [[ -d "$INSTALL_DIR" ]]; then
        show_progress "Removing existing installation directory"
        rm -rf "$INSTALL_DIR"
        show_done
    fi
    
    show_progress "Cloning repository from $REPO_URL"
    if git clone "$REPO_URL" "$INSTALL_DIR" &> /dev/null; then
        show_done
        log_success "Repository cloned successfully"
    else
        show_failed
        log_error "Failed to clone repository"
        exit 1
    fi
}
install_configurations() {
    log_header "Installing Configurations"
    
    cd "$INSTALL_DIR"
    
    for config in "${CONFIGS[@]}"; do
        show_progress "Installing $config configuration"
        if stow "$config" &> /dev/null; then
            show_done
        else
            show_failed
            log_error "Failed to install $config configuration"
            exit 1
        fi
    done
    
    log_success "All configurations installed successfully"
}
install_omarchy() {
    log_header "Installing Omarchy Base System"
    
    echo -e "\nCloning Omarchy..."
    rm -rf "$OMARCHY_DIR"
    git clone "$OMARCHY_REPO" "$OMARCHY_DIR" >/dev/null
    
    # Use custom branch if instructed
    if [[ -n "${OMARCHY_REF:-}" ]]; then
        echo -e "\nUsing branch: $OMARCHY_REF"
        cd "$OMARCHY_DIR"
        git fetch origin "$OMARCHY_REF" && git checkout "$OMARCHY_REF"
        cd - >/dev/null
    fi
    
    echo -e "\nInstallation starting..."
    source "$OMARCHY_DIR/install.sh"
}

run_selected_scripts() {
    if [[ ${#SELECTED_SCRIPTS[@]} -eq 0 ]]; then
        return
    fi
    
    log_header "Running Selected Scripts"
    
    cd "$INSTALL_DIR"
    
    for script in "${SELECTED_SCRIPTS[@]}"; do
        local script_path="scripts/${script}.sh"
        if [[ -f "$script_path" ]]; then
            chmod +x "$script_path"
            log_info "Running $script script (output will be shown below)"
            echo -e "${YELLOW}--- Script $script Output ---${NC}"
            if bash "$script_path"; then
                echo -e "${YELLOW}--- End Script $script Output ---${NC}"
                log_success "Script $script completed successfully"
            else
                echo -e "${YELLOW}--- End Script $script Output ---${NC}"
                log_warning "Script $script failed but installation will continue"
            fi
        else
            log_warning "Script $script not found"
        fi
    done
    
    log_success "Script execution completed"
}

post_install() {
    log_header "Post-Installation Tasks"
    log_info "Bash configuration installed. Run 'source ~/.bashrc' or restart your terminal"
    log_info "Tmux configuration installed. Press 'prefix + I' in tmux to install plugins"
    log_info "Neovim configuration installed. LazyVim will auto-install plugins on first run"
    
    log_success "Installation completed successfully!"
    echo
    echo -e "${BOLD}${GREEN}🎉 Welcome to Trapani's OS Configuration! 🎉${NC}"
    echo
    echo -e "${WHITE}What's next:${NC}"
    echo -e "  ${CYAN}•${NC} Restart your terminal or run ${YELLOW}source ~/.bashrc${NC}"
    echo -e "  ${CYAN}•${NC} Launch your applications to see the new configurations"
    echo -e "  ${CYAN}•${NC} Check out the documentation for customization options"
    echo
    
    if [[ -d "$BACKUP_DIR" ]] && [[ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        echo -e "${WHITE}Your original configurations are backed up at:${NC}"
        echo -e "  ${YELLOW}$BACKUP_DIR${NC}"
        echo
    fi
}

main() {
    clear
    echo -e "${PURPLE}$ansi_art${NC}\n"
    echo -e "${BOLD}${WHITE}Trapani's OS Configuration Installer${NC}"
    
    check_system
    install_dependencies
    setup_configurations
    backup_configs
    clone_repository
    setup_scripts
    install_configurations
    install_omarchy
    run_selected_scripts
    post_install
}

if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
    main "$@"
fi
