#!/bin/bash
set -euo pipefail

# update os
sudo dnf update -y --refresh

# curl dotfiles
curl https://raw.githubusercontent.com/sasha-kw/vim-config/master/.vimrc -o $HOME/.vimrc

# remove firewalld and install iptables-services
sudo dnf remove -y firewalld
sudo dnf install -y iptables-services

# set restrictive umask for iptables file creation and store existing one to reset after
old_umask=$(umask)
umask 077

# ip6tables config
cat <<EOF | sudo tee /etc/sysconfig/ip6tables
*filter
:INPUT DROP [o:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p ipv6-icmp -j ACCEPT
-A OUTPUT -o lo -j ACCEPT
-A OUTPUT -m conntrack --ctstate NEW,RELATED,ESTABLISHED -j ACCEPT
-A OUTPUT -p ipv6-icmp -j ACCEPT
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

# install protonvpn cli
sudo dnf install -y openvpn dialog python3-pip python3-setuptools
pip3 install --user protonvpn-cli

# resolved config
cat <<EOF | sudo tee /etc/systemd/resolved.conf
[Resolve]
DNSOverTLS=yes
DNSSEC=yes
DNS=dns.quad9.net
FallbackDNS=9.9.9.9 149.112.112.112 1.1.1.2 1.0.0.2 1.1.1.1 1.0.0.1
LLMNR=no
MulticastDNS=no
Cache=yes
DNSStubListener=yes
ReadEtcHosts=yes
ResolveUnicastSingleLabel=no
EOF

# restart resolved
sudo systemctl restart systemd-resolved

# install extra programs
sudo dnf install -y vim # text editor
sudo dnf install -y vim-airline.noarch # vim status-line/prompt utility
sudo dnf install -y vim-trailing-whitespace.noarch # vim whitespace plugin
sudo dnf install -y rust # programming language
sudo dnf install -y cargo # rust package manager
sudo dnf install -y rustfmt # rust formatter
sudo dnf install -y clippy # rust linter
sudo dnf install -y gimp.x86_64 # image editing software
sudo dnf install -y keepassxc.x86_64 # password manager
sudo dnf install -y htop.x86_64 # resource monitor
sudo dnf install -y powertop.x86_64 # power monitor
sudo dnf install -y git.x86_64 # version control
sudo dnf install -y nmap.x86_64 # network scanner
sudo dnf install -y ShellCheck.x86_64 # bash static analysis tool
sudo dnf install -y wget.x86_64 # download tool
sudo dnf install -y wireshark.x86_64 # network analysis tool
sudo dnf install -y yubikey-manager.noarch # yubikey personalisation tool
sudo dnf install -y yubikey-personalization-gui.x86_64 # yubikey personalisation tool GUI
sudo dnf install -y jq.x86_64 # json processor
sudo dnf install -y bc.x86_64 # command line calculator
sudo dnf install -y android-tools.x86_64 # adb/fastboot ect
sudo dnf install -y rsync.x86_64 # file synchronizing
sudo dnf install -y rclone.x86_64 # rsync for cloud storage
sudo dnf install -y zbar.x86_64 # bar code reader
sudo dnf install -y qrencode.x86_64 # qr code generator
sudo dnf install -y strace.x86_64 # tracks system calls
sudo dnf install -y tldr.noarch # similar to man pages with examples
sudo dnf install -y cheat.x86_64 # similar to tldr
sudo dnf install -y howdoi.noarch # help with cli
sudo dnf install -y blueman.x86_64 # bluetooth manager
sudo dnf install -y pdfarranger.noarch # PDF file merging, rearranging, and splitting
sudo dnf install -y exif.x86_64 # jpg meta data tool
sudo dnf install -y pylint.noarch # python static analysis tool
sudo dnf install -y rdesktop.x86_64 # RDP client
sudo dnf install -y pciutils.x86_64 # PCI bus related utilities
sudo dnf install -y firejail.x86_64 # security tool
sudo dnf install -y xournalpp.x86_64 # handwriting note taking
sudo dnf install -y pandoc.x86_64 # document converter
sudo dnf install -y vim-jedi.noarch # python autocompletion
sudo dnf install -y poetry.noarch # python project management tool
sudo dnf install -y lynis.noarch # security and system auditing tool
sudo dnf install -y calibre.x86_64 # ebook manager
sudo dnf install -y inkscape.x86_64 # drawing tool
sudo dnf install -y audacity.x86_64 # audio tool
sudo dnf install -y blender.x86_64 # 3D tool
sudo dnf install -y godot.x86_64 # game engine
sudo dnf install -y firefox.x86_64 # web browser
sudo dnf install -y ftp.x86_64 # file transfer tool
sudo dnf install -y i3.x86_64 # tiling window manager
sudo dnf install -y pam_yubico.x86_64 # Pluggable Authentication Module for yubikeys
sudo dnf install -y spectre-meltdown-checker.noarch # Spectre & Meltdown checker
sudo dnf install -y wireguard-tools.x86_64 # VPN
sudo dnf install -y openvpn.x86_64 # VPN
sudo dnf install -y wine.x86_64 # windows compatibility layer
sudo dnf install -y pdfgrep.x86_64 # pdf searching tool
sudo dnf install -y chromium.x86_64 # web browser
sudo dnf install -y cfn-lint # AWS CloudFormation linter
sudo dnf install -y awscli # AWS CLI
sudo dnf install -y python3-boto3.noarch # Python AWS SDK
sudo dnf install -y hugo.x86_64 # static website generator
sudo dnf install -y neofetch # system information
sudo dnf install -y fzf.x86_64 # fuzzy finder
sudo dnf install -y polybar # status bar
sudo dnf install -y picom # compositor
sudo dnf install -y nitrogen # wallpaper
sudo dnf install -y vim-gitgutter.noarch # git vim plugin
sudo dnf install -y @virtualization # virtualisation tools
sudo dnf install -y rpi-imager.x86_64 # raspberry pi imager
sudo dnf install -y gqrx.x86_64 # SDR application
sudo dnf install -y bubblewrap.x86_64 # sandbox application
sudo dnf install -y gh # github cli
sudo dnf install -y minicom.x86_64 # modem control and terminal emulation program
pip3 install --user cfn-flip # switch between json and yml cfn

# set vim as default text editor
sudo dnf remove -y nano-default-editor
sudo dnf install -y vim-default-editor

# clean up
sudo dnf clean all
