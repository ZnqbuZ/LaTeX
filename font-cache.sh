#!/bin/sh

cd "$(dirname "$(realpath "$0")")" || exit 1

rm -f /etc/fonts/conf.d/09-LaTeX.conf /etc/fonts/conf.d/09-texlive.conf

cat <<EOF > /etc/fonts/conf.d/09-LaTeX.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
	<dir>$(pwd)/fonts</dir>
</fontconfig>
EOF

ln -sf $(ls -d /usr/local/texlive/*/texmf-var/fonts/conf/texlive-fontconfig.conf 2>/dev/null | tail -n 1) /etc/fonts/conf.d/09-texlive.conf

fc-cache -f -s -v
