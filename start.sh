function dinfo() {
	local INFO="$1"
	echo "INFO: $INFO"
}

function derror() {
	local ERROR="$1"
	echo "ERROR: $ERROR"
}

function get_aws_ip() {
	local AWS_IP=$(vagrant ssh-config | grep "HostName" | awk '{ printf $2 }')
	echo "$AWS_IP"
}
function get_domain() {
	local IP=$"$1"
	local DOMAIN=$(host $IP | awk '{ printf $5 }' | python -c "import sys; print(sys.stdin.read()[:-1])")
	echo "$DOMAIN"
}

function get_vm_ip() {
	local VM_IP=$(vagrant ssh-config | grep "HostName" | awk '{ printf $2 }')
	# local VM_DOMAIN=$(host $VM_IP | awk '{ printf $5 }' | python -c "import sys; print(sys.stdin.read()[:-1])")
	echo "$VM_IP"
}


function flash_iptables_rules(){
	# Flash all old iptables rules
	dinfo "Flash iptables rules ->"
	CMD=""
	CMD=$CMD" sudo iptables -F;"
	CMD=$CMD" sudo iptables -X;"
	CMD=$CMD" sudo iptables -t nat -F;"
	CMD=$CMD" sudo iptables -t nat -X;"
	ssh "ubuntu@$AWS_DOMAIN" "$CMD"
}

function make_reverse_tunnel() {

	PORT="$1"
	TUNNEL_PORT=$((PORT + 50000))
	
	# Add iptable rule because when ssh over 'ubuntu' user we can't make ssh tunnel on port below <1024
	dinfo "Add iptables redirect ->"
	CMD=""
	CMD=$CMD"sudo iptables -t nat -I PREROUTING --src 0/0 -p tcp --dport $PORT -j REDIRECT --to-ports $TUNNEL_PORT;"
	CMD=$CMD"sudo iptables -t nat -A OUTPUT -p tcp -d $AWS_DOMAIN --dport $PORT -j REDIRECT --to-port $TUNNEL_PORT;"
		
	ssh "ubuntu@$AWS_DOMAIN" "$CMD"
	dinfo "\t * $AWS_DOMAIN:$PORT -> $AWS_DOMAIN:$TUNNEL_PORT"

	# sysctl net.ipv4.ip_forward=1

	# Delete old ssh tunnel
	CMD="sudo lsof -i :$TUNNEL_PORT"
	PIDS=$(ssh "ubuntu@$AWS_DOMAIN" "$CMD" | sed -n '2p' | awk '{ printf "%s\n",$2 }')
	if [ ! "$PIDS" == "" ]; then
		dinfo "\t * AWS: Kill old $TUNNEL_PORT reverse tunnel proceses PIDS=$PIDS"
		ssh "ubuntu@$AWS_DOMAIN" "sudo kill -9 $PIDS"
	fi

	# Make new ssh tunnel
	dinfo "Make tunnel ->"
	ssh -f -N -R "0.0.0.0:$TUNNEL_PORT:$VM_IP:$PORT" "ubuntu@$AWS_DOMAIN" 
	dinfo "\t * $AWS_DOMAIN:$TUNNEL_PORT -> $VM_IP:$PORT"
}

function check_vagrant() {
	dinfo "Check vagrant ->"
	output=$(whereis vagrant)
	if [[ ! $output == *"vagrant"* ]]; then
		dinfo "\t * Please install vagrant"
		exit
	else
		dinfo "\t * Vagrant is installed"
	fi
}

function check_aws_plugin() {
	dinfo "Check aws plugin ->"
	output=$(vagrant plugin list | grep vagrant-aws)
	if [[ ! $output == *"vagrant-aws"* ]]; then
		dinfo "\t * Please install vagrant plugin 'vagrant plugin install vagrant-aws'"
		exit
	else
		dinfo "\t * AWS plugin already installed"
	fi
}

function check_aws_box() {
	dinfo "Check aws box ->"
	output=$(vagrant box list | grep dummy)
	if [[ ! $output == *"dummy"* ]]; then
		dinfo "\t * Please install aws box 'vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'"
		exit
	else
		dinfo "\t * AWS box already installed"
	fi
}

function check_env() {
	dinfo "Check environment variables ->"

	: ${VAGRANT_AWS_DIR?"Need to set VAGRANT_AWS_DIR"}
	: ${VAGRANT_VM_DIR?"Need to set VAGRANT_VM_DIR"}
	: ${VAGRANT_DIR?"Need to set VAGRANT_DIR"}
	: ${AWS_KEYNAME?"Need to set AWS_KEYNAME"}
	: ${AWS_KEYPATH?"Need to set AWS_KEYPATH"}
	: ${AWS_KEY?"Need to set AWS_KEY"}
	: ${AWS_SECRET?"Need to set AWS_SECRET"}

	dinfo "\t * All variables is setted"
}

function ssl_generate() {
	dinfo "Generate SSL certificate ->"
	SSL_DIR="../telegram/src/bot/ssl"
	
	if [ -d $SSL_DIR ]; then
		dinfo "\t * Delete old sertificates"
		rm $SSL_DIR/*
	else
		dinfo "\t * Create SSL dir"
		mkdir $SSL_DIR
	fi

	dinfo "\t * Create new certificates"
	openssl req -new -newkey rsa:1024 -days 365 -nodes -x509 \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=$AWS_DOMAIN" \
    -keyout "$SSL_DIR/server.key" \
    -out "$SSL_DIR/server.crt"
} 

# # Check before running
check_vagrant
check_aws_plugin
check_aws_box
check_env

# # ================== AWS ==================
cd $VAGRANT_AWS_DIR
dinfo "Up AWS instance ->"
vagrant up --provider=aws || { derror "Can't load aws instance"  ; exit 1; }

dinfo "Get AWS ip ->"
AWS_IP=$(get_aws_ip)
dinfo "\t * AWS_IP=$AWS_IP"

dinfo "Get AWS domain ->"
AWS_DOMAIN=$(get_domain "$AWS_IP")
dinfo "\t * AWS_DOMAIN=$AWS_DOMAIN"

# # ================== VM ==================
cd $VAGRANT_VM_DIR
dinfo "Up VM instance ->"
vagrant up --provider=parallels || { derror "Can't load vm instance"  ; exit 1; }

dinfo "Get VM ip ->"
VM_IP=$(get_vm_ip)
dinfo "\t * VM_IP=$VM_IP"

cd $VAGRANT_DIR
flash_iptables_rules

make_reverse_tunnel "80"
make_reverse_tunnel "443"
ssl_generate

dinfo "+ ==================================== +"
dinfo "\t * AWS_IP=$AWS_IP"
dinfo "\t * AWS_DOMAIN=$AWS_DOMAIN"
dinfo "\t * VM_IP=$VM_IP"
dinfo "+ ==================================== +"




