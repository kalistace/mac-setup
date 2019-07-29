#!/bin/sh

pretty_print() {
  printf "\n%b\n" "[mac-setup] $1"
}

press_any_key_to_continue() {
  read -n1 -r -p "Press any key to continue..." key
}

pretty_print "Starting mac setup..."
pretty_print "Installing Apple's Xcode developer tools..."
if [[ $XCODE_LOCATION = "/Library/Developer/CommandLineTools" ]]; then
  pretty_print "The Xcode developer tools are already installed!"
  press_any_key_to_continue
else
  xcode-select --install
  while true; do
    if [ -d "/Library/Developer/CommandLineTools" ]; then
      break
    else
      pretty_print "Checking for successful Xcode developer tools installation. Follow onscreen prompts..."
      sleep 10
    fi
  done
  # A little bit hacky - just to be absolutely sure all files have been copied before proceeding
  sleep 10
  pretty_print "Successfully installed the Xcode developer tools!"
  press_any_key_to_continue
fi

pretty_print "Generating SSH key"
if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  pretty_print "SSH key already generated"
  press_any_key_to_continue
else
  pretty_print "email address to use ?"
  read -r email
  pretty_print "Using email to generate key, follow promt..."
  ssh-keygen -t rsa -b 4096 -C "$email"
fi
pretty_print "Adding key to ssh-agent"
ssh-add ~/.ssh/id_rsa

pretty_print "Copying public key to clipboard, share it if necessary(github, puppet, ...)"
pbcopy < ~/.ssh/id_rsa.pub

press_any_key_to_continue


pretty_print "Installing Ansible..."
sudo easy_install pip
sudo pip install ansible
pretty_print "Ansible installed"
pretty_print "Installing Homebrew..."
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
pretty_print "Homebrew installed"

pretty_print "Running ansible..."
press_any_key_to_continue
ansible-playbook mac_setup.yml -i hosts --ask-become-pass
press_any_key_to_continue

pretty_print "Installing Powerline fonts"
# clone
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
# clean-up a bit
cd ..
rm -rf fonts

pretty_print "Installing ohmyzhc"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
pretty_print "Copying custom zhc config"
cp .zshrc ~/
pretty_print "Copying custom git config"
cp .gitconfig ~/
pretty_print "Copying custom vim config"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cp .vimrc ~/
