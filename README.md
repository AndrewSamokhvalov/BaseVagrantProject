# What I want:
* I work on OS X and want that  development and production environments were close to each other as much as possible.
* I don't have public ip address and I need way to be available from the internet (in my case this is Telegram Bot that should be available out of the local network).
* I need a fast synchronisations of my changes.
* I don't wanna waste enormous amount of time by setting up my environment again and again.

# This script helps me with:
* Run AWS instance over vagrant-aws.
* Run local vagrant vm with ubuntu-14.04.
* Install my project in vagrant vm and mount this directory on local computer.
* Install my project python dependencies.
* Create tunnel AWS:80 -> VM:80 and AWS:443 -> VM:443.
* Generate self-signed certificate for AWS domain.


## Example of init.sh
```
export AWS_KEYNAME="AndreySamokhvalov"
export AWS_KEYPATH="$HOME/.ssh/AndreySamokhvalov.pem"
export AWS_KEY="AKIAJAFIU54OS2B3UUHQ"
export AWS_SECRET="e0w01wf+qUgAI4Cj5Q4taXYLGTTLeabOai+Ec5yZ"

export PROJECT_GIT_URL="git@gitlab.com:AndreySamokhvalov/AdvertismentTelegramBot.git"
export PROJECT_GIT_SSH_KEY_PATH="$HOME/.ssh/id_rsa"
export PROJECT_DIR="$HOME/../project"
```

# Usage:
* Create init.sh in root directory.
* Run ". ./init.sh"
* Run " ./start.sh"

# Errors:
I know that this script is far away from ideal. If you have troubles please inform me about it.
