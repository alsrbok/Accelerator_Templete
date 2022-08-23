onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+sram_1440kb -L blk_mem_gen_v8_4_5 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.sram_1440kb xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {sram_1440kb.udo}

run -all

endsim

quit -force
