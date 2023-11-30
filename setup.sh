#!/bin/zsh

# Function for echoing with color
echo_color() {
    printf "\033[1;32m%s\033[0m\n" "$1"
}



# Ensure $HOME/bin exists
[[ -d "$HOME/bin" ]] || mkdir "$HOME/bin"

# Change to $HOME/bin
cd "$HOME/bin"

# Function to install tools
install_tool() {
    local tool_name="$1"
    local tool_url="$2"
    local tool_file="$3"

    local install_dir="${tool_name}_dir"

    if [ -d "$install_dir" ]; then
        read -p "$tool_name is already installed. Do you want to reinstall it? (y/n): " reinstall
        if [[ ! $reinstall =~ ^[Yy]$ ]]; then
            echo_color "Skipping $tool_name installation."
            return
        fi
    fi

    echo_color "Downloading $tool_name..."
    curl -# -OL "$tool_url"
    tar xzf "$tool_file"
    rm "$tool_file"
    rm -fr install_dir
    mv "${tool_name}-"* "$install_dir"
    echo_color "$tool_name [installed]"
}

# Neovim
NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.9.4/nvim-macos.tar.gz"
NVIM_FILE="nvim-macos.tar.gz"
install_tool "nvim" "$NVIM_URL" "$NVIM_FILE"

# Ripgrep
RG_URL="https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-apple-darwin.tar.gz"
RG_FILE="ripgrep-13.0.0-x86_64-apple-darwin.tar.gz"
install_tool "rg" "$RG_URL" "$RG_FILE"

# fd
FD_URL="https://github.com/sharkdp/fd/releases/download/v8.4.0/fd-v8.4.0-x86_64-apple-darwin.tar.gz"
FD_FILE="fd-v8.4.0-x86_64-apple-darwin.tar.gz"
install_tool "fd" "$FD_URL" "$FD_FILE"

# Ask if the user wants to install Astrovim
read -p "Do you want to install Astrovim? (y/n): " installAstrovim
if [[ $installAstrovim =~ ^[Yy]$ ]]; then
    # Install Astrovim
    # Existing nvim configuration
    if [[ ! -d "$HOME/.config/nvim/lua/user/" ]]; then
        if [[ -d "$HOME/.config/nvim" ]]; then
            mv "$HOME/.config/nvim" "$HOME/.config/old_nvim"
            echo_color "Existing nvim configuration moved to old_nvim."
        fi
        echo_color "Installing Astrovim..."
        git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
        echo_color "Astrovim [installed]"
        echo_color "Cloning from abdelmottalib astrovim user config"
        git clone -q https://github.com/konami2/user "$HOME/.config/nvim/lua/user"
        echo_color "Astrovim config completed"
    fi

fi

# Check if Homebrew is installed
if [[ ! -d "$HOME/.brew" ]]; then
    echo_color "Homebrew is not installed. Installing Homebrew..."
    curl -fsSL https://raw.githubusercontent.com/hakamdev/42homebrew/master/install.sh | zsh
fi


# Exporting path
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo "export PATH=$PATH:$HOME/bin/" >> "$HOME/.zshrc"
fi

# Installing brew and gettext
echo_color "Installing gettext"
brew install gettext
echo "export DYLD_LIBRARY_PATH=$HOME/.brew/Cellar/gettext/0.22.4/lib" >> $HOME/.zshrc

# Ask if the user wants to install tmux
read -p "Do you want to install tmux? (y/n): " installTmux
if [[ $installTmux =~ ^[Yy]$ ]]; then
    # Install tmux
    echo_color "Installing tmux..."
    brew install tmux
    echo_color "Tmux [installed]"
fi

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

