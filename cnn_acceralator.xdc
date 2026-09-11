# ============================================================================
# XDC: cnn_artix7_demo.xdc
# Board: Digilent Arty A7-100T
# FPGA: XC7A100T-1CSG324C
# Clock: 100 MHz
# ============================================================================

# 100 MHz oscillator on Arty A7
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {clk}]
create_clock -name sys_clk -period 10.000 -waveform {0 5} [get_ports {clk}]

# User switches
set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
set_property -dict { PACKAGE_PIN C11 IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
set_property -dict { PACKAGE_PIN C10 IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]

# BTN0 = start
# BTN1 = reset
set_property -dict { PACKAGE_PIN D9 IOSTANDARD LVCMOS33 } [get_ports {btn_start}]
set_property -dict { PACKAGE_PIN C9 IOSTANDARD LVCMOS33 } [get_ports {reset}]

# User LEDs: LED0..LED3
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports {led_result[0]}]
set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [get_ports {led_result[1]}]
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports {led_result[2]}]
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {led_result[3]}]

# Conservative output drive/slew
set_property DRIVE 8 [get_ports {led_result[*]}]
set_property SLEW SLOW [get_ports {led_result[*]}]
