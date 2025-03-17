#!/bin/sh

cd "$(dirname "$(realpath "$0")")" || exit 1
echo "Current directory: $(pwd)"
echo "Precompiling header.sty and header.article.sty"
xelatex -ini -jobname=header "&xelatex header.sty\dump"
xelatex -ini -jobname=header.article "&xelatex header.article.sty\dump"
echo "Precompilation done, deleting auxiliary files..."
rm header.log header.article.log