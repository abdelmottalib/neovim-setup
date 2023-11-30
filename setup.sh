#!/bin/sh

# Function for echoing with color
echo_color() {
    printf "\033[1;32m%s\033[0m\n" "$1"
}


# Check if Homebrew is installed
if [[ ! -d "$HOME/.brew/" ]]; then
    echo_color "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure $HOME/bin exists
[[ -d "$HOME/bin" ]] || mkdir "$HOME/bin"

# Change to $HOME/bin
cd "$HOME/bin"

# Function to install tools
install_tool() {
    local tool_name="$1"
    local tool_url="$2"
    local tool_file="$3"

    if ! command -v "$tool_name" > /dev/null 2>&1; then
        echo_color "Downloading $tool_name..."
        curl -# -OL "$tool_url"
        tar xzf "$tool_file"
        rm "$tool_file"
        mv "${tool_name}-"* "${tool_name}_dir"
        echo_color "$tool_name [installed]"
    fi
}

# Neovim
NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.9.4/nvim-macos.tar.gz"
NVIM_FILE="nvim-macos.tar.gz"
install_tool "nvim" "$NVIM_URL" "$NVIM_FILE"

# Ask if the user wants to install Astrovim
read -p "Do you want to install Astrovim? (y/n): " installAstrovim
if [[ $installAstrovim =~ ^[Yy]$ ]]; then
    # Install Astrovim
    echo_color "Installing Astrovim..."
    git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
    echo_color "Astrovim [installed]"
    # Existing nvim configuration
    if [[ ! -d "$HOME/.config/nvim/lua/user/" ]]; then
        if [[ -d "$HOME/.config/nvim" ]]; then
            mv "$HOME/.config/nvim" "$HOME/.config/old_nvim"
            echo_color "Existing nvim configuration moved to old_nvim."
        fi
    else
        echo_color "Cloning from abdelmottalib astrovim user config"
        git clone -q https://github.com/konami2/user "$HOME/.config/nvim/lua/user"
        echo_color "Astrovim config completed"
    fi

fi

# Ask if the user wants to install tmux
read -p "Do you want to install tmux? (y/n): " installTmux
if [[ $installTmux =~ ^[Yy]$ ]]; then
    # Install tmux
    echo_color "Installing tmux..."
    brew install tmux
    echo_color "Tmux [installed]"
fi

# Exporting path
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo "export PATH=$PATH:$HOME/bin/" >> "$HOME/.zshrc"
fi

# Installing brew and gettext
echo_color "Installing gettext using brew to fix link error"
curl -fsSL https://raw.githubusercontent.com/hakamdev/42homebrew/master/install.sh | zsh
brew install gettext
echo "export DYLD_LIBRARY_PATH=$HOME/.brew/Cellar/gettext/0.22.4/lib" >> $HOME/.zshrc

# Tmux Configuration
TMUX_CONFIG_URL="https://github.com/konami2/tmux_config/blob/main/.tmux.conf"
TMUX_CONFIG_FILE=".tmux.conf"
if [ ! -f "$HOME/$TMUX_CONFIG_FILE" ]; then
    echo_color "Downloading tmux configuration..."
    curl -# -OL "$TMUX_CONFIG_URL" -o "$HOME/$TMUX_CONFIG_FILE"
    echo_color "Tmux configuration added."
fi

echo_color "Script complete"
echo_color "Sourcing zshrc"
source $HOME/.zshrc

