# `arxivify.sh`

Generates a zip *archive* to upload to *arXiv*.

It [strips all tex comments](https://arxiv.org/help/faq/whytex)
and includes only relevant asset files in the zip archive.

Usage:

```
latexmk -pdf mypaper.pdf
./arxivify.sh mypaper.pdf
```
