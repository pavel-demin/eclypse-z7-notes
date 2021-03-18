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

# LED

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_0 {
  Output_Width 32
} {
  CLK pll_0/clk_out1
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_0 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 26 DOUT_WIDTH 1
} {
  Din cntr_0/Q
  Dout led_o
}

# STS

# Create dna_reader
cell pavel-demin:user:dna_reader dna_0 {} {
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 1
  IN0_WIDTH 64
} {
  In0 dna_0/dna_data
}

# Create axi_sts_register
cell pavel-demin:user:axi_sts_register sts_0 {
  STS_DATA_WIDTH 64
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
} {
  sts_data concat_0/dout
}

addr 0x40000000 4K sts_0/S_AXI /ps_0/M_AXI_GP0
