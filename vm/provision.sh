#!/bin/bash
PROJECT_GIT_URL="$1"
PROJECT_DIR="/vagrant"

RED='\033[0;31m'
NC='\033[0m'

function dinfo() {
	local INFO="$1"
	echo "INFO: $INFO"
}

function derror() {
	local ERROR="$1"
	echo "ERROR: $ERROR"
}

function upd_upgr() {
	echo -e "\n" \
			"+ = = = = = = = = = = = +\n" \
			"+                       +\n" \
			"+ update/upgrade system +\n" \
			"+                       +\n" \
			"+ = = = = = = = = = = = +\n" 

	sudo apt-get -y update || { derror "Can't update system"  ; exit 1; }
	# sudo apt-get -y upgrade 1>/dev/null || { derror "Can't upgrade system"  ; exit 1; }
}

function check_env() {
	dinfo "Check environment variables ->"

	: ${PROJECT_GIT_URL?"Need to set PROJECT_GIT_URL"}
	dinfo "\t * PROJECT_GIT_URL=$PROJECT_GIT_URL"

	dinfo "\t * All variables is setted"
}

function install_depen(){ 
	echo -e "\n" \
			"+ = = = = = = = = = = = +\n" \
			"+                       +\n" \
			"+   install git/pip3    +\n" \
			"+                       +\n" \
			"+ = = = = = = = = = = = +\n" 

	# Install necessary programs
	sudo apt-get -y install git || { derror "Can't install git"  ; exit 1; }
	sudo apt-get -y install python3-pip || { derror "Can't install python3-pip"  ; exit 1; }
}

function install_py_depen {
	echo -e "\n" \
			"+ = = = = = = = = = = = = = = +\n" \
			"+                             +\n" \
			"+  install python dependency  +\n" \
			"+                             +\n" \
			"+ = = = = = = = = = = = = = = +\n" 

	# Add github.com to known_hosts because when "git fetch" ssh is asking about approval of unknown host and script stuck
	dinfo "Add github.com to known_hosts ->"
	KNOWN_HOSTS="$HOME/.ssh/known_hosts"
	HOST="gitlab.com"
	
	if [ -f $KNOWN_HOSTS ]; then
		IS_EXIST=$(grep '^'$HOST $KNOWN_HOSTS)
		if [ ! -n "$IS_EXIST" ]; then 
			ssh-keyscan gitlab.com >> $KNOWN_HOSTS 2>/dev/null; 
		fi
	fi

	cd $PROJECT_DIR
	dinfo "Clone project ->"
	if [ ! -d ".git" ]; then
		dinfo "\t * PROJECT_GIT_URL=$PROJECT_GIT_URL ->"
		git init || { derror "Can't init git project"  ; exit 1; }
		git remote add origin "$PROJECT_GIT_URL" || { derror "Can't add origin"  ; exit 1; }
		git fetch origin || { derror "Can't fetch origin"  ; exit 1; }
		git checkout aws-telegram-bot || { derror "Can't checkout branch"  ; exit 1; }
	else
		dinfo "\t * Project already exist"
	fi

	dinfo "Install python dependencies ->"
	sudo pip3 install $(cat "$PROJECT_DIR/src/ssp/requirements.txt") || { derror "Can't install ssp dependencies"  ; exit 1; }
	sudo pip3 install $(cat "$PROJECT_DIR/src/bot/requirements.txt") || { derror "Can't install bot dependencies"  ; exit 1; }
	sudo pip3 install $(cat "$PROJECT_DIR/src/bidswitch/requirements.txt") || { derror "Can't install bidswitch dependencies"  ; exit 1; }
}

function main {
	check_env	
	# upd_upgr
	# install_depen
	install_py_depen
}

main