reset
set ylabel 'Latency(ms)'
set style fill solid
set title 'Figure 7: Latency of single control plane message between UPF/SMF'
set term png enhanced font 'Verdana,10'
set output 'Figure7.png'

plot [:][:2.0]'figure7.txt' using 2:xtic(1) with histogram title 'L25GC', \
'' using ($0-0.1):($2+0.001):2 with labels title ' ', \
'' using 3:xtic(1) with histogram title 'free5GC'  , \
'' using ($0+0.1):($3+0.0015):3 with labels title ' '
