# Complete UART UVM Simulation Script
# Usage: do run_complete.do

set UVM_PATH "C:/Users/BHAVIK/Downloads/uvm-core-main/uvm-core-main"
set TB_PATH "C:/Users/BHAVIK/Desktop/Bhavik_clg/Projects/vlsi_projects/uart_uvm/tb"
set RTL_PATH "C:/Users/BHAVIK/Desktop/Bhavik_clg/Projects/vlsi_projects/uart_uvm/rtl"

# Clean
quit -sim
vdel -lib work -all
if {[file exists uvm_lib]} {
    vdel -lib uvm_lib -all
}

# Create libraries
vlib work
vlib uvm_lib
vmap work work
vmap uvm_lib uvm_lib

# Compile UVM
echo "Compiling UVM..."
vlog -work uvm_lib -sv +incdir+${UVM_PATH}/src ${UVM_PATH}/src/uvm_pkg.sv

# Compile RTL
echo "Compiling RTL..."
vlog -sv ${RTL_PATH}/uart_tx.sv
vlog -sv ${RTL_PATH}/uart_rx.sv
vlog -sv ${RTL_PATH}/uart_top.sv

# Compile Interface
echo "Compiling Interface..."
vlog -sv +incdir+${UVM_PATH}/src +incdir+${TB_PATH} -L uvm_lib ${TB_PATH}/uart_interface.sv

# Compile Package
echo "Compiling Testbench Package..."
vlog -sv +incdir+${UVM_PATH}/src +incdir+${TB_PATH} -L uvm_lib ${TB_PATH}/uart_pkg.sv

# Compile Top
echo "Compiling Testbench Top..."
vlog -sv +incdir+${UVM_PATH}/src +incdir+${TB_PATH} -L uvm_lib ${TB_PATH}/uart_tb_top.sv

# Start simulation
echo "Starting simulation..."
vsim -L uvm_lib -voptargs=+acc work.uart_tb_top +UVM_TESTNAME=uart_random_test +UVM_VERBOSITY=UVM_MEDIUM

# Add waves
add wave -position insertpoint sim:/uart_tb_top/clk
add wave -position insertpoint sim:/uart_tb_top/vif/*
add wave -position insertpoint sim:/uart_tb_top/dut/*

# Configure wave
configure wave -namecolwidth 250
configure wave -valuecolwidth 100

# Run
echo "Running simulation..."
run -all

# Zoom
wave zoom full

echo ""
echo "=========================================="
echo "  Simulation Complete!"
echo "=========================================="