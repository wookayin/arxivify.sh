#!/bin/bash
# Usage: arxivify.sh icml19_mypaper.pdf
# after you have built the target pdf using pdflatex.


TARGET="$1"
TARGET_DIR="_arxiv"

# fig_dirname: name of the directory where all figures are in
if [ -z "$FIG_DIRNAME" ]; then
    FIG_DIRNAME="figures"
fi

# source tex files
SOURCES=$(ls *.tex)

# target: the filename of target pdf, e.g. 'xxxxx.pdf'
if [[ ! -f "$TARGET" ]] ; then
    echo "Error: specify target file that exists";
    exit 1
fi
if [[ ! $TARGET =~ ^.*\.pdf$ ]] ; then
    echo "Error: target file should be xxxx.pdf";
    exit 1
fi

# ---------------------------------------------------------------

RESET="\033[0m"
BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"

JOBNAME=${TARGET##*/}
JOBNAME=${JOBNAME%.pdf}
echo -e "${GREEN}JOBNAME: $JOBNAME\nFIG_DIRNAME: $FIG_DIRNAME${WHITE}\n"

# die on error
set -e

rm -rf $TARGET_DIR
mkdir -p $TARGET_DIR/

# copy resources and assets
echo -e "${YELLOW}[*] Copying resources ...${RESET}"
rsync --verbose -R ${SOURCES} *.sty $TARGET_DIR/

# copy generated bbl files
cp -v ${TARGET/.pdf/.bbl} $TARGET_DIR/

# strip comments -- https://arxiv.org/help/faq/whytex
echo -e "${YELLOW}[*] Stripping all tex comments ...${RESET}"
for f in $TARGET_DIR/*.tex; do
    echo "    $f";
    perl -pe 's/(^|[^\\])%.*/\1%/' $f > $f.tmp; mv $f.tmp $f;
    sed -i '' '/^\\begin{comment}/,/^\\end{comment}/d' $f;
    sed -i '' '/^\\iffalse/,/^\\fi/d' $f;
done

# copy figures (only that are included in the stripped tex)
# ASSUMES all figures are stored in "figures/" folder
echo -e "${YELLOW}[*] Copying figures ...${RESET}"
mkdir -p "$TARGET_DIR/$FIG_DIRNAME"
for f in `cat $TARGET_DIR/*.tex | sed -n -E "s|^.*{(\./){0,1}${FIG_DIRNAME}/(.*\.(pdf\|png\|jpg))}.*$|\2|p"`; do \
    echo "    ${FIG_DIRNAME}/$f"; \
    rsync -R "${FIG_DIRNAME}/$f" $TARGET_DIR/; \
done

cd $TARGET_DIR

# create .zip ball
echo -e "${YELLOW}[*] Making zip archive and running a test build ...${RESET}"
zip -r "$JOBNAME.zip" *

# run a test build, and revoke if fails
latexmk -nobibtex -pdf -pdflatex="pdflatex -interaction=nonstopmode" \
    $JOBNAME > /dev/null || (rm -rf *.zip; exit 1;)

echo -e "\n\n${GREEN}=== Done ===${RESET}"
cd -
tree $TARGET_DIR/ || true

echo -e "\n${GREEN}You are all set! Upload $TARGET_DIR/$JOBNAME.zip.${RESET}"
