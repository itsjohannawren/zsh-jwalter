# jwalter's Theme - https://github.com/jeffwalter/jwalter.zsh-theme
# Based heavily on agnoster's Theme - https://gist.github.com/3712874

SYS_NET_FS="nfs afs smb smbfs cifs"

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

is_network_path() {
	local TEST_PATH SYS_MOUNTS SYS_MOUNT LONGEST_FS LONGEST_MOUNT
	TEST_PATH="${1}"

	for SYS_MOUNT in $(mount | awk '$2=="on" {mnt=$3} $3=="on" {mnt=$4} $4=="type" {fs=$5} $5=="type" {fs=$6} $4 ~ /^\(/ {sub(/\(/, "", $4); sub(/,/, "", $4); fs=$4} $5 ~ /^\(/ {sub(/\(/, "", $5); sub(/,/, "", $5); fs=$5} (mnt!="" && fs!="") {printf("%s:%s\n", fs, mnt)}'); do
		eval set -- "${SYS_MOUNT/:/ }"
		if [ "${1}" != "autofs" ]; then
			if echo "${TEST_PATH}" | grep -qE "^${2}"; then
				if [ "${#2}" -gt "${#LONGEST_MOUNT}" ]; then
					LONGEST_FS="${1}"
					LONGEST_MOUNT="${2}"
				fi
			fi
		fi
	done

	if echo "${SYS_NET_FS}" | grep -q "\\b${LONGEST_FS}\\b"; then
		return 0
	else
		return 1
	fi
}

prompt_userhost() {
	local USER
	USER="$(whoami)"

	if [ "${USER}" != "${DEFAULT_USER}" ] || [ -n "${SSH_CLIENT}" ]; then
		segment black default "%(!.%{%F{yellow}%}.)${USER}@%m"
	fi
}

prompt_git() {
	local GIT_PATH GIT_UNTRACKED GIT_MODIFIED GIT_REMOVED GIT_STAGED GIT_AHEAD GIT_BEHIND GIT_BRANCH GIT_COMMIT GIT_TAG GIT_STATS
	local GIT_PATH_REAL SYS_MOUNTS SYS_MOUNT LONGEST_MOUNT LONGEST_FS

	if git rev-parse --is-inside-work-tree &>/dev/null; then
		GIT_PATH="$(git rev-parse --git-dir 2>/dev/null)"

		# Are we on a network mount?
		if is_network_path "$(cd "${GIT_PATH}" &>/dev/null && pwd -P)"; then
			segment cyan black
			GIT_UNTRACKED="0"
			GIT_MODIFIED="0"
			GIT_REMOVED="0"
			GIT_STAGED="0"
			GIT_AHEAD="0"
			GIT_BEHIND="0"
			GIT_TAG=""

		else
			eval "$(git status --porcelain 2>&1 | awk '/^\?\?/ {untracked++;} /^[ADMR]/ {staged++;} /^ M/ {modified++} /^ D/ {removed++;} END {printf ("GIT_UNTRACKED=%u\nGIT_MODIFIED=%u\nGIT_REMOVED=%u\nGIT_STAGED=%u\n", untracked, modified, removed, staged);}')"
			eval "$(git status 2>&1 | awk '/branch is ahead/ {ahead=$(NF-1);} /branch is behind/ {behind=$7;} /different commits? each/ {ahead=$3; behind=$5;} /On branch/ {branch=$NF;} END {printf ("GIT_AHEAD=%u\nGIT_BEHIND=%u\nGIT_BRANCH=\"%s\"\n", ahead, behind, branch);}')"
			GIT_TAG="$(git describe --tags 2>/dev/null)"

			if [ -n "$(parse_git_dirty 2>&1)" ]; then
				segment yellow black
			else
				segment green black
			fi
		fi

		if [ -z "${GIT_BRANCH}" ]; then
			GIT_BRANCH="$(git branch 2>/dev/null | awk '/^\* / {print $2}')"
			if [ -z "${GIT_BRANCH}" ]; then
				GIT_BRANCH="NO BRANCH"
			fi
		fi
		GIT_COMMIT="$(git rev-parse HEAD 2>/dev/null | grep -ioE '^[0-9a-f]{10}' | head -n 1)"
		if [ -z "${GIT_COMMIT}" ]; then
			GIT_COMMIT="initial"
		fi

		echo -n " ${GIT_BRANCH}→${GIT_COMMIT}"
		if [ -n "${GIT_TAG}" ]; then
			echo -n ":${GIT_TAG}"
		fi

		GIT_STATS=""
		if [ "${GIT_UNTRACKED}" -gt 0 ]; then
			GIT_STATS="${GIT_STATS}…${GIT_UNTRACKED}"
		fi
		if [ "${GIT_MODIFIED}" -gt 0 ]; then
			GIT_STATS="${GIT_STATS}±${GIT_MODIFIED}"
		fi
		if [ "${GIT_REMOVED}" -gt 0 ]; then
			GIT_STATS="${GIT_STATS}-${GIT_REMOVED}"
		fi
		if [ "${GIT_STAGED}" -gt 0 ]; then
			GIT_STATS="${GIT_STATS}+${GIT_STAGED}"
		fi
		if [ "${GIT_AHEAD}" -gt 0 ]; then
			GIT_STATS="${GIT_STATS}↑${GIT_AHEAD}"
		fi
		if [ "${GIT_BEHIND}" -gt 0 ]; then
			GIT_STATS="${GIT_STATS}↓${GIT_BEHIND}"
		fi

		if [ -n "${GIT_STATS}" ]; then
			echo -n " ${GIT_STATS}"
		fi

		if [ -e "${GIT_PATH}/BISECT_LOG" ]; then
			echo -n " (Bisecting)"

		elif [ -e "${GIT_PATH}/MERGE_HEAD" ]; then
			echo -n " (Merging)"

		elif [ -e "${GIT_PATH}/rebase" ] || [ -e "${GIT_PATH}/rebase-apply" ] || [ -e "${GIT_PATH}/rebase-merge" ] || [ -e "${GIT_PATH}/../.dotest" ]; then
			echo -n " (Rebasing)"

		elif [ "$(git rev-parse --is-bare-repository 2>/dev/null)" = "true" ]; then
			echo -n " (Bare)"
		fi
	fi
}

prompt_dir() {
	if is_network_path "$(pwd)"; then
		segment blue black "(net) %~"
	else
		segment blue black "%~"
	fi
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
	RETVAL="$?"
	prompt_status
	prompt_userhost
	prompt_dir
	prompt_git
	segments_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
