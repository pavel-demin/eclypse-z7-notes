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

# CFG

# Create axi_cfg_register
cell pavel-demin:user:axi_cfg_register cfg_0 {
  CFG_DATA_WIDTH 320
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
}

# RX 0

# Create port_slicer
cell pavel-demin:user:port_slicer rst_slice_0 {
  DIN_WIDTH 320 DIN_FROM 7 DIN_TO 0
} {
  din cfg_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer cfg_slice_0 {
  DIN_WIDTH 320 DIN_FROM 25 DIN_TO 16
} {
  din cfg_0/cfg_data
  dout adc_cfg_o
}

# Create port_slicer
cell pavel-demin:user:port_slicer cfg_slice_1 {
  DIN_WIDTH 320 DIN_FROM 319 DIN_TO 32
} {
  din cfg_0/cfg_data
}

module rx_0 {
  source projects/sdr_receiver_hpsdr/rx.tcl
} {
  slice_0/din rst_slice_0/dout
  slice_1/din cfg_slice_1/dout
  slice_2/din cfg_slice_1/dout
  slice_3/din cfg_slice_1/dout
  slice_4/din cfg_slice_1/dout
  slice_5/din cfg_slice_1/dout
  slice_6/din cfg_slice_1/dout
  slice_7/din cfg_slice_1/dout
  slice_8/din cfg_slice_1/dout
  slice_9/din cfg_slice_1/dout
  slice_10/din cfg_slice_1/dout
  slice_11/din cfg_slice_1/dout
  slice_12/din cfg_slice_1/dout
  slice_13/din cfg_slice_1/dout
  slice_14/din cfg_slice_1/dout
  slice_15/din cfg_slice_1/dout
  slice_16/din cfg_slice_1/dout
  slice_17/din cfg_slice_1/dout
}

# STS

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 8
  IN0_WIDTH 16
  IN1_WIDTH 16
  IN2_WIDTH 16
  IN3_WIDTH 16
  IN4_WIDTH 16
  IN5_WIDTH 16
  IN6_WIDTH 16
  IN7_WIDTH 16
} {
  In0 rx_0/fifo_generator_0/rd_data_count
  In1 rx_0/fifo_generator_1/rd_data_count
  In2 rx_0/fifo_generator_2/rd_data_count
  In3 rx_0/fifo_generator_3/rd_data_count
  In4 rx_0/fifo_generator_4/rd_data_count
  In5 rx_0/fifo_generator_5/rd_data_count
  In6 rx_0/fifo_generator_6/rd_data_count
  In7 rx_0/fifo_generator_7/rd_data_count
}

# Create axi_sts_register
cell pavel-demin:user:axi_sts_register sts_0 {
  STS_DATA_WIDTH 128
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
} {
  sts_data concat_0/dout
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins sts_0/S_AXI]

assign_bd_address -range 4K -offset 0x40000000 [get_bd_addr_segs -of_objects [get_bd_intf_pins sts_0/S_AXI]]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins cfg_0/S_AXI]

assign_bd_address -range 4K -offset 0x40001000 [get_bd_addr_segs -of_objects [get_bd_intf_pins cfg_0/S_AXI]]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins writer_0/S_AXI]

assign_bd_address -range 4K -offset 0x40002000 [get_bd_addr_segs -of_objects [get_bd_intf_pins writer_0/S_AXI]]

for {set i 0} {$i <= 7} {incr i} {

  # Create all required interconnections
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
    Master /ps_0/M_AXI_GP0
    Clk Auto
  } [get_bd_intf_pins rx_0/reader_$i/S_AXI]

  assign_bd_address -range 4K -offset 0x4000[format %X [expr $i + 3]]000 [get_bd_addr_segs -of_objects [get_bd_intf_pins rx_0/reader_$i/S_AXI]]

}
