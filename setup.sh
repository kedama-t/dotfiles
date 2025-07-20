#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

DRY_RUN=false
FORCE=false
MINIMAL=false

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
    exit 1
}

warning() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $*" >&2
}

info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*"
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian)
                    echo "debian"
                    ;;
                centos|rhel|fedora)
                    echo "rhel"
                    ;;
                *)
                    echo "linux"
                    ;;
            esac
        else
            echo "linux"
        fi
    else
        error "Unsupported OS: $OSTYPE"
    fi
}

detect_package_manager() {
    local os="$1"
    
    case "$os" in
        macos)
            echo "brew"
            ;;
        debian)
            echo "apt"
            ;;
        rhel)
            if command -v dnf &> /dev/null; then
                echo "dnf"
            elif command -v yum &> /dev/null; then
                echo "yum"
            else
                error "No package manager found"
            fi
            ;;
        *)
            error "Unsupported OS for package manager detection: $os"
            ;;
    esac
}

command_exists() {
    command -v "$1" &> /dev/null
}

create_backup() {
    local file="$1"
    if [ -e "$file" ] && [ ! -e "${file}.backup" ]; then
        if [ "$DRY_RUN" = true ]; then
            info "Would backup: $file -> ${file}.backup"
        else
            info "Creating backup: $file -> ${file}.backup"
            cp -r "$file" "${file}.backup"
        fi
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ ! -e "$source" ]; then
        error "Source file does not exist: $source"
    fi
    
    local target_dir="$(dirname "$target")"
    if [ "$DRY_RUN" = true ]; then
        info "Would create directory: $target_dir"
        info "Would create symlink: $target -> $source"
        return
    fi
    
    mkdir -p "$target_dir"
    
    if [ -L "$target" ]; then
        if [ "$(readlink "$target")" = "$source" ]; then
            info "Symlink already exists: $target"
            return
        else
            warning "Removing existing symlink: $target"
            rm "$target"
        fi
    elif [ -e "$target" ]; then
        if [ "$FORCE" = true ]; then
            create_backup "$target"
            rm -rf "$target"
        else
            error "Target already exists (use --force to overwrite): $target"
        fi
    fi
    
    info "Creating symlink: $target -> $source"
    ln -s "$source" "$target"
}

install_essential_tools() {
    local os="$1"
    local pkg_manager="$2"
    
    info "Installing essential tools..."
    
    local essential_tools=("git" "curl" "wget" "unzip")
    
    for tool in "${essential_tools[@]}"; do
        if command_exists "$tool"; then
            info "$tool is already installed"
            continue
        fi
        
        if [ "$DRY_RUN" = true ]; then
            info "Would install: $tool"
            continue
        fi
        
        case "$pkg_manager" in
            brew)
                brew install "$tool"
                ;;
            apt)
                sudo apt update && sudo apt install -y "$tool"
                ;;
            dnf)
                sudo dnf install -y "$tool"
                ;;
            yum)
                sudo yum install -y "$tool"
                ;;
        esac
    done
}

install_dev_tools() {
    local os="$1"
    local pkg_manager="$2"
    
    info "Installing development tools..."
    
    install_neovim "$os" "$pkg_manager"
    install_go "$os" "$pkg_manager"
    setup_nodejs
    setup_python
    setup_claude_code
    install_eza "$os" "$pkg_manager"
}

install_neovim() {
    local os="$1"
    local pkg_manager="$2"
    
    if command_exists nvim; then
        local version=$(nvim --version | head -n1 | grep -o 'v[0-9]\+\.[0-9]\+')
        info "Neovim is already installed: $version"
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        info "Would install: Neovim"
        return
    fi
    
    case "$pkg_manager" in
        brew)
            brew install neovim
            ;;
        apt)
            sudo apt update && sudo apt install -y software-properties-common
            sudo add-apt-repository ppa:neovim-ppa/unstable -y
            sudo apt update && sudo apt install -y neovim
            ;;
        dnf)
            sudo dnf install -y neovim
            ;;
        yum)
            sudo yum install -y neovim
            ;;
    esac
}

install_go() {
    local os="$1"
    local pkg_manager="$2"
    
    if command_exists go; then
        local version=$(go version | grep -o 'go[0-9]\+\.[0-9]\+\.[0-9]\+')
        info "Go is already installed: $version"
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        info "Would install: Go"
        return
    fi
    
    case "$pkg_manager" in
        brew)
            brew install go
            ;;
        apt)
            sudo apt update && sudo apt install -y golang-go
            ;;
        dnf)
            sudo dnf install -y golang
            ;;
        yum)
            sudo yum install -y golang
            ;;
    esac
}

install_eza() {
    local os="$1"
    local pkg_manager="$2"
    
    if command_exists eza; then
        info "eza is already installed"
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        info "Would install: eza"
        return
    fi
    
    case "$pkg_manager" in
        brew)
            brew install eza
            ;;
        apt)
            sudo apt update && sudo apt install -y eza
            ;;
        dnf)
            sudo dnf install -y eza
            ;;
        yum)
            sudo yum install -y eza
            ;;
    esac
}

setup_nodejs() {
    if command_exists fnm; then
        info "fnm is already installed"
    else
        if [ "$DRY_RUN" = true ]; then
            info "Would install: fnm"
        else
            info "Installing fnm..."
            curl -fsSL https://fnm.vercel.app/install | bash
        fi
    fi
    
    if [ "$DRY_RUN" = false ]; then
        export PATH="$HOME/.local/share/fnm:$PATH"
        eval "$(fnm env --use-on-cd)"
        
        if ! fnm list | grep -q "lts"; then
            info "Installing Node.js LTS..."
            fnm install --lts
            fnm use lts-latest
        else
            info "Node.js LTS is already installed"
        fi
    fi
}

setup_python() {
    if command_exists uv; then
        info "uv is already installed"
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        info "Would install: uv"
        return
    fi
    
    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

setup_claude_code() {
    if command_exists claude; then
        info "Claude Code is already installed"
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        info "Would install: Claude Code"
        return
    fi
    
    if ! command_exists npm; then
        warning "npm not found. Please install Node.js first."
        return
    fi
    
    info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
}

setup_zsh() {
    local os="$1"
    local pkg_manager="$2"
    
    if ! command_exists zsh; then
        if [ "$DRY_RUN" = true ]; then
            info "Would install: zsh"
        else
            info "Installing zsh..."
            case "$pkg_manager" in
                brew)
                    brew install zsh
                    ;;
                apt)
                    sudo apt update && sudo apt install -y zsh
                    ;;
                dnf)
                    sudo dnf install -y zsh
                    ;;
                yum)
                    sudo yum install -y zsh
                    ;;
            esac
        fi
    else
        info "zsh is already installed"
    fi
    
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        if [ "$DRY_RUN" = true ]; then
            info "Would install: Oh My Zsh"
        else
            info "Installing Oh My Zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi
    else
        info "Oh My Zsh is already installed"
    fi
    
    local zsh_plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    if [ ! -d "$zsh_plugins_dir/zsh-autosuggestions" ]; then
        if [ "$DRY_RUN" = true ]; then
            info "Would install: zsh-autosuggestions"
        else
            info "Installing zsh-autosuggestions..."
            git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_plugins_dir/zsh-autosuggestions"
        fi
    else
        info "zsh-autosuggestions is already installed"
    fi
    
    if [ ! -d "$zsh_plugins_dir/zsh-syntax-highlighting" ]; then
        if [ "$DRY_RUN" = true ]; then
            info "Would install: zsh-syntax-highlighting"
        else
            info "Installing zsh-syntax-highlighting..."
            git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_plugins_dir/zsh-syntax-highlighting"
        fi
    else
        info "zsh-syntax-highlighting is already installed"
    fi
    
    if [ "$(basename "$SHELL")" != "zsh" ]; then
        if [ "$DRY_RUN" = true ]; then
            info "Would change default shell to zsh"
        else
            info "Changing default shell to zsh..."
            chsh -s "$(which zsh)"
        fi
    else
        info "Default shell is already zsh"
    fi
}

setup_neovim() {
    local nvim_config_dir="$HOME/.config/nvim"
    
    if [ ! -d "$HOME/.config" ]; then
        if [ "$DRY_RUN" = true ]; then
            info "Would create directory: $HOME/.config"
        else
            mkdir -p "$HOME/.config"
        fi
    fi
    
    create_symlink "$DOTFILES_DIR/nvim/init.lua" "$nvim_config_dir/init.lua"
    create_symlink "$DOTFILES_DIR/nvim/lua" "$nvim_config_dir/lua"
    
    if [ "$DRY_RUN" = false ] && command_exists nvim; then
        info "Installing lazy.nvim and syncing plugins..."
        nvim --headless "+Lazy! sync" +qa
    fi
}

create_symlinks() {
    info "Creating symlinks for configuration files..."
    
    setup_neovim
    
    if [ -d "$DOTFILES_DIR/zsh" ]; then
        create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    fi
}

verify_installation() {
    info "Verifying installation..."
    
    local tools=("git" "curl" "wget" "unzip" "nvim" "go" "zsh")
    local failed=()
    
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            info "✓ $tool"
        else
            failed+=("$tool")
            warning "✗ $tool"
        fi
    done
    
    if [ ${#failed[@]} -eq 0 ]; then
        info "All essential tools are installed successfully!"
    else
        warning "Some tools failed to install: ${failed[*]}"
    fi
}

install_homebrew() {
    if command_exists brew; then
        info "Homebrew is already installed"
        return
    fi
    
    if [ "$DRY_RUN" = true ]; then
        info "Would install: Homebrew"
        return
    fi
    
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    --dry-run    Show what would be done without making changes
    --force      Force overwrite existing configurations
    --minimal    Install only essential tools
    --help       Show this help message

Examples:
    $0                 # Basic installation
    $0 --dry-run       # Preview changes
    $0 --force         # Force overwrite existing configs
    $0 --minimal       # Minimal installation
EOF
}

main() {
    if [ "$DRY_RUN" = true ]; then
        info "Running in dry-run mode - no changes will be made"
    fi
    
    info "Starting dotfiles setup..."
    info "Dotfiles directory: $DOTFILES_DIR"
    
    local os=$(detect_os)
    info "Detected OS: $os"
    
    local pkg_manager=$(detect_package_manager "$os")
    info "Package manager: $pkg_manager"
    
    if [ "$os" = "macos" ]; then
        install_homebrew
    fi
    
    install_essential_tools "$os" "$pkg_manager"
    
    if [ "$MINIMAL" = false ]; then
        install_dev_tools "$os" "$pkg_manager"
        setup_zsh "$os" "$pkg_manager"
    fi
    
    create_symlinks
    
    if [ "$DRY_RUN" = false ]; then
        verify_installation
        info "Setup completed successfully!"
        info "Please restart your shell or run 'source ~/.zshrc' to apply changes."
    else
        info "Dry-run completed. Use '$0' to apply changes."
    fi
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --minimal)
            MINIMAL=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi