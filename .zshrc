autoload promptinit compinit
promptinit
compinit

setopt autocd
setopt prompt_subst
setopt correct
setopt inc_append_history
setopt extended_history
setopt hist_ignore_dups
setopt hist_save_no_dups
unsetopt beep

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	SESSION_TYPE=remote/ssh
# many other tests omitted
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

accept-line-custom () {
	(( $#BUFFER == 0 )) && blank_cmd; zle accept-line
};
zle -N accept-line-custom; bindkey '^M' accept-line-custom

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
	git ls-files -u >& /dev/null
	if [[ $? != 0 ]]; then
		return #No .git found! Abort!
	fi

	NEEDSPACE=0
	OUTPUT=''

	if [[ `git log --branches --not --remotes |wc -l|xargs` != 0 ]]; then
		OUTPUT=${OUTPUT}"%F{green}^"
		NEEDSPACE=1
	fi

	git diff --quiet >& /dev/null
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
	git ls-files -u >& /dev/null
	if [[ $? != 0 ]]; then
		return #No .git found! Abort!
	fi

	BRANCH=$(parse_git_branch | cut -d'/' -f3)


	if [[ $BRANCH != "master" ]]; then
		echo "%F{green}["${BRANCH}"] "
	fi
}

function prompt_svn(){
	svn status >& /dev/null
	if [[ $? != 0 ]]; then
		return #No svn installed!
	fi

	if [ ! -d ".svn" ]; then
		return #Not svn root!
	fi

	OUTPUT=''

	if [[ `svn status|wc -l|xargs` != 0 ]]; then
		OUTPUT="%F{yellow}%% "
	fi

	echo $OUTPUT
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

	if [[ $PWD == '/Users/laurim' ]]; then
		return; #Its my default home, lets hide the ~
	fi

	if [[ -w $PWD ]]; then
		echo "%~ "
	else
		echo "%F{red}%~ "
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

# check internal version of the dots files
function prompt_version() {
	# don't check if we don't have the file
	if [ -f ~/.dots_version_hash ]; then
		CURRENT=`git --git-dir="$HOME/dots/.git" --work-tree="$HOME/dots" rev-parse HEAD`

		if [[ `cat ~/.dots_version_hash | grep $CURRENT` == "" ]]; then
			echo "%F{cyan}>"
		fi

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

function chpwd() {
	emulate -L zsh

	if [[ `uname` == "Darwin" ]]; then
		ls -G
	else
		ls --color=auto
	fi
}

export EDITOR="vim"

HISTFILE=~/.zsh-history
HISTSIZE=5000
SAVEHIST=5000

zstyle ':completion:*' menu select

bindkey -e
bindkey '^R' history-incremental-search-backward

bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line

bindkey "^[[3~" delete-char

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
fi

alias cls="clear"
alias g="git"
alias d="docker"

alias cb="cargo build"
alias cr="cargo run"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias foldersize="du -h --max-depth=1 | sort -hr"
alias logout="clear && exit"
alias tags="ctags -R ."

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

function lsg(){ #ls grep
	ls -lah | grep -i $*
}

function findg(){ #find grep
	find | grep -i $*
}

function hg(){ #history grep
	history 1 | grep -i $*
}

function gs(){ #grep search
	grep -inIEr --color=ALWAYS "$*" .
}

function f(){
	find . -name "*$**"
}

function dots_update(){
	git --git-dir="$HOME/dots/.git" --work-tree="$HOME/dots" pull &
	retrieve_latest_version
}

function n(){
	vim ~/.scratch.txt
}

# Calculator
function = 
{
	echo "$@" | bc -l
}
alias calc="="

function zsh_stats() {
	fc -l 1 | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n20
}

# Make a notification (ring) after a command is done
function ring(){

	typeset -gi START=SECONDS
	$@
	typeset -gi DURATION=SECONDS-START

	reattach-to-user-namespace osascript -e "display notification \"Command $1 has finished in $DURATION seconds.\" with title \"Ring\""
}

# Load plugins
source ~/dots/extract.plugin.zsh

if [[ `uname` == "Darwin" ]]; then
	if  [ -f ~/dots/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
		# Tmux causes issues with this plugin
		if [ -z "$TMUX" ]; then
			source ~/dots/zsh-autosuggestions/zsh-autosuggestions.zsh
		fi
	else
		echo "! Remember to update submodules !"
	fi
fi

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


function retrieve_latest_version() {
	git ls-remote http://github.com/laurim/dots HEAD > ~/.dots_version_hash_temp

	# Moving to prevent empty file being present
	mv ~/.dots_version_hash_temp ~/.dots_version_hash
}

# Retrieve latest dots version on background
( retrieve_latest_version > /dev/null 2>&1 & )
