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

readonly CONFIGS=("aws" "bash" "git" "hypr" "nvim" "tmux")
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
        show_progress "Installing missing dependencies: ${missing_deps[*]}"
        if sudo pacman -Sy --noconfirm --needed "${missing_deps[@]}" &> /dev/null; then
            show_done
        else
            show_failed
            log_error "Failed to install dependencies"
            exit 1
        fi
    else
        log_success "All dependencies already installed"
    fi
}
select_configurations() {
    log_header "Configuration Selection"
    
    echo -e "${WHITE}Available configurations:${NC}"
    echo
    
    for i in "${!CONFIGS[@]}"; do
        local config="${CONFIGS[$i]}"
        local desc=""
        case "$config" in
            "aws") desc="AWS CLI configuration and profiles" ;;
            "bash") desc="Enhanced shell with aliases and Starship prompt" ;;
            "git") desc="Git aliases and workflow optimizations" ;;
            "hypr") desc="Hyprland window manager configuration" ;;
            "nvim") desc="LazyVim-based Neovim configuration" ;;
            "tmux") desc="Feature-rich terminal multiplexer setup" ;;
        esac
        printf "${CYAN}%2d${NC}) ${BOLD}%-8s${NC} - %s\n" $((i+1)) "$config" "$desc"
    done
    
    echo
    echo -e "${CYAN} a${NC}) ${BOLD}All configurations${NC}"
    echo -e "${CYAN} q${NC}) ${BOLD}Quit${NC}"
    echo
    
    local selected_configs=()
    
    while true; do
        echo -ne "${WHITE}Select configurations${NC} (comma-separated numbers, 'a' for all, 'q' to quit): "
        read -r selection
        
        case "$selection" in
            "q"|"Q") 
                log_info "Installation cancelled by user"
                exit 0
                ;;
            "a"|"A")
                selected_configs=("${CONFIGS[@]}")
                break
                ;;
            *) 
                IFS=',' read -ra ADDR <<< "$selection"
                selected_configs=()
                local valid=true
                
                for i in "${ADDR[@]}"; do
                    i=$(echo "$i" | xargs)
                    if [[ "$i" =~ ^[0-9]+$ ]] && [[ $i -ge 1 ]] && [[ $i -le ${#CONFIGS[@]} ]]; then
                        selected_configs+=("${CONFIGS[$((i-1))]}")
                    else
                        log_error "Invalid selection: $i"
                        valid=false
                        break
                    fi
                done
                
                if [[ "$valid" = true ]] && [[ ${#selected_configs[@]} -gt 0 ]]; then
                    break
                fi
                ;;
        esac
    done
    
    echo
    log_info "Selected configurations: ${selected_configs[*]}"
    echo
    SELECTED_CONFIGS=("${selected_configs[@]}")
}

select_scripts() {
    discover_scripts
    
    if [[ ${#AVAILABLE_SCRIPTS[@]} -eq 0 ]]; then
        log_info "No additional scripts found to run"
        SELECTED_SCRIPTS=()
        return
    fi
    
    log_header "Additional Scripts Selection"
    
    echo -e "${WHITE}Available scripts:${NC}"
    echo
    
    for i in "${!AVAILABLE_SCRIPTS[@]}"; do
        local script="${AVAILABLE_SCRIPTS[$i]}"
        local desc=""
        case "$script" in
            "ssh") desc="Configure SSH to use 1Password identity agent" ;;
            *) desc="Custom script: $script" ;;
        esac
        printf "${CYAN}%2d${NC}) ${BOLD}%-8s${NC} - %s\n" $((i+1)) "$script" "$desc"
    done
    
    echo
    echo -e "${CYAN} a${NC}) ${BOLD}All scripts${NC}"
    echo -e "${CYAN} n${NC}) ${BOLD}No scripts${NC}"
    echo
    
    local selected_scripts=()
    
    while true; do
        echo -ne "${WHITE}Select scripts to run${NC} (comma-separated numbers, 'a' for all, 'n' for none): "
        read -r selection
        
        case "$selection" in
            "n"|"N")
                selected_scripts=()
                break
                ;;
            "a"|"A")
                selected_scripts=("${AVAILABLE_SCRIPTS[@]}")
                break
                ;;
            *) 
                IFS=',' read -ra ADDR <<< "$selection"
                selected_scripts=()
                local valid=true
                
                for i in "${ADDR[@]}"; do
                    i=$(echo "$i" | xargs)
                    if [[ "$i" =~ ^[0-9]+$ ]] && [[ $i -ge 1 ]] && [[ $i -le ${#AVAILABLE_SCRIPTS[@]} ]]; then
                        selected_scripts+=("${AVAILABLE_SCRIPTS[$((i-1))]}")
                    else
                        log_error "Invalid selection: $i"
                        valid=false
                        break
                    fi
                done
                
                if [[ "$valid" = true ]]; then
                    break
                fi
                ;;
        esac
    done
    
    echo
    if [[ ${#selected_scripts[@]} -gt 0 ]]; then
        log_info "Selected scripts: ${selected_scripts[*]}"
    else
        log_info "No scripts selected"
    fi
    echo
    SELECTED_SCRIPTS=("${selected_scripts[@]}")
}

backup_configs() {
    log_header "Backing Up Existing Configurations"
    
    local backed_up=false
    
    for config in "${SELECTED_CONFIGS[@]}"; do
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
    
    for config in "${SELECTED_CONFIGS[@]}"; do
        show_progress "Installing $config configuration"
        if stow "$config" &> /dev/null; then
            show_done
        else
            show_failed
            log_error "Failed to install $config configuration"
            exit 1
        fi
    done
    
    log_success "All selected configurations installed successfully"
}
install_omarchy() {
    log_header "Installing Omarchy Base System"
    if [[ -d "$OMARCHY_DIR" ]]; then
        show_progress "Removing existing Omarchy installation"
        rm -rf "$OMARCHY_DIR"
        show_done
    fi
    
    show_progress "Cloning Omarchy repository"
    if git clone "$OMARCHY_REPO" "$OMARCHY_DIR" &> /dev/null; then
        show_done
    else
        show_failed
        log_error "Failed to clone Omarchy repository"
        exit 1
    fi
    if [[ -n "${OMARCHY_REF:-}" ]]; then
        log_info "Using Omarchy branch: $OMARCHY_REF"
        cd "$OMARCHY_DIR"
        if git fetch origin "$OMARCHY_REF" && git checkout "$OMARCHY_REF" &> /dev/null; then
            log_success "Switched to branch $OMARCHY_REF"
        else
            log_warning "Failed to switch to branch $OMARCHY_REF, using default"
        fi
        cd - > /dev/null
    fi
    
    show_progress "Running Omarchy installation script"
    if source "$OMARCHY_DIR/install.sh" &> /dev/null; then
        show_done
        log_success "Omarchy installed successfully"
    else
        show_failed
        log_error "Omarchy installation failed"
        exit 1
    fi
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
            show_progress "Running $script script"
            if bash "$script_path" &> /dev/null; then
                show_done
            else
                show_failed
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
    if [[ " ${SELECTED_CONFIGS[*]} " =~ " bash " ]]; then
        log_info "Bash configuration installed. Run 'source ~/.bashrc' or restart your terminal"
    fi
    if [[ " ${SELECTED_CONFIGS[*]} " =~ " tmux " ]]; then
        log_info "Tmux configuration installed. Press 'prefix + I' in tmux to install plugins"
    fi
    if [[ " ${SELECTED_CONFIGS[*]} " =~ " nvim " ]]; then
        log_info "Neovim configuration installed. LazyVim will auto-install plugins on first run"
    fi
    
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
    select_configurations
    backup_configs
    clone_repository
    select_scripts
    install_configurations
    install_omarchy
    run_selected_scripts
    post_install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
