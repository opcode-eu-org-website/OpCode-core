#!/bin/bash

# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

for repo_name in *; do [ -d "$repo_name/.git" ] && (
	cd "$repo_name"
	repo_owner=$(git remote -v | grep '^pub-' | awk '{print $2; exit}' | awk 'BEGIN {FS="[/:]"} $1=="ssh" {print $5; next} {print $2}')
	case "${repo_owner,,}" in
		"opcode-eu-org"|"opcode-eu-org-website"|"opcode-eu-org-libs")
			mode="opcode"
			url="https://src-opcode.pages.dev/"
			;;
		"dragons-labs")
			mode="dragons-labs"
			url="https://src-dragons-labs.pages.dev/"
			;;
		*)
			#echo "no-pub $repo_name 0 1"
			exit
			;;
	esac
	
	# get info about branches from repos site
	LS_REMOTE=$(git ls-remote "$url/$repo_name")
	
	# list all branches tracked by public remotes (with branch-HEAD commit hash)
	git branch -rv --no-abbrev | awk '
		BEGIN {FS="[ /]+"}
		$2 !~ "^pub-" {next}
		b[$3]=="" {b[$3]=$4; next}
		b[$3] != $4 {b[$3] = b[$3] "/" $4}
		END {for (bb in b) print bb, b[bb]}
	' | while read BRANCH REF1; do
		# for each branch tracked by public repo find branch-HEAD commit on repos site
		REF2=$(echo "$LS_REMOTE" | awk -v b="refs/heads/$BRANCH" '($2==b) {print $1}')
		echo "$mode $repo_name $BRANCH ${REF2:-NONE} $REF1"
	done
); done | sort | awk '
	$4 != $5 {print $0}
'
