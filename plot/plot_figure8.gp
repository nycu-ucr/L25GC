reset
set ylabel 'Latency(s)'
set style fill solid
set title 'Figure 8: Total control plane latency for different UE events'
set term png enhanced font 'Verdana,10'
set output 'Figure8.png'

plot [:][:0.300]'figure8.txt' using 2:xtic(1) with histogram title 'L25GC', \
'' using ($0-0.06):($2+0.001):2 with labels title ' ', \
'' using 3:xtic(1) with histogram title 'free5GC'  , \
'' using ($0+0.2):($3+0.001):3 with labels title ' '
