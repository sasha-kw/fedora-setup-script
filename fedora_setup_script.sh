#!/bin/bash
set -euo pipefail

# update os
sudo dnf update -y --refresh

# TODO curl dotfiles

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

# install protonvpn cli
sudo dnf install -y openvpn dialog python3-pip python3-setuptools
pip3 install --user protonvpn-cli

# resolved config
cat <<EOF | sudo tee /etc/systemd/resolved.conf
[Resolve]
DNSOverTLS=yes
DNSSEC=yes
DNS=1.1.1.2#cloudflare-dns.com 1.0.0.2#cloudflare-dns.com
FallbackDNS=1.1.1.2 1.0.0.2 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
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
sudo dnf install -y \
        gimp.x86_64 \ # image editing software
        keepassxc.x86_64 \ # password manager
        htop.x86_64 \ # resource monitor
        git.x86_64 \ # version control
        nmap.x86_64 \ # network scanner
        ShellCheck.x86_64 \ # bash static analysis tool
        wget.x86_64 \ # download tool
        wireshark.x86_64 \ # network analysis tool
        yubikey-manager.noarch \ # yubikey personalisation tool
        yubikey-personalization-gui.x86_64 \ # yubikey personalisation tool GUI
        jq.x86_64 \ # json processor
        bc.x86_64 \ # command line calculator
        android-tools.x86_64 \ # adb/fastboot ect
        rsync.x86_64 \ # file synchronizing
        rclone.x86_64 \ # rsync for cloud storage
        zbar.x86_64 \ # bar code reader
        qrencode.x86_64 \ # qr code generator
        strace.x86_64 \ # tracks system calls
        tldr.noarch \ # similar to man pages with examples
        cheat.x86_64 \ # similar to tldr
        blueman.x86_64 \ # bluetooth manager
        pdfarranger.noarch \ # PDF file merging, rearranging, and splitting
        exif.x86_64 \ # jpg meta data tool
        pylint.noarch \ # python static analysis tool
        rdesktop.x86_64 \ # RDP client
        powerline.x86_64 \ # status-line/prompt utility
        tmux-powerline.noarch \ # status-line/prompt utility tmux plugin
        pciutils.x86_64 \ # PCI bus related utilities
        firejail.x86_64 \ # security tool
        xournalpp.x86_64 \ # handwriting note taking
        pandoc.x86_64 \ # document converter
        vim-powerline.noarch # status-line/prompt utility vim plugin
        lynis.noarch \ # security and system auditing tool
        glow.x86_64 \ # markdown on CLI
        calibre.x86_64 \ # ebook manager
        inkscape.x86_64 \ # drawing tool
        audacity.x86_64 \ # audio tool
        blender.x86_64 \ # 3D tool
        firefox.x86_64 \ # web browser
        ftp.x86_64 \ # file transfer tool
        i3.x86_64 \ # tiling window manager
        pam_yubico.x86_64 \ # Pluggable Authentication Module for yubikeys
        spectre-meltdown-checker.noarch \ # Spectre & Meltdown checker
        wireguard-tools.x86_64 \ # VPN
        openvpn.x86_64 \ # VPN
        wine.x86_64 \ # windows compatibility layer
        pdfgrep.x86_64 # pdf searching tool

# clean up
sudo dnf clean all
