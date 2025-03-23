#!/bin/sh

cd "$(dirname "$(realpath "$0")")" || exit 1
ln -sf $(pwd)/09-LaTeX.conf /etc/fonts/conf.d/09-LaTeX.conf
ln -sf $(ls -d /usr/local/texlive/*/texmf-var/fonts/conf/texlive-fontconfig.conf 2>/dev/null | tail -n 1) /etc/fonts/conf.d/09-texlive.conf 
fc-cache -f -s -v