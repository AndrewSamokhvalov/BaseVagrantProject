#!/bin/bash

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

function enable_gatewayports() {
	dinfo "Enable GatewayPorts ->"

	SSHD_CONFIG="/etc/ssh/sshd_config"
	OPTION="GatewayPorts yes"

	IS_OPTION_ENABLED=$(cat "$SSHD_CONFIG" | grep "$OPTION" | wc -l)
	if [ "$IS_GATEWAYPORTS_ENABLED" == "0" ]; then
		sudo sh -c "echo '$OPTION' >>  $SSHD_CONFIG"
		dinfo "\t * GatewayPorts is enabled"
		sudo service ssh restart
	else
		dinfo "\t * GatewayPorts already enabled"
	fi
}

function upd_upgr() {
	# Update and Upgrade system
	dinfo " Update and upgrade system ->"

	sudo apt-get -y update || { derror "Can't update system"  ; exit 1; }
	sudo apt-get -y upgrade 1>/dev/null || { derror "Can't upgrade system"  ; exit 1; }
}

enable_gatewayports
upd_upgr