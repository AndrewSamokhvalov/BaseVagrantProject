#!/bin/bash

function dinfo() {
	local INFO="$1"
	echo "INFO: $INFO"
}

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

# upd_upgr