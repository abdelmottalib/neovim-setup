#!/bin/sh

# Function for echoing with color
echo_color () {
    printf "\033[1;32m%s\033[0m\n" "$1"
}

# Ensure $HOME/bin exists
[[ -d "$HOME/bin" ]] || mkdir "$HOME/bin"

# Change to $HOME/bin
cd "$HOME/bin"

# Neovim
NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.9.4/nvim-macos.tar.gz"
NVIM_FILE="nvim-macos.tar.gz"
if ! command -v nvim > /dev/null 2>&1; then
    echo_color "Downloading nvim..."
    curl -# -OL "$NVIM_URL"
    tar xzf "$NVIM_FILE"
    rm "$NVIM_FILE"
    echo_color  "Neovim [installed]"
fi

# Ripgrep
RG_URL="https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-apple-darwin.tar.gz"
RG_FILE="ripgrep-13.0.0-x86_64-apple-darwin.tar.gz"
if ! command -v rg > /dev/null 2>&1; then
    echo_color "Downloading ripgrep..."
    curl -# -OL "$RG_URL"
    tar xzf "$RG_FILE"
    rm "$RG_FILE"
    mv ripgrep-* rg_dir
    echo_color  "Ripgrep [installed]"
fi

# fd
FD_URL="https://github.com/sharkdp/fd/releases/download/v8.4.0/fd-v8.4.0-x86_64-apple-darwin.tar.gz"
FD_FILE="fd-v8.4.0-x86_64-apple-darwin.tar.gz"
if ! command -v fd > /dev/null 2>&1; then
    echo_color "Downloading fd..."
    curl -# -OL "$FD_URL"
    tar xzf "$FD_FILE"
    rm "$FD_FILE"
    mv fd-* fd_dir
    echo_color  "fd [installed]"
fi
#Exporting path
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo_color "export PATH=$PATH:$HOME/bin/" >> "$HOME/.zshrc"
fi
# Existing nvim configuration
if [[ ! -d "$HOME/.config/nvim/lua/user/" ]]; then
    if [[ -d "$HOME/.config/nvim" ]]; then
        mv "$HOME/.config/nvim" "$HOME/.config/old_nvim"
        echo_color  "Existing nvim configuration moved to old_nvim."
    fi
else
    echo_color  "Installing astrovim"
    git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
    echo_color  "Cloning from abdelmottalib astrovim user config"
    git clone -q https://github.com/konami2/user "$HOME/.config/nvim/lua/user"
    echo_color  "Astrovim config completed"
fi
#Installing brew and gettext
echo_color  "Installing gettext using brew to fix link error"
curl -fsSL https://raw.githubusercontent.com/hakamdev/42homebrew/master/install.sh | zsh
brew install gettext
echo_color "export DYLD_LIBRARY_PATH=$HOME/.brew/Cellar/gettext/0.22.4/lib" >> $HOME/.zshrc
# Tmux Configuration
brew install tmux
TMUX_CONFIG_URL="https://github.com/konami2/tmux_config/blob/main/.tmux.conf"
TMUX_CONFIG_FILE=".tmux.conf"
if [ ! -f "$HOME/$TMUX_CONFIG_FILE" ]; then
    echo_color "Downloading tmux configuration..."
    curl -# -OL "$TMUX_CONFIG_URL" -o "$HOME/$TMUX_CONFIG_FILE"
    echo_color  "Tmux configuration added."
fi

echo_color  "script complete"
chmod +x setup.sh
echo_color  "Sourcing zshrc"
source $HOME/.zshrc

