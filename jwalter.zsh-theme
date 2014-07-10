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

SEGMENT_BACKGROUND=""
SEGMENT_SEPARATOR=""

segment() {
	if [ -n "${1}" ]; then
		BACKGROUND="%K{$1}"
	else
		BACKGROUND="%k"
	fi

	if [ -n "${2}" ]; then
		FOREGROUND="%F{$2}"
	else
		FOREGROUND="%f"
	fi

	if [ -n "${SEGMENT_BACKGROUND}" ] && [ "${1}" != "${SEGMENT_BACKGROUND}" ]; then
		echo -n " %{${BACKGROUND}%F{$SEGMENT_BACKGROUND}%}${SEGMENT_SEPARATOR}%{${FOREGROUND}%} "
	elif [ -z "${SEGMENT_BACKGROUND}" ]; then
		echo -n "%{${BACKGROUND}%}%{${FOREGROUND}%}"
	else
		echo -n "%{${BACKGROUND}%}%{${FOREGROUND}%} "
	fi

	if [ -n "${3}" ]; then
		echo -n "${3}"
	fi

	SEGMENT_BACKGROUND="${1}"
}

# End the prompt, closing any open segments
segments_end() {
	if [ -n "${SEGMENT_BACKGROUND}" ]; then
		echo -n " %{%k%F{$SEGMENT_BACKGROUND}%}${SEGMENT_SEPARATOR}"
	else
		echo -n "%{%k%}"
	fi
	echo -n "%{%f%}"
	SEGMENT_BACKGROUND=""
}

prompt_userhost() {
	local USER
	USER="$(whoami)"

	if [[ "${USER}" != "${DEFAULT_USER}" || -n "${SSH_CLIENT}" ]]; then
		segment black default "%(!.%{%F{yellow}%}.)${USER}@%m"
	fi
}

prompt_git() {
	local GIT_PATH GIT_UNTRACKED GIT_MODIFIED GIT_REMOVED GIT_STAGED GIT_AHEAD GIT_BEHIND GIT_BRANCH GIT_COMMIT GIT_TAG GIT_STATS

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
			segment yellow black
		else
			segment green black
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

prompt_dir() {
	segment blue black '%~'
}

prompt_status() {
	local SYMBOLS
	SYMBOLS=""

	if [ "${RETVAL}" -ne 0 ]; then
		SYMBOLS="${SYMBOLS}%{%F{red}%}✘"
	fi
	if [ "${UID}" -eq 0 ]; then
		SYMBOLS="${SYMBOLS}%{%F{yellow}%}⚡"
	fi
	if [ "$(jobs -l | wc -l)" -gt 0 ]; then
		SYMBOLS="${SYMBOLS}%{%F{cyan}%}⚙"
	fi
	if [ -n "${SYMBOLS}" ]; then
		segment black default "${SYMBOLS}"
	fi
}

## Main prompt
build_prompt() {
	RETVAL=$?
	prompt_status
	prompt_userhost
	prompt_dir
	prompt_git
	segments_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
