#!/bin/bash
USER="$1"
MOUNT_DIR="$2"

AWS_DIR="/home/ubuntu/telegram"

AWS_TMP_KEY="/home/ubuntu/.ssh/tmp_key.rsa"

function is_lib_installed() {
	LIB_NAME="$1"
	ASNWER=$(pip3 freeze | grep $LIB_NAME | wc -l)
	echo $ASWER
}	

function dinfo() {
	local INFO="$1"
	echo "INFO: $INFO"
}

dinfo "USER: $USER"
dinfo "MOUNT_DIR: $MOUNT_DIR"

function derror() {
	local ERROR="$1"
	echo "ERROR: $ERROR"
}

function upd_upgr() {
	# Update and Upgrade system
	echo -e "\n" \
			"+ = = = = = = = = = = = +\n" \
			"+                       +\n" \
			"+ update/upgrade system +\n" \
			"+                       +\n" \
			"+ = = = = = = = = = = = +\n" 

	sudo apt-get -y update 1>/dev/null
	sudo apt-get -y upgrade 1>/dev/null
}
function install_depen(){ 
	echo -e "\n" \
			"+ = = = = = = = = = = = +\n" \
			"+                       +\n" \
			"+   install git/pip3    +\n" \
			"+                       +\n" \
			"+ = = = = = = = = = = = +\n" 

	# Install necessary programs
	sudo apt-get -y install git
	sudo apt-get -y install python3-pip
}

function install_py_depen {
	echo -e "\n" \
			"+ = = = = = = = = = = = = = = +\n" \
			"+                             +\n" \
			"+  install python dependency  +\n" \
			"+                             +\n" \
			"+ = = = = = = = = = = = = = = +\n" 

	git clone "https://gitlab.com/AndreySamokhvalov/AdvertismentTelegramBot.git" /vagrant/

	dinfo "Create dir if needed ->"
	mkdir -p $AWS_DIR

	dinfo "Install python dependencies ->"
	sudo pip3 install $(cat "$AWS_DIR/src/ssp/requirements.txt")
	sudo pip3 install $(cat "$AWS_DIR/src/bot/requirements.txt")
	sudo pip3 install $(cat "$AWS_DIR/src/bidswitch/requirements.txt")

	else
		derror "tmp file not created!"
		exit
	fi
}

function main {
	upd_upgr
	install_depen
	install_py_depen
}

# main