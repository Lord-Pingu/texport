#!/bin/bash

printf "Finding all .tex files\n"
files=( `find . | grep "\.tex" | sed "/._export\.tex/d"` )

# delete ./master/master.tex
files=( ${files[@]/'./master/master.tex'} )

for f in ${files[@]}; do
    
    printf "processing %s\n" $f
    
    fout=${f/\.tex/_export\.tex}
    if [[ ! -f $fout ]]; then
        touch $fout
    fi

    # calcs fout's relative (r) path (p) to master.tex (m) (rpm)
    fout_rpm=` printf ".%s" $f | sed -E "s#(\.\/.*\/)[^\/]*\.tex#\1#" `

    # returns contents of doc between \begin{document} and \end{document}
    `cat $f | awk '/\\\begin{document}/{ f = 1; next }/\\\end{document}/{ f = 0 } f' > $fout`

    # update figure import so that its relative to ./master/master.tex
    `cat $fout | sed -E "s#(\\\includegraphics\[.*\]\{)(.*\.(png|pdf|jpg|jpeg)\})#\1$fout_rpm\2#" > $fout`

done

printf "pdflatex: compiling master/master.tex\n"
cd master; `pdflatex master.tex`; cd ..
printf "finished\n"