# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set variable identifying the git branch you work in (used in the prompt below)
export GIT_PS1_SHOWDIRTYSTATE=1

pt_user_co() {
    if [ "$(id -u)" == "0" ]; then
        echo -en "\033[1;31m"
    else
        echo -en "\033[1;32m"
    fi
}

pt_host_co() {
    if [[ ${SSH_CLIENT} ]] || [[ ${SSH2_CLIENT} ]]; then 
        echo -en "\033[1;35m"
    else
        echo -en "\033[1;34m"
    fi
}

_git_repo() {
    if type -p __git_ps1; then
#        branch=$(__git_ps1 '%s')
        branch=$(__git_ps1)
        if [ -n "$branch" ]; then 
            subdir=$(git rev-parse --show-prefix 2>/dev/null)
            subdir="${subdir%/}" 
            predir="${PWD%/$subdir}"
            echo -ne "${predir#~}/${subdir}"
        else
            echo -ne ""
        fi
    fi
}

_git_repo_path() {
    if type -p __git_ps1; then
#        branch=$(__git_ps1 '%s')
        branch=$(__git_ps1)
        if [ -n "$branch" ]; then 
            n_remote="$(git remote | wc -l)"
            if [ $n_remote -eq 0 ]; then 
            # no remote repo, no backup red
                c_rem="[1;31m"
            elif [ $n_remote -eq 1 ]; then
            # single remote repo green
                c_rem="[1;32m"
            else
            # multiple remote repo purple
                c_rem="[1;35m"
            fi

            status=$(git status 2> /dev/null)
            if $(echo $status | grep 'added to commit' &> /dev/null); then
            # If we have modified files but no index (blue)
               c_stat="[1;34m"
            else
                if $(echo $status | grep 'to be committed' &> /dev/null); then
                # If we have files in index (red)
                   c_stat="[1;31m"
                else
                # If we are completely clean (green)
                   c_stat="[1;32m"
                fi
            fi

            subdir=$(git rev-parse --show-prefix 2>/dev/null)
            subdir="${subdir%/}" 
            predir="${PWD%/$subdir}"
            echo -ne "\033[01;34m~${predir#~}\033${c_rem}/${subdir}\033${c_stat}"
        else
            echo -ne "\033[01;34m"
        fi
    fi
}

# detect working directory relative to working tree root
pt_git_co() {
    if type -p __git_ps1; then
#        branch=$(__git_ps1 '%s')
        branch=$(__git_ps1)
        if [ -n "$branch" ]; then 
            if [ -n "$1" ]; then
                printf "$1" "${branch}"
            else
                printf "\n%s" "${branch}"
            fi
        else
            printf "%s" "~${PWD#~}"
        fi
    else
        printf "%s" "~${PWD#~}"
    fi
}

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    elif [ "$TERM" = "cygwin" ]; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi


if [ "$color_prompt" = yes ]; then
    #excape \[ non pritable char \]
    PS1='${debian_chroot:+($debian_chroot)}\[$(pt_user_co)\]\u\[\033[0m\]@\[$(pt_host_co)\]\h\[\033[0m\]:\[$(_git_repo_path)\]$(pt_git_co)\[\033[0m\]\$ '
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\n$(_git_repo)$(__git_ps1)\$ '
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h:\w\a\]$PS1"
    ;;
*)
    ;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
fi
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias pcregrep='pcregrep --color=auto'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

#git alias
#‘gco ‘, hit tab, and see all of branches
complete -o default -o nospace -F _git_checkout gco


alias gco='git checkout'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
