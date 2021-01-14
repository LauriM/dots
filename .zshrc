#!/bin/zsh

# #######
# Options
# #######
autoload promptinit compinit
promptinit
compinit

setopt prompt_subst
setopt correct
setopt inc_append_history
setopt extended_history
setopt hist_ignore_dups
setopt hist_save_no_dups
unsetopt beep

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select

export EDITOR="vim"
export HISTFILE=~/.zsh-history
export HISTSIZE=15000
export SAVEHIST=15000

# #####
# Binds
# #####

bindkey -e
bindkey '^R' history-incremental-search-backward

bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line

bindkey "^[[3~" delete-char

accept-line-custom () {
(( $#BUFFER == 0 )) && blank_cmd; zle accept-line
};
zle -N accept-line-custom; bindkey '^M' accept-line-custom

# #######
# Aliases
# #######

if [[ `uname` == "Linux" ]]; then
	alias l="ls --color=auto"
	alias ll="ls -lah --color=auto"
	alias ls="ls --color=auto"
	alias dir="ls --color=auto"
fi

if [[ `uname` == "Darwin" ]]; then
	alias l="ls -G"
	alias ll="ls -lahG"
	alias ls="ls -G"
	alias dir="ls -G"
	export HOMEBREW_NO_EMOJI=1
	export HOMEBREW_NO_ANALYTICS=1
fi

alias cls="clear"
alias g="git"

alias glo='git log --oneline --decorate'
alias glol="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glola="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'

alias cb="cargo build"
alias cr="cargo run"
alias ct="cargo test"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias foldersize="du -h --max-depth=1 | sort -hr"
alias reload="source ~/.zshrc"

# ###########################
# Custom prompt configuration
# ###########################

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	SESSION_TYPE=remote/ssh
else
	case $(ps -o comm= -p $PPID) in
		sshd|*/sshd) SESSION_TYPE=remote/ssh;;
	esac
fi

function preexec() {
	#SHOWTIME=0
	typeset -gi CALCTIME=1
	typeset -gi CMDSTARTTIME=SECONDS
}

function precmd() {
	if (( CALCTIME )) ; then
		typeset -gi ETIME=SECONDS-CMDSTARTTIME
	fi
	typeset -gi CALCTIME=0
}

function blank_cmd(){
	#Blank line, reset timers and show time.
	typeset -gi ETIME=0
	#SHOWTIME=1
}

#Only display my username if its not the default one.
function prompt_user(){
	USERNAME=`whoami`
	if [[ $USERNAME != 'lauri' && $USERNAME != 'laurim' ]]; then

		# Only display the @ if both hostname and username are different
		if [ $SESSION_TYPE ]; then
			echo "%F{yellow}${USERNAME}%F{yellow}@"
		else
			echo "%F{yellow}"${USERNAME}""
		fi
	fi
}

function prompt_hostname(){
	if [ $SESSION_TYPE ]; then
		echo "%m "
	fi
}

parse_git_branch() {
	(git symbolic-ref -q HEAD  || echo "ref/dummy/~DETACHED~") 2> /dev/null
}

#Show % if the directory has a dirty git repo
#show ^ if the directory has commits that aren't pushed
#Show {branch} if branch isn't master
function prompt_git(){
	if (( ${+DOTS_GIT_DISABLE} )); then
		return # Disable git with a env variable
	fi

	git ls-files -u >& /dev/null
	if [[ $? != 0 ]]; then
		return #No .git found! Abort!
	fi

	NEEDSPACE=0
	OUTPUT=''

	BRANCH=$(parse_git_branch)
	BRANCH="${BRANCH/refs\/\heads\//}"

	if [[ `git log --branches --not --remotes --pretty=%d|grep $BRANCH|wc -l|xargs` != 0 ]]; then
		OUTPUT=${OUTPUT}"%F{green}^"
		NEEDSPACE=1
	fi

	git diff --ignore-submodules --quiet >& /dev/null
	if [[ $? == 1 ]]; then
		OUTPUT=${OUTPUT}"%F{blue}%%"
		NEEDSPACE=1
	fi

	if [[ $NEEDSPACE == 1 ]]; then
		OUTPUT=${OUTPUT}" "
	fi

	echo $OUTPUT
}

function prompt_branch() {
	if (( ${+DOTS_GIT_DISABLE} )); then
		return # Disable git with a env variable
	fi

	git ls-files -u >& /dev/null
	if [[ $? != 0 ]]; then
		return #No .git found! Abort!
	fi

	BRANCH=$(parse_git_branch)
	BRANCH="${BRANCH/refs\/\heads\//}"

	if [[ $BRANCH != "master" ]]; then

		DIR_LENGHT=$(pwd|wc -m)
		BRANCH_LENGHT=$(echo $BRANCH|wc -m)
		typeset -gi TARGETLENGHT=COLUMNS-25

		if [[ $DIR_LENGHT -ge $TARGETLENGHT ]]; then
			# Cut the branch display, not enough space
			echo "%F{green}[%F{white}..%F{green}] "
		else
			# Regular branch display, no need to cut it
			echo "%F{green}["${BRANCH}"] "
		fi
	fi
}

function prompt_exectime(){
	if [[ $ETIME > 0 ]]; then
		echo "%F{yellow}[%F{white}"$ETIME"%F{yellow}]"
	fi
}

function prompt_dir(){
	if [[ $PWD == '/home/lauri' ]]; then
		return; #Its my default home, lets hide the ~
	fi

	if [[ $PWD == '/Users/lauri' ]]; then
		return; #Its my default home, lets hide the ~
	fi
	
	if [[ $PWD == '/Users/laurim' ]]; then
		return; #Its my default home, lets hide the ~
	fi

	if [[ -w $PWD ]]; then
		PREFIX=`echo ""`
	else
		PREFIX=`echo "%F{red}"`
	fi

	DIR_LENGHT=$(pwd|wc -m)

	# Desired target for command spacing is 15 chars
	typeset -gi TARGETLENGHT=COLUMNS-15

	if [[ $DIR_LENGHT -ge $TARGETLENGHT ]]; then
		# Count how much we need to remove
		typeset -gi TO_BE_REMOVED=DIR_LENGHT-TARGETLENGHT
		typeset -gi PART_TWO_START=13+TO_BE_REMOVED

		A=`pwd|cut -c1-10`
		B=`pwd|cut -c$PART_TWO_START-999`

		echo "$PREFIX$A...$B "
	else
		echo "$PREFIX%~ "
	fi

}

function prompt_time(){
	if [[ $SHOWTIME == 1 ]]; then
		echo "%F{yellow}[%F{white}%*%F{yellow}]"
	fi
}

function prompt_jobs(){
	if [[ `jobs|wc -l|xargs` != 0 ]]; then
		echo "%F{blue}[%F{WHITE}%j%F{blue}] "
	fi
}

VIMODE='$'
function zle-line-init zle-keymap-select {
	VIMODE="${${KEYMAP/vicmd/#}/(main|viins)/$}"
	zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

PS1='%F{white}$(prompt_user)%F{yellow}$(prompt_hostname)$(prompt_jobs)$(prompt_git)%F{white}$(prompt_dir)$(prompt_branch)%(?.%F{green}.%F{red})${VIMODE} %f'
RPS1='$(prompt_exectime)' 

# #######################
# Custom helper functions
# #######################

# print ls when changing directory
function chpwd() {
	emulate -L zsh

	if [[ `uname` == "Darwin" ]]; then
		ls -G
	else
		ls --color=auto
	fi
}

# Cross-session directory stack
function pu(){
	pwd >> ~/.dirs.txt
}

function po(){
	cd `tail -n 1 ~/.dirs.txt` && sed -i '' -e '$ d' ~/.dirs.txt
}

function pd(){
	cat ~/.dirs.txt
}

#HELPER FUNCTIONS
function ss(){ #Search source
	grep -inIEr --exclude-dir=.svn --color=ALWAYS "$*" .
}

function f(){
	find . -name "*$**"
}

# Make a notification (ring) after a command is done
function ring(){
	typeset -gi START=SECONDS
	$@
	typeset -gi DURATION=SECONDS-START

	if [[ `uname` == "Darwin" ]]; then
		reattach-to-user-namespace osascript -e "display notification \"Command $1 has finished in $DURATION seconds.\" with title \"Ring\""
	fi
}

# ############################
# Load external configurations
# ############################

# Scan for nocorrect commands
if [ -f ~/.zsh_nocorrect ]; then
	while read -r COMMAND; do
		alias $COMMAND="nocorrect $COMMAND"
	done < ~/.zsh_nocorrect
fi

if [ -f ~/note.txt ]; then
	cat ~/note.txt
fi

#local zshrc additions
if [ -f ~/.zshrc_local ]; then
	source ~/.zshrc_local
fi

uptime
