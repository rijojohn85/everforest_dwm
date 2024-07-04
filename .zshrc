# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

autoload -Uz compinit
compinit
# End of lines added by compinstall

###################################
#     Plugins 
###################################
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

###################################
#      exclusive settings
###################################
# vi mode
bindkey -v
export KEYTIMEOUT=1

# language and unicode
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Editor
export EDITOR=nvim
export VISUAL=nvim

## Editing command line in vim
autoload -z edit-command-line
zle -N edit-command-line
bindkey -M  vicmd v edit-command-line

# Keybindings
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char

###################################
#    Exporting Paths
###################################
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.emacs.d/bin:$PATH"

alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias knvim="NVIM_APPNAME=knvim nvim"
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
alias rvim="NVIM_APPNAME=RustVim nvim"
alias pyvim="NVIM_APPNAME=PyVim nvim"

function nvims() {
  items=("default" "knvim" "LazyVim" "RustVim" "PyVim" "NvChad" "AstroNvim")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}
###################################
#     Aliases
###################################

## Universal
alias iconfig="nvim ~/.config/i3/config"
alias qconfig="nvim ~/.config/qtile/config.py"
alias polyconfig="nvim ~/.config/polybar/config.ini"
alias piconfig="nvim ~/.config/picom/picom.conf"
alias alconfig="nvim ~/.config/alacritty/alacritty.toml"
alias kitconfig="nvim ~/.config/kitty/kitty.conf"
alias wezconfig="nvim ~/.config/wezterm/wezterm.lua"
alias vv="nvim"
alias dv="devour"
alias open="devour pcmanfm"
alias ss="ranger ~/Pictures/screenshots"
alias neodir="cd ~/.config/nvim"
alias DS="cd ~/Desktop/DS"
alias bsource="source .bashrc"
alias xx="exit"
alias cc="clear"
alias ai="tgpt"
alias cd="z"
alias ipaddr="ip -o route get to 9.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'"

## Arch
alias up="paru -Syyu"
alias ref="paru -Syy"
alias search="paru -Ss"
alias pacs="paru -Q | wc -l"
alias list="paru -Q"
alias aur_list="paru -Qm"

###################################
#         Tmux
###################################
alias tnew="tmux new -s"
alias tls="tmux ls"
alias trename="tmux rename-session -t"
alias ta="tmux a -t"

# Starship prompt
eval "$(starship init zsh)"

source ~/alias
# fzf
# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

eval $(thefuck --alias)
eval $(thefuck --alias fk)


eval "$(zoxide init zsh)"

eval "$(starship init zsh)"
