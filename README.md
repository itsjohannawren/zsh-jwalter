zsh-jwalter
===========
My own personal ZSH theme with Git, SVN, and network awareness

Requirements
------------
* ZSH >= 1.3
* Access to the `mount` command
* Terminal font patched with Powerline

Optional Requirements
---------------------
* Git
* SVN

Installation
------------
Clone the repo, create a symlink, change `.zshrc`. Or...

    cd "${ZSH_CUSTOM}"
    mkdir themes
    cd themes
    git clone https://github.com/jeffwalter/zsh-jwalter.git
    ln -s zsh-jwalter/jwalter.zsh-theme ./
    cd
    # Set ZSH_THEME to "jwalter"
    "${EDITOR}" .zshrc

That's it. Open a new terminal and you should be in business.
