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

CLASSES="article book beamer"

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

declare -A LANGUAGES=(
    [en]="english"
    [fr]="french"
    [cn]="chinese"
)

for class in ${CLASSES}; do
    if [[ "$class" == "beamer" ]]; then
        langs=("${!LANGUAGES[@]}")
    else
        langs=("default")
    fi

    for lang in "${langs[@]}"; do
        log "$(printf '=%0.s' {1..50})"
        if [[ "$class" == "beamer" ]]; then
            filename="${lang}.${class}"
            CLASS_OPT="${LANGUAGES[$lang]:-$lang}, aspectratio=169"
        else
            filename="${class}"
            CLASS_OPT="11pt, a4paper"
        fi

        log "Generating ${filename}.sty ..."
        cat <<EOF > "${filename}.sty"
\def\precompile{}
\PassOptionsToPackage{tbtags}{amsmath}
\RequirePackage[T1]{fontenc}
\documentclass[${CLASS_OPT}]{${class}}
\RequirePackage{../config}
EOF
        for engine in ${ENGINES}; do
            log "$(printf -- '-%.0s' {1..50})"
            log "Precompiling ${filename}.sty with engine ${engine}..."
            ${engine} -ini $OPT -jobname=${filename}.${engine} "&${engine} ${filename}.sty\dump"
            if [ $? -ne 0 ]; then
                log "Error: Failed to precompile ${filename}.sty"
                exit 1
            fi
        done
    done
done

log "$(printf '=%0.s' {1..50})"
log "All done."
