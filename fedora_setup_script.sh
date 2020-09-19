#!/bin/bash
set -euo pipefail

#update os
sudo dnf update -y --refresh

#curl dotfiles

# remove firewalld and install iptables-services
sudo dnf remove -y firewalld
sudo dnf install -y iptables-services

# set restrictive umask for iptables file creation and store existing one to reset after
old_umask=$(umask)
umask 077

# ip6tables config
cat <<EOF | sudo tee /etc/sysconfig/ip6tables
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
COMMIT
EOF

# iptables config
cat <<EOF | sudo tee /etc/sysconfig/iptables
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
COMMIT
EOF

# enable and start iptables
sudo systemctl enable iptables ip6tables
sudo systemctl start iptables ip6tables

# reset umask
umask "$old_umask"

#install protonvpn cli
sudo dnf install -y openvpn dialog python3-pip python3-setuptools
pip3 install --user protonvpn-cli

#install extra programs
sudo dnf install -y \
        gimp.x86_64 \ #image editing software
        keepassxc.x86_64 \ #password manager
        # nextcloud-client.x86_64 \ #cloud storage client
        # nextcloud-client-nautilus.x86_64 \
        thunderbird.x86_64 \ #email client
        thunderbird-enigmail.noarch \ #GPG GUI tool
        htop.x86_64 \ #resource monitor
        git \ #version control
        nmap.x86_64 \ #network scanner
        ShellCheck.x86_64 \ #bash static analysis tool
        wget.x86_64 \ 
        wireshark.x86_64 \ #network analysis tool
        yubikey-manager.noarch \ #yubikey personalisation tool
        yubikey-personalization-gui.x86_64 \ #yubikey personalisation tool GUI
        jq.x86_64 \ #json processor
        bc.x86_64 \ #command line calculator
        android-tools.x86_64 \ 
        rsync.x86_64 \ #file synchronizing
        rclone.x86_64 \ #rsync for cloud storage
        zbar.x86_64 \ #bar code reader
        strace.x86_64 \ #tracks system calls
        tldr.noarch \ #similar to man pages with examples
        most.x86_64 \ #pager
        blueman.x86_64 \ #bluetooth manager
        pdfarranger.noarch \ #PDF file merging, rearranging, and splitting
        exif.x86_64 \ #jpg meta data tool
        pylint.noarch \ #python static analysis tool
        rdesktop.x86_64 \ #RDP client
        powerline.x86_64 \ #status-line/prompt utility
        tmux-powerline.noarch \ #status-line/prompt utility tmux plugin
        #marker.x86_64 \ #markdown editor
        vim-powerline.noarch #status-line/prompt utility vim plugin

#clean up
sudo dnf clean all
