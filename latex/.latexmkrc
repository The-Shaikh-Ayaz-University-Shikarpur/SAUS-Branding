# Build SAUS slides and posters with LuaLaTeX.
# Run:  latexmk saus-slides-demo.tex   (switch to XeLaTeX with: latexmk -xelatex ...)
$pdf_mode = 4;
$lualatex = 'lualatex -interaction=nonstopmode -file-line-error %O %S';
