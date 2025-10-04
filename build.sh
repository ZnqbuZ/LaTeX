#!/bin/bash

log() {
    local BLUE="\033[34m"
    local RESET="\033[0m"
    echo -e "${BLUE}$*${RESET}"
}

DEBUG=0

while getopts 'v' opt; do
    case $opt in
      (v)   DEBUG=1;;
    esac
done

ENGINES="xelatex pdflatex"

WORK_DIR="precompile"
WORK_DIR="$(dirname "$(realpath "$0")")/${WORK_DIR}"

CLASSES="article book"

INTERACTION=$([ $DEBUG -eq 1 ] && echo "nonstopmode" || echo "batchmode")

OPT="-interaction=$INTERACTION"

if [ $INTERACTION = "batchmode" ]; then
    OPT="${OPT} -halt-on-error"
fi

log "Working directory: ${WORK_DIR}"
if [ ! -d "${WORK_DIR}" ]; then
	log "Working directory not found. Creating..."
	mkdir "${WORK_DIR}" || exit 1
fi

cd "${WORK_DIR}"

for class in ${CLASSES}; do
    log "$(printf '=%0.s' {1..50})"
    log "Generating ${class}.sty ..."
    CLASS_OPT="11pt"
    cat <<EOF > "${class}.sty"
\RequirePackage[OT1]{fontenc}

\documentclass[${CLASS_OPT}]{${class}}

\RequirePackage{../common}
EOF
    for engine in ${ENGINES}; do
        log "$(printf -- '-%.0s' {1..50})"
        log "Precompiling ${class}.sty with engine ${engine}..."
        ${engine} -ini $OPT -jobname=${class}.${engine} "&${engine} ${class}.sty\dump"
        if [ $? -ne 0 ]; then
            log "Error: Failed to precompile ${class}.sty"
            exit 1
        fi
    done
done

log "$(printf '=%0.s' {1..50})"
log "All done."
