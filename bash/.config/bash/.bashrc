. ~/.config/bash/git-completion.bash
. ~/.config/bash/git-prompt.sh

export LANG=ja_JP.UTF-8

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWCOLORHINTS=1

function setPrompt(){
    # define decorations
    _reset=$(tput sgr0)
    _fgBlack=$(tput setaf 0) #\e[30m
    _bgBlack=$(tput setab 0) #\e[40m
    _fgRed=$(tput setaf 1) #\e[31m
    _bgRed=$(tput setab 1) #\e[41m
    _fgGreen=$(tput setaf 2) #\e[32m
    _bgGreen=$(tput setab 2) #\e[42m
    _fgYellow=$(tput setaf 3) #\e[33m
    _bgYellow=$(tput setab 3) #\e[43m
    _fgBlue=$(tput setaf 4) #\e[34m
    _bgBlue=$(tput setab 4) #\e[44m
    _fgMagenta=$(tput setaf 5) #\e[35m
    _bgMagenta=$(tput setab 5) #\e[45m
    _fgCyan=$(tput setaf 6) #\e[36m
    _bgCyan=$(tput setab 6) #\e[46m
    _fgWhite=$(tput setaf 7) #\e[37m
    _bgWhite=$(tput setab 7) #\e[47m
    _bold=$(tput bold)
    _italic=$(tput sitm)
    _dim=$(tput dim)
    _newLine=$'\n'
    
    PS1=$_fgBlack$_bgBlue$(echo -e "\ue0b0")$_reset
    PS1+=$_fgGreen$_bgBlue'[\t]'$_reset
    PS1+=$_fgBlue$_bgGreen$(echo -e "\ue0b0")$_reset
    PS1+=$_fgBlue$_bgGreen' \w '$_reset
    PS1+=$_fgGreen$(echo -e "\ue0b0")$_reset
    PS1+=$_fgGreen$_dim$_italic' $(__git_ps1 "%s") '$_reset
    PS1+=$_newLine
    PS1+='$(if [ $? == 0 ];then echo '$_fgGreen$(echo -e "\U0001f4ac")';else echo '$_bold$_fgRed$(echo -e "\U0001f4ab")';fi) >'$_reset
    PS1+=' '
    PS1+=$_reset
    export PS1
}

setPrompt
