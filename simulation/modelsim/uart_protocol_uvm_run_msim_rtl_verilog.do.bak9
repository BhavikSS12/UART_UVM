transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/BHAVIK/Desktop/Bhavik_clg/Projects/vlsi_projects/uart_uvm/rtl {C:/Users/BHAVIK/Desktop/Bhavik_clg/Projects/vlsi_projects/uart_uvm/rtl/uart_tx.sv}
vlog -sv -work work +incdir+C:/Users/BHAVIK/Desktop/Bhavik_clg/Projects/vlsi_projects/uart_uvm/rtl {C:/Users/BHAVIK/Desktop/Bhavik_clg/Projects/vlsi_projects/uart_uvm/rtl/uart_top.sv}
vlog -sv -work work +incdir+C:/Users/BHAVIK/Desktop/Bhavik_clg/Projects/vlsi_projects/uart_uvm/rtl {C:/Users/BHAVIK/Desktop/Bhavik_clg/Projects/vlsi_projects/uart_uvm/rtl/uart_rx.sv}

do "C:/Users/BHAVIK/Desktop/Bhavik_clg/Projects/vlsi_projects/uart_uvm/run_uart_uvm.do"
