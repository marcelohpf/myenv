#!/bin/bash

set -e

sudo apt-get update
sudo apt-get install --yes gcc libc6-dev make zlib1g-dev lbzip2 libncurses5-dev libffi-dev libreadline-dev libssl-dev

if [ ! -d $HOME/.local/pyenv ]; then
  git clone https://github.com/pyenv/pyenv.git $HOME/.local/pyenv
fi

export PYENV_ROOT=$HOME/.local/pyenv
export PATH="$PYENV_ROOT/bin${PATH:+:${PATH}}"
eval "$(pyenv init -)"

pyenv install 3.10.5
pyenv global 3.10.5
pip3 install ansible
which ansible-playbook

sudo apt-get install --yes openssh-server sshpass
sudo service ssh start
ssh-keygen
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
chmod 640 ~/.ssh/authorized_keys
