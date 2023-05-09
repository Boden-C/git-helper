#!/bin/bash

cd "$(dirname "$0")"

function checkGit {
    if [ ! -d .git ]; then
	echo "Git is not installed. Initializing Git repository..."
	git init
    fi
}

function checkRemote {
    remote_url=$(git config --get remote.origin.url)
    if [ -z "$remote_url" ]; then
	read -p "[PROMPT] Enter the Github SSH Link you want the remote repository to be at: " github_link
	if [[ $github_link == "https://"* ]]; then
	    echo "You entered the HTTPS Link, auto-converting..."
	    # Replace "https://" with "git@" and ".com" with ":"
	    github_link=${github_link/https:\/\//git@}
	    github_link=${github_link/\//:}
	fi
	git remote add origin $github_link
	echo "Remote origin added: $github_link"
	echo "Run 'git remote -v' to check for remote"
    fi
}

function helpMenu {
    echo
    echo "=====HELP====="
    echo "sync"
    echo "     Choose branch and sync"
    echo "sync -m 'commit message'"
    echo "     Skip branch and directly commit"
    echo "sync pull"
    echo "     Pull only"
    echo "sync push"
    echo "     Push only"
    echo "sync remote"
    echo "     View and change remote origin"
    echo "==============="
}

function branchMenu {
    # Check if Git repository has any branches
    if [[ -z $(git branch --list) ]]; then
	echo "Creating 'main' as default branch..."
	git branch
	git branch main
    fi

    echo "=====BRANCHES====="
    git branch
    echo "=================="
    if [ $(git branch --show-current) = "master" ]; then
	echo "=====WARNING====="
	echo "GitHub uses 'main' as the default branch. Type 'main' below to change."
    fi
    read -p "[PROMPT] Enter the branch you want, or press 'Enter' to stay at $(git branch --show-current): " branch_name

    if [ -n "$branch_name" ]; then
	if git branch --list $branch_name > /dev/null
	then
	    git checkout $branch_name
	    echo "Switched to branch '$(git branch --show-current)'."
	else
	    git checkout -b $branch_name
	    echo "Created and switched to new branch '$(git branch --show-current)'."
	fi
    fi
}

function pull {
    current_branch=$(git branch --show-current)
    if [ "git branch --list $current_branch > /dev/null" ]; then
	if git pull origin $current_branch ; then
	    echo "Successfully pulled with no merge errors"
	else
	    echo "There was a error."
	    read -p "[PROMPT] If it is a merge error, press 'Enter' to run 'git mergetool', or any other key to exit." input
	    if [ -z "$input" ]; then
		git mergetool
		exit 0
	    else
		echo "Exiting, fix the merge error"
		echo "Once done, do 'sync -m \"commit message\"'"
		exit 0
	    fi
	fi
    fi
}

function push {
    git add .
    git commit -m "$1"
    if git diff-index --quiet --cached HEAD; then
	read -p "[PROMPT] There are no changes staged, pressing 'Enter' will push all changes. Otherwise, press any key to exit." input
	if [ -z "$input" ]; then
	    git add .
	else
	    echo "Exiting, do 'git add <file>' to stage a file for change"
	    echo "Once done, do 'sync push' and press 'Enter' on the warning"
	    exit 0
	fi
    fi

    if git ls-remote --heads origin "$current_branch" | grep -q "$current_branch"; then
	git push -u origin "$current_branch"
    else
	git push -u origin "$current_branch":"$current_branch"
    fi
}

#BEGIN MAIN

checkGit
checkRemote

#Check the parameters

#If not parameters
if [ $# -eq 0 ]; then
    branchMenu
    echo "Type 'end' to finish and not sync; otherwise..."
    read -p "[PROMPT] Enter the commit message or 'Enter' to use 'updated code' as message: " message
    if [[ $message == "end" ]]; then
	echo "Finished without syncing"
    elif [ -z "$message" ]; then
	pull
	push "updated code"
	echo "Finished, try 'sync -m' next time"
    else
	pull
	push "$message"
	echo "Finished, try 'sync -m \"commit message\"' next time"
    fi
    exit 0

    
elif [ $1 == "-m" ]; then
    if [ -z "$2" ]; then
	pull
	push "updated code"
	echo "Finished"
    elif [ -n "$2" ] && [ "$2" == "\"$2\"" ]; then
	pull
	push "${2//\"}"
	echo "Finished, try 'sync -m \"commit message\"' next time"
    else
	message="${*:2}"
	echo "Assuming commit message is '$message'"
	pull
	push "${*:2}"
	echo "Finished"
    fi
    exit 0	
    
    
elif [ $1 == "help" ]; then
    helpMenu
    exit 0


elif [ $1 == "pull" ]; then
    pull
    echo "Pulled only"
    exit 0

    
elif [ $1 == "push" ]; then
    echo "This ONLY pushes and does not pull; type 'end' to cancel, otherwise..."
    read -p "[PROMPT] Enter the commit message or 'Enter' to use 'updated code' as message: " message
    if [[ $message == "end" ]]; then
	echo "Canceled"
    elif [ -z "$message" ]; then
	push "updated code"
	echo "Pushed only"
    else
	push "$message"
	echo "Pushed only"
    fi
    exit 0
    

    
elif [ $1 == "remote" ]; then
    echo "=====REMOTE REPOSITORY====="
    git remote -v
    echo "==========================="
    read -p "[PROMPT] Enter the Github SSH Link you want the remote repository to be at OR press 'Enter' to keep: " github_link
	if [[ $github_link == "https://"* ]]; then
	    echo "You entered the HTTPS Link, auto-converting..."
	    # Replace "https://" with "git@" and ".com" with ":"
	    github_link=${github_link/https:\/\//git@}
	    github_link=${github_link/\//:}
	elif [ -z $github_link ]; then
	    echo "Staying at current remote repository"
	    echo "Run 'git remote -v' to check for remote"
	    exit 0
	fi
	git remote add origin $github_link
	git remote set-url origin $github_link
	echo "Remote origin is now: $(git remote get-url origin)"
	echo "Run 'git remote -v' to check for remote"
    exit 0

else
    helpMenu
    exit 0
fi
