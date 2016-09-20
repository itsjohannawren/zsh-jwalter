zsh-jwalter
===========
My own personal ZSH theme with Git, SVN, and network awareness

![Screenshot](https://github.com/jeffwalter/zsh-jwalter/raw/master/screenshot.png)

Requirements
------------
* ZSH >= 4.3
* Access to the `mount` command
* Terminal font patched with Powerline

Optional Requirements
---------------------
* Git
* SVN
* rvm
* nvm

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

* **JWALTER_UPDATE_INTERVAL**: How often to check for updates to the theme. A
    value of `0` disables updates.
    * Values: Days, integer greater than or equal to `0`
    * Default: `7`

* **JWALTER_PROMPT_SECTIONS**: Space-separated list of which prompt sections to
    are shown and which order to show them in.
    * Values:
        * `userhost`: Username and hostname for the session
        * `exitstatus`: Exit status of the last run command
        * `rootstatus`: Root indicator
        * `jobstatus`: Number of jobs currently running the session's
                       background
        * `exectime`: The elapsed real-time the last command took to run
        * `path`: Current working directory
        * `git`: Git repository information
        * `svn`: SVN repository information
        * `nvm`: Current NodeJS version via nvm
        * `rvm`: Current Ruby version via rvm
        * `break`: A line break
    * Default: `rootstatus userhost jobstatus exitstatus nvm rvm exectime path
               git svn`

* **JWALTER_NET_FS**: List of filesystem types that are known to be
    network-based.
    * Values: Space-separated list of filesystem types
    * Default: `nfs afs smb smbfs cifs`

* **JWALTER_SHELL_DAEMONS**: List of shell binaries with maps to a textual name.
    * Values: Space-separated list of shell:description pairs
    * Default: `sshd:SSH in.sshd:SSH mosh-server:Mosh telnetd:Telnet in.telnetd:Telnet agetty:Local getty:Local Terminal:Local iTerm:Local xterm:Local Konsole:Local`

* **JWALTER_PATH_STYLE**: How the current working directory is shown: `full`
    gives an absolute path, `aliased` reduces the path on home directories.
    * Values: `full`, `aliased`
    * Default: `full`

* **JWALTER_PATH_TRUNCATE**: If the current working directory has more than
    this number of elements, the extra elements are replaced with "...". `0`
    indicates no truncation.
    * Values: Integer greater than or equal to `0`
    * Default: `0`

* **JWALTER_HOSTNAME_DIVISORS**: A list of elements that will cause the local
    machine's hostname to be divided into a part that will be displayed and a
    part that will not.
    * Values: Space-separated list of hostname elements
    * Default: *empty*

* **JWALTER_HOSTNAME_PARTS**: The number of leading elements from the local
    machine's hostname to display. If an element in the hostname matches one
    from `JWALTER_HOSTNAME_DIVISORS` this value is ignored. A value of `0` here
    indicates that the whole hostname should be displayed.
    * Values: Integer greater than or equal to `0`
    * Default: `0`

* **JWALTER_EXIT_STYLE**: Controls how the exit status of the previous command
    is displayed.
    * Values: `icon`, `emote`
    * Default: `emote`

* **JWALTER_JOB_STYLE**: Controls how the number of backgrounded jobs is shown.
    * Values: `icon`, `count`, `countalways`
    * Default: `count`

* **JWALTER_GIT_NET**: Whether or not even try Git commands on network
    filesystems.
    * Values: `yes`, `no`
    * Default: `yes`

* **JWALTER_SVN_NET**: Whether or not even try SVN commands on network
    filesystems.
    * Values: `yes`, `no`
    * Default: `yes`
