#!/bin/bash

#update os
sudo dnf update -y

#curl dotfiles

#install iptables and configure

#install protonvpn cli
sudo dnf install -y openvpn dialog python3-pip python3-setuptools
sudo pip3 install protonvpn-cli

#install extra programs
sudo dnf install -y \
        gimp.x86_64 \
        keepassxc.x86_64 \ #password manager
        nextcloud-client.x86_64 \
        nextcloud-client-nautilus.x86_64 \
        thunderbird.x86_64 \ #email client
        thunderbird-enigmail.noarch \ #GPG GUI tool
        htop.x86_64 \
        git \
        nmap.x86_64 \ #network scanner
        ShellCheck.x86_64 \ #bash static analysis tool
        wget.x86_64 \
        wireshark.x86_64 \ #network analysis tool
        yubikey-manager.noarch \ #yubikey personalisation tool
        yubikey-personalization-gui.x86_64 \ #yubikey personalisation tool gui
        jq.x86_64 \ #json processor
        bc.x86_64 \ #command line calculator
        android-tools.x86_64 \
        rsync.x86_64 \
        rclone.x86_64 \ #rsync for cloud storage
        zbar.x86_64 \
        strace.x86_64 \
        tldr.noarch \ #similar to man pages with examples
        most.x86_64 \ #pager
        pylint.noarch \ #python static analysis tool
        rdesktop.x86_64 \ #RDP client

#clean up
sudo dnf clean all
