. ~/.config/bash/git-completion.bash
. ~/.config/bash/git-prompt.sh

export LANG=ja_JP.UTF-8

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWCOLORHINTS=1

function setPrompt(){
    newLine=$'\n'
    PS1='\[\e[30;44m'$(echo -e "\ue0b0")'\[\e[39;49m'
    PS1+='\[\e[32;44m[\t]\[\e[49m'
    PS1+='\[\e[34;42m'$(echo -e "\ue0b0")'\[\e[39m'
    PS1+=' '
    PS1+='\w'
    PS1+=' '
    PS1+='\[\e[32;49m'$(echo -e "\ue0b0")'\[\e[39m'
    PS1+='\[\e[2;3;32m $(__git_ps1 "%s") \[\e[m'
    PS1+=$newLine
    PS1+='$(if [ $? == 0 ];then echo "\[\e[32m";else echo "\[\e[1;31m";fi)>\[\e[39m'
    PS1+=' '
    PS1+='\[\e[m\]\]'
    export PS1
}

setPrompt