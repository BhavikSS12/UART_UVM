# UART UVM Simulation - Final Version (Fixed)

set PROJECT_PATH "C:/Users/BHAVIK/Desktop/Bhavik_clg/Projects/vlsi_projects/uart_uvm"
set MODELSIM_UVM "C:/intelFPGA_lite/20.1/modelsim_ase/verilog_src/uvm-1.2"

echo "=========================================="
echo "  UART UVM Complete Simulation"
echo "=========================================="

# Clean everything
quit -sim
if {[file exists work]} {
    vdel -lib work -all
}
if {[file exists uvm_lib]} {
    vdel -lib uvm_lib -all
}

# ========================================
# STEP 1: Compile UVM Library
# ========================================
echo ""
echo "Step 1: Compiling UVM 1.2 library..."
vlib uvm_lib
vmap uvm_lib uvm_lib

vlog -work uvm_lib \
     -sv \
     +incdir+${MODELSIM_UVM}/src \
     +define+UVM_NO_DPI \
     -timescale 1ns/1ns \
     ${MODELSIM_UVM}/src/uvm_pkg.sv

echo "✓ UVM library compiled"

# ========================================
# STEP 2: Create Work Library
# ========================================
echo ""
echo "Step 2: Creating work library..."
vlib work
vmap work work

# ========================================
# STEP 3: Compile RTL Design
# ========================================
echo ""
echo "Step 3: Compiling RTL design files..."
vlog -sv \
     ${PROJECT_PATH}/rtl/uart_tx.sv \
     ${PROJECT_PATH}/rtl/uart_rx.sv \
     ${PROJECT_PATH}/rtl/uart_top.sv

echo "✓ RTL compiled successfully"

# ========================================
# STEP 4: Compile Interface
# ========================================
echo ""
echo "Step 4: Compiling interface..."
vlog -sv \
     +incdir+${MODELSIM_UVM}/src \
     +incdir+${PROJECT_PATH}/tb \
     -L uvm_lib \
     ${PROJECT_PATH}/tb/uart_interface.sv

echo "✓ Interface compiled successfully"

# ========================================
# STEP 5: Compile Testbench Package
# ========================================
echo ""
echo "Step 5: Compiling testbench package..."
echo "(This includes all test files)"
vlog -sv \
     +incdir+${MODELSIM_UVM}/src \
     +incdir+${PROJECT_PATH}/tb \
     -L uvm_lib \
     ${PROJECT_PATH}/tb/uart_pkg.sv

echo "✓ Package compiled successfully"

# ========================================
# STEP 6: Compile Testbench Top
# ========================================
echo ""
echo "Step 6: Compiling testbench top..."
vlog -sv \
     +incdir+${MODELSIM_UVM}/src \
     +incdir+${PROJECT_PATH}/tb \
     -L uvm_lib \
     ${PROJECT_PATH}/tb/uart_tb_top.sv

echo "✓ Top module compiled successfully"

# ========================================
# STEP 7: Start Simulation
# ========================================
echo ""
echo "=========================================="
echo "  Starting Simulation"
echo "=========================================="

vsim -L uvm_lib \
     -voptargs=+acc \
     work.uart_tb_top \
     +UVM_TESTNAME=uart_random_test \
     +UVM_VERBOSITY=UVM_MEDIUM

# ========================================
# STEP 8: Add Waveforms
# ========================================
echo ""
echo "Adding signals to waveform..."

# Clock & Reset
add wave -divider "Clock & Reset"
add wave -position insertpoint sim:/uart_tb_top/clk

# Interface signals
add wave -divider "Interface Signals"
add wave -position insertpoint sim:/uart_tb_top/vif/rst_n
add wave -position insertpoint sim:/uart_tb_top/vif/tx_start
add wave -position insertpoint sim:/uart_tb_top/vif/tx_data
add wave -position insertpoint sim:/uart_tb_top/vif/tx_serial
add wave -position insertpoint sim:/uart_tb_top/vif/tx_done
add wave -position insertpoint sim:/uart_tb_top/vif/tx_active
add wave -position insertpoint sim:/uart_tb_top/vif/rx_serial
add wave -position insertpoint sim:/uart_tb_top/vif/rx_data
add wave -position insertpoint sim:/uart_tb_top/vif/rx_done
add wave -position insertpoint sim:/uart_tb_top/vif/parity_error
add wave -position insertpoint sim:/uart_tb_top/vif/frame_error

# DUT TX signals
add wave -divider "DUT - UART TX"
add wave -position insertpoint sim:/uart_tb_top/dut/u_uart_tx/state
add wave -position insertpoint sim:/uart_tb_top/dut/u_uart_tx/clk_count
add wave -position insertpoint sim:/uart_tb_top/dut/u_uart_tx/bit_index
add wave -position insertpoint sim:/uart_tb_top/dut/u_uart_tx/parity_bit

# DUT RX signals
add wave -divider "DUT - UART RX"
add wave -position insertpoint sim:/uart_tb_top/dut/u_uart_rx/state
add wave -position insertpoint sim:/uart_tb_top/dut/u_uart_rx/clk_count
add wave -position insertpoint sim:/uart_tb_top/dut/u_uart_rx/bit_index

# Configure wave window
configure wave -namecolwidth 300
configure wave -valuecolwidth 120
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# ========================================
# STEP 9: Run Simulation
# ========================================
echo ""
echo "=========================================="
echo "  Running Simulation"
echo "=========================================="
echo ""

run -all

# Zoom waveform to fit
wave zoom full

echo ""
echo "=========================================="
echo "  Simulation Complete!"
echo "=========================================="
echo ""
echo "Available Tests:"
echo "  - uart_random_test (default)"
echo "  - uart_sequential_test"
echo "  - uart_corner_test"
echo "  - uart_burst_test"
echo "  - uart_comprehensive_test"
echo ""
echo "To run a different test:"
echo "  quit -sim"
echo "  vsim -L uvm_lib work.uart_tb_top +UVM_TESTNAME=<test_name>"
echo "  add wave -r /*"
echo "  run -all"
echo "=========================================="