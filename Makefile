.ONESHELL:
SHELL := bash
.SHELLFLAGS := -euo pipefail -c

.PHONY: init update

init: .git-lfs
	git lfs install --local
	if git rev-parse --verify -q HEAD >/dev/null; then
		git lfs pull
	fi

update:
	git fetch origin edge
	git merge --ff-only origin/edge
	git lfs pull

.git-lfs:
	if ! command -v git >/dev/null 2>&1 || ! command -v git-lfs >/dev/null 2>&1; then
		if command -v dnf >/dev/null 2>&1; then
			sudo dnf install -y git git-lfs
		elif command -v apt-get >/dev/null 2>&1; then
			sudo apt-get update && sudo apt-get install -y git git-lfs
		elif command -v pacman >/dev/null 2>&1; then
			sudo pacman -Sy --noconfirm git git-lfs
		elif command -v brew >/dev/null 2>&1; then
			brew install git git-lfs
		else
			echo "no supported package manager found; install git and git-lfs manually and re-run make init" >&2
			exit 1
		fi
	fi
	touch "$@"
