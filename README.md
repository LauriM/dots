# dots

These are my personal dotfiles, now with proper install process and crossplatform support!

# Installation

    git clone git@github.com:LauriM/dots.git
    cd dots
    ./symlinks.sh

# Local configs

* ~/.note.txt - displayed when new shell is created
* ~/.zshrc_local - local additions to .zshrc

# Prompt

Prompt is only showing the information that is necessary, for example hading my hostname if I am on my local machine.

    >User@Hostname $ [2] %^ [branch] ~/directory/something             [4]

While that is the longest the prompt can grow, usually it is this:

    $

The prompt has following items:

* ">" indicating that the dot files are not in sync with the Github repo
* username only visible if not my usual usernames
* hostname only visible if not the local machine
* $ The "prompt", never goes away
* % Visible if git repo is dirty
* ^ Visible if there is stuff to be pushed in the git repo
* [branch] visible if the branch is different than "master"
* Directory is visible if not in the home directory
* [4] On the right side, showing exec time of last command (only if != 0)
