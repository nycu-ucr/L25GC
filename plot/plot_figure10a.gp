set xlabel "packet size (Bytes)"
set ylabel "Throughput (Gbps)"
set style fill solid
set boxwidth 0.5
set term png enhanced font 'Verdana,10'
set output 'Figure10a.png'

plot [:][:12.0] 'figure10.txt' using 2:xtic(1) with histogram title 'L25GC (DL)', \
'' using ($0-0.2):($2+0.001):2 with labels title ' ', \
'' using 3:xtic(1) with histogram title 'L25GC (UL)', \
'' using ($0-0.1):($3+0.001):3 with labels title ' ', \
'' using 4:xtic(1) with histogram title 'free5GC (DL)', \
'' using ($0+0.1):($4+0.001):4 with labels title ' ', \
'' using 5:xtic(1) with histogram title 'free5GC (UL)', \
'' using ($0+0.2):($5+0.001):5 with labels title ' '
