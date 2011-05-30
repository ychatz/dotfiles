# Set history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

# Set default pager
export PAGER=most

# Setup rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

# Setup mysql
export DYLD_LIBRARY_PATH=/usr/local/mysql/lib/
export PATH="$PATH:/usr/local/mysql/bin/"
export PATH="$PATH:/usr/local/Cellar/smlnj/110.72/libexec/bin"

#Custom commands inside
export PATH="$PATH:$HOME/dotfiles/bin"

autoload compinit
compinit

# Wise message of the day (see /dotfiles/bin/randomcow)
randomcow

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# KEY BINDINGS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

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
bindkey "^F" insert-root-prefix # make ctrl+f add sudo prefix


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# PROMPT
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# Get the name of the branch we are on
git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo " (${ref#refs/heads/})"
}
autoload -U colors
colors
setopt prompt_subst
PROMPT='%{$fg[yellow]%}%c%{$fg[green]%}$(git_prompt_info)%{$fg[yellow]%} ⇢  %{$reset_color%}'


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# ALIASES
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# git
g() {
    if [[ $# == 0 ]]; then
        git status
    else
        git $*
    fi
}
alias gco='git checkout'
alias gc='git commit -am'

# rails
alias r='rails'

# file navigation
alias l='ls -alGh'
alias ..='cd ..'
alias ...='cd ../..'
alias t='touch'

# misc
alias duh='du -csh'
alias top='top -o cpu'
alias df='df -h'
alias jobs='jobs -p'
alias cpu="ps ux | awk 'NR > 1 {res += \$3} END { print \"Total %CPU:\",res }'"
alias c='clear'

# fucking vim
alias h="man"
alias so="source ~/.zshrc"
alias :q="toilet -f bigmono12 -F gay FACEPALM"
