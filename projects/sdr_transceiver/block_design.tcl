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
}

# CFG

# Create axi_cfg_register
cell pavel-demin:user:axi_cfg_register cfg_0 {
  CFG_DATA_WIDTH 32
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 32 DIN_FROM 9 DIN_TO 0
} {
  din cfg_0/cfg_data
  dout adc_cfg_o
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 32 DIN_FROM 19 DIN_TO 16
} {
  din cfg_0/cfg_data
  dout dac_cfg_o
}

# ADC SPI

# Create axi_axis_writer
cell pavel-demin:user:axi_axis_writer writer_0 {
  AXI_DATA_WIDTH 32
} {
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_data_fifo
cell xilinx.com:ip:axis_data_fifo fifo_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  FIFO_DEPTH 1024
  HAS_WR_DATA_COUNT true
} {
  S_AXIS writer_0/M_AXIS
  s_axis_aclk pll_0/clk_out1
  s_axis_aresetn rst_0/peripheral_aresetn
}

# Create axis_spi
cell pavel-demin:user:axis_spi spi_0 {
  SPI_DATA_WIDTH 24
} {
  S_AXIS fifo_0/M_AXIS
  spi_data adc_spi_o
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# ADC

# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_1 {
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
  clk_in1 ps_0/FCLK_CLK0
}

# Create util_ds_buf
cell xilinx.com:ip:util_ds_buf obufds_0 {
  C_BUF_TYPE OBUFDS
} {
  OBUF_IN pll_1/clk_out1
  OBUF_DS_N adc_clk_n_o
  OBUF_DS_P adc_clk_p_o
}

# Create axis_zmod_dac
cell pavel-demin:user:axis_zmod_adc adc_0 {
  ADC_DATA_WIDTH 14
} {
  aclk pll_0/clk_out1
  adc_data adc_data_i
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 2
  M00_TDATA_REMAP {tdata[15:0]}
  M01_TDATA_REMAP {tdata[31:16]}
} {
  S_AXIS adc_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# DAC SPI

# Create axi_axis_writer
cell pavel-demin:user:axi_axis_writer writer_1 {
  AXI_DATA_WIDTH 32
} {
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_data_fifo
cell xilinx.com:ip:axis_data_fifo fifo_1 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  FIFO_DEPTH 1024
  HAS_WR_DATA_COUNT true
} {
  S_AXIS writer_1/M_AXIS
  s_axis_aclk pll_0/clk_out1
  s_axis_aresetn rst_0/peripheral_aresetn
}

# Create axis_spi
cell pavel-demin:user:axis_spi spi_1 {
  SPI_DATA_WIDTH 16
} {
  S_AXIS fifo_1/M_AXIS
  spi_data dac_spi_o
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# DAC

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 2
} {
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_zmod_dac
cell pavel-demin:user:axis_zmod_dac dac_0 {
  DAC_DATA_WIDTH 14
} {
  aclk pll_0/clk_out1
  locked pll_0/locked
  S_AXIS comb_0//M_AXIS
  dac_clk dac_clk_o
  dac_data dac_data_o
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins cfg_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]
set_property OFFSET 0x40000000 [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins writer_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_writer_0_reg0]
set_property OFFSET 0x40001000 [get_bd_addr_segs ps_0/Data/SEG_writer_0_reg0]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins writer_1/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_writer_1_reg0]
set_property OFFSET 0x40002000 [get_bd_addr_segs ps_0/Data/SEG_writer_1_reg0]

# TRX

module trx_0 {
  source projects/sdr_transceiver/trx.tcl
} {
  rx_0/mult_0/S_AXIS_A bcast_0/M00_AXIS
  tx_0/mult_0/M_AXIS_DOUT comb_0/S00_AXIS
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_0/cfg_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg01]
set_property OFFSET 0x40003000 [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg01]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_0/sts_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]
set_property OFFSET 0x40004000 [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_0/rx_0/reader_0/S_AXI]

set_property RANGE 32K [get_bd_addr_segs ps_0/Data/SEG_reader_0_reg0]
set_property OFFSET 0x40010000 [get_bd_addr_segs ps_0/Data/SEG_reader_0_reg0]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_0/tx_0/writer_0/S_AXI]

set_property RANGE 32K [get_bd_addr_segs ps_0/Data/SEG_writer_0_reg01]
set_property OFFSET 0x40018000 [get_bd_addr_segs ps_0/Data/SEG_writer_0_reg01]

module trx_1 {
  source projects/sdr_transceiver/trx.tcl
} {
  rx_0/mult_0/S_AXIS_A bcast_0/M01_AXIS
  tx_0/mult_0/M_AXIS_DOUT comb_0/S01_AXIS
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_1/cfg_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg02]
set_property OFFSET 0x40005000 [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg02]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_1/sts_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg01]
set_property OFFSET 0x40006000 [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg01]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_1/rx_0/reader_0/S_AXI]

set_property RANGE 32K [get_bd_addr_segs ps_0/Data/SEG_reader_0_reg01]
set_property OFFSET 0x40020000 [get_bd_addr_segs ps_0/Data/SEG_reader_0_reg01]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_1/tx_0/writer_0/S_AXI]

set_property RANGE 32K [get_bd_addr_segs ps_0/Data/SEG_writer_0_reg02]
set_property OFFSET 0x40028000 [get_bd_addr_segs ps_0/Data/SEG_writer_0_reg02]
