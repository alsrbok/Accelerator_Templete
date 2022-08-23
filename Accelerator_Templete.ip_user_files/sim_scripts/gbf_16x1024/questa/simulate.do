onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib gbf_16x1024_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {gbf_16x1024.udo}

run -all

quit -force
