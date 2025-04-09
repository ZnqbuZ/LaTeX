#!/bin/sh

WORK_DIR="precompile"
CLASSES="article book"

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
    xelatex -ini -interaction=batchmode -jobname=$class "&xelatex ${class}.sty\dump"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to precompile ${class}.sty"
        exit 1
    fi
done