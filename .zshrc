# General {{{
#---------------------------------------------------------------------------------

# Set history
HISTSIZE=100000
HISTFILE="$HOME/.history"
SAVEHIST=$HISTSIZE
setopt inc_append_history
setopt share_history

# Set default pager
export PAGER=most

# Set word characters
export WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Setup rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

# Setup mysql
export DYLD_LIBRARY_PATH=/usr/local/mysql/lib/
export PATH="$PATH:/usr/local/mysql/bin/"
export PATH="$PATH:/usr/local/Cellar/smlnj/110.72/libexec/bin"

# Setup tomcat
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/1.5/Home
export CATALINA_HOME=/usr/local/tomcat

#Custom commands inside
export PATH="$PATH:$HOME/dotfiles/bin"
# }}}
# Auto completion {{{
#---------------------------------------------------------------------------------

autoload -U compinit
compinit -C

zstyle ':completion:*' menu select
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"
# }}}
# Key bindings {{{
#---------------------------------------------------------------------------------
#
# Ctrl-f      Insert sudo prefix
# Esc-e       Edit the current line in editor
# Ctrl-x f    Insert files
# Ctrl-t      Tetris
#
#---------------------------------------------------------------------------------

insert-root-prefix () {
   local prefix
   case $(uname -s) in
      "SunOS")
         prefix="pfexec"
      ;;
      *) 
         prefix="sudo"
      ;;
   esac
   BUFFER="$prefix $BUFFER"
   CURSOR=$(($CURSOR + $#prefix + 1))
}

zle -N insert-root-prefix
bindkey "^F" insert-root-prefix

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^[e' edit-command-line
bindkey '^X^E' edit-command-line
bindkey -M vicmd v edit-command-line

autoload -U insert-files
zle -N insert-files
bindkey "^Xf" insert-files

# Tetris
autoload -U tetris
zle -N tetris
bindkey "^t" tetris
# }}}
# Prompt {{{
#---------------------------------------------------------------------------------

# Get the name of the branch we are on
git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo " (${ref#refs/heads/})"
}
autoload -U colors
colors
setopt prompt_subst
PROMPT='%{$fg[yellow]%}%c%{$fg[green]%}$(git_prompt_info)%{$fg[yellow]%} ⇢  %{$reset_color%}'
# }}}
# Aliases# {{{
#---------------------------------------------------------------------------------

# git
g() {
    if [[ $# == 0 ]]; then
        git status
    else
        git $*
    fi
}

# rails
alias r='rails'

# file navigation
alias l='ls -alGh'
alias lsd='ls -ldG *(-/DN)' #list directories
alias ..='cd ..'
alias ...='cd ../..'
alias t='touch'
alias mv='nocorrect mv -i'
alias mkdir='nocorrect mkdir'

rt() {
    while [ ! -d ".git" ]; do
        cd ..
    done 
}

c() { #from https://github.com/holman/dotfiles
    cd ~/work/$*
}

compdef '_files -W ~/work -/' c

# misc
alias duh='du -csh'
alias top='top -o cpu'
alias df='df -h'
alias jobs='jobs -p'
alias cpu="ps ux | awk 'NR > 1 {res += \$3} END { print \"Total %CPU:\",res }'"
alias grep='grep --colour'
alias egrep='egrep --colour'

# fucking vim
alias h="man"
alias so="source ~/.zshrc"
alias :q="toilet -f bigmono12 -F gay FACEPALM"
# }}}
