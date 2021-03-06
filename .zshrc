# General {{{
#---------------------------------------------------------------------------------

# Set history
HISTSIZE=100000
HISTFILE="$HOME/.history"
SAVEHIST=$HISTSIZE
setopt inc_append_history
setopt share_history

unsetopt nomatch

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
# Ctrl-n      Insert sudo prefix
# Esc-e       Edit the current line in editor
# Ctrl-x f    Insert files
# Ctrl-t      Tetris
#
# Ctrl-b      Go back one word
# Ctrl-f      Go forward one word
# Ctrl-w      Delete the previous word
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
bindkey "^J" insert-root-prefix

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^[e' edit-command-line
bindkey '^X^E' edit-command-line
bindkey -M vicmd v edit-command-line

autoload -U insert-files
zle -N insert-files
bindkey "^Xf" insert-files

bindkey "^W" backward-kill-word
bindkey "^B" backward-word
bindkey "^F" forward-word

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
PROMPT='%{$fg[magenta]%}%c%{$fg[green]%}$(git_prompt_info)%{$fg[magenta]%} ⇢  %{$reset_color%}'
# }}}
# Custom commands {{{
#---------------------------------------------------------------------------------

# git shortcut
g() {
    if [[ $# == 0 ]]; then
        git status
    else
        git $*
    fi
}

# navigates back to the root folder of the current project
rt() {
    while [ ! -d ".git" ]; do
        cd ..
    done 
}

# a shortcut for my projects directory that supports auto-completion
#from https://github.com/holman/dotfiles
c() { 
    cd ~/work/$*
}

compdef '_files -W ~/work -/' c


a() {
    cd ~/algo/$*
}

compdef '_files -W ~/algo -/' a

cdl() {
    cd $*;
    l
}

dotf() {
    if [[ $# == 0 ]]; then
        cd ~/dotfiles
    else
        vi ~/dotfiles/$*
    fi
}

compdef '_files -W ~/dotfiles -/' dotf

# }}}
# Aliases {{{
#---------------------------------------------------------------------------------

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

# misc
alias duh='du -csh'
alias top='top -o cpu'
alias df='df -h'
alias jobs='jobs -p'
alias cpu="ps ux | awk 'NR > 1 {res += \$3} END { print \"Total %CPU:\",res }'"
alias grep='grep --colour'
alias egrep='egrep --colour'
alias calc='noglob calc'

# fucking vim
alias h="man"
alias so="source ~/.zshrc"
alias :q="toilet -f bigmono12 -F gay FACEPALM"
# }}}
