zsh-jwalter
===========
My own personal ZSH theme with Git, SVN, and network awareness

Requirements
------------
* ZSH >= 4.3
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

Configuration
-------------
There are a number of environment variables you can set in your .zshrc that
affect which information is shown and how the theme presents it.

* **JWALTER_NET_FS**: List of filesystem types that are known to be network-based
    * Values: Space-separated list of filesystem types
    * Default: `nfs afs smb smbfs cifs`

* **JWALTER_SHELL_DAEMONS**: List of shell binaries with maps to a textual name
    * Values: Space-separated list of shell:description pairs
    * Default: `sshd:SSH in.sshd:SSH mosh-server:Mosh telnetd:Telnet in.telnetd:Telnet agetty:Local getty:Local Terminal:Local iTerm:Local xterm:Local Konsole:Local`

* **JWALTER_PATH_STYLE**: How the current working directory is shown: `full`
    gives an absolute path, `aliased` reduces the path on home directories
    * Values: `full`, `aliased`
    * Default: `full`

* **JWALTER_PATH_TRUNCATE**: If the current working directory has more than
    this number of elements, the extra elements are replaced with "...". `0`
    indicates no truncation
    * Values: Integer greater than or equal to `0`
    * Default: `0`

* **JWALTER_EXIT_STYLE**: Controls how the exit status of the previous command
    is displayed
    * Values: `icon`, `emote`
    * Default: `emote`

* **JWALTER_JOB_STYLE**: Controls how the number of backgrounded jobs is shown
    * Values: `icon`, `count`, `countalways`
    * Default: `count`

* **JWALTER_PROMPT_SECTIONS**: Space-separated list of which prompt sections to
    are shown and which order to show them in
    * Values: `userhost`, `exitstatus`, `rootstatus`, `jobstatus`, `exectime`, `path`, `git`, `svn`
    * Default: `rootstatus userhost jobstatus exitstatus exectime path git svn`

* **JWALTER_GIT_NET**: Whether or not even try Git commands on network filesystems
    * Values: `yes`, `no`
    * Default: `yes`

* **JWALTER_SVN_NET**: Whether or not even try SVN commands on network filesystems
    * Values: `yes`, `no`
    * Default: `yes`
