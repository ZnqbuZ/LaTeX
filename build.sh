#!/bin/sh

DEBUG=0

while getopts 'v' opt; do
    case $opt in
      (v)   DEBUG=1;;
    esac
done

WORK_DIR="precompile"
CLASSES="article book"

INTERACTION=$([ $DEBUG -eq 1 ] && echo "nonstopmode" || echo "batchmode")

OPT="-interaction=$INTERACTION"

if [ $INTERACTION = "batchmode" ]; then
    OPT="${OPT} -halt-on-error"
fi

cd "$(dirname "$(realpath "$0")")/${WORK_DIR}" || exit 1
echo "Working directory: $(pwd)"
for class in ${CLASSES}; do
    echo "Generating ${class}.sty ..."
    CLASS_OPT="11pt"
    cat <<EOF > "${class}.sty"
% xelatex -ini -jobname=${class} "&xelatex ${class}.sty\dump"

\RequirePackage[OT1]{fontenc}

\documentclass[${CLASS_OPT}]{${class}}

\RequirePackage{../common}
EOF
    echo "Precompiling ${class}.sty ..."
    xelatex -ini $OPT -jobname=$class "&xelatex ${class}.sty\dump"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to precompile ${class}.sty"
        exit 1
    fi
done