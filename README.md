# `arxivify.sh`

Generates a zip *archive* to upload to *arXiv*.

It [strips all tex comments](https://arxiv.org/help/faq/whytex)
and includes only relevant asset files in the zip archive.

Usage:

```
latexmk -pdf mypaper.tex
./arxivify.sh mypaper.pdf

# or set figure directory name manually (default: "figures")
FIG_DIRNAME="mydir" ./arxivify.sh mypaper.pdf
```

See Also:

https://github.com/google-research/arxiv-latex-cleaner
