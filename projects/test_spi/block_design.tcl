# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 100.0
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 100.0
  JITTER_SEL Min_O_Jitter
  JITTER_OPTIONS PS
  CLKIN1_UI_JITTER 600
  USE_RESET false
} {
  clk_in1 adc_dco_i
}

# Create processing_system7
cell xilinx.com:ip:processing_system7 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/eclypse_z7.xml
} {
  M_AXI_GP0_ACLK pll_0/clk_out1
}

# Create cdce_iic
cell pavel-demin:user:cdce_iic iic_0 {
  DATA_SIZE 132
  DATA_FILE [pwd]/cfg/cdce_100.mem
} {
  iic cdce_iic_tri_io
  aclk ps_0/FCLK_CLK0
}

# Create cdce_gpio
cell pavel-demin:user:cdce_gpio gpio_0 {} {
  gpio cdce_gpio_tri_io
  aclk ps_0/FCLK_CLK0
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in const_0/dout
  dcm_locked pll_0/locked
  slowest_sync_clk pll_0/clk_out1
}

# HUB

# Create axi_cfg_register
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 32
  STS_DATA_WIDTH 32
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# FIFO

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 1024
} {
  S_AXIS hub_0/M00_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# PMOD

# Delete input/output port
delete_bd_objs [get_bd_ports pmod_a_tri_io]

# Create output port
create_bd_port -dir O -from 2 -to 0 pmod_a_tri_io

# SPI

# Create axis_spi
cell pavel-demin:user:axis_spi spi_0 {
  SPI_DATA_WIDTH 24
} {
  S_AXIS fifo_0/M_AXIS
  spi_data pmod_a_tri_io
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}
