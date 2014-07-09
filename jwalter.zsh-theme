# vim:ft=zsh ts=2 sw=2 sts=2
#
# jwalter's Theme - https://github.com/jeffwalter/jwalter.zsh-theme
# Based heavily on agnoster's Theme - https://gist.github.com/3712874
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$user@%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty mode repo_path
  
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    GIT_PATH="$(git rev-parse --git-dir 2>/dev/null)"

    eval "$(git status --porcelain 2>&1 | awk '/^\?\?/ {untracked++;} /^[ADMR]/ {staged++;} /^ M/ {modified++} /^ D/ {removed++;} END {printf ("GIT_UNTRACKED=%u\nGIT_MODIFIED=%u\nGIT_REMOVED=%u\nGIT_STAGED=%u\n", untracked, modified, removed, staged);}')"
    eval "$(git status 2>&1 | awk '/branch is ahead/ {ahead=$(NF-1);} /branch is behind/ {behind=$7;} /different commits each/ {ahead=$3; behind=$5;} /On branch/ {branch=$NF;} END {printf ("GIT_AHEAD=%u\nGIT_BEHIND=%u\nGIT_BRANCH=\"%s\"\n", ahead, behind, branch);}')"
    GIT_COMMIT="$(git rev-parse HEAD 2>/dev/null | grep -ioE '^[0-9a-f]{10}' | head -n 1)"
    if [[ -z "${GIT_COMMIT}" ]]; then
      GIT_COMMIT="initial"
    fi
    GIT_TAG="$(git describe --tags 2>/dev/null)"


    if [[ -n "$(parse_git_dirty 2>&1)" ]]; then
      prompt_segment yellow black
    else
      prompt_segment green black
    fi

    echo -n " ${GIT_BRANCH}→${GIT_COMMIT}"
    if [ -n "${GIT_TAG}" ]; then
      echo -n ":${GIT_TAG}"
    fi

    GIT_STATS=""
    if [[ ${GIT_UNTRACKED} -gt 0 ]]; then
      GIT_STATS="${GIT_STATS}…${GIT_UNTRACKED}"
    fi
    if [[ ${GIT_MODIFIED} -gt 0 ]]; then
      GIT_STATS="${GIT_STATS}±${GIT_MODIFIED}"
    fi
    if [[ ${GIT_REMOVED} -gt 0 ]]; then
      GIT_STATS="${GIT_STATS}-${GIT_REMOVED}"
    fi
    if [[ ${GIT_STAGED} -gt 0 ]]; then
      GIT_STATS="${GIT_STATS}+${GIT_STAGED}"
    fi
    if [[ ${GIT_AHEAD} -gt 0 ]]; then
      GIT_STATS="${GIT_STATS}↑${GIT_AHEAD}"
    fi
    if [[ ${GIT_BEHIND} -gt 0 ]]; then
      GIT_STATS="${GIT_STATS}↓${GIT_BEHIND}"
    fi

    if [ -n "${GIT_STATS}" ]; then
      echo -n " ${GIT_STATS}"
    fi

    if [[ -e "${GIT_PATH}/BISECT_LOG" ]]; then
      echo -n " (Bisecting)"

    elif [[ -e "${GIT_PATH}/MERGE_HEAD" ]]; then
      echo -n " (Merging)"

    elif [[ -e "${GIT_PATH}/rebase" || -e "${GIT_PATH}/rebase-apply" || -e "${GIT_PATH}/rebase-merge" || -e "${GIT_PATH}/../.dotest" ]]; then
      echo -n " (Rebasing)"
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment blue black '%~'
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment blue black "(`basename $virtualenv_path`)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
