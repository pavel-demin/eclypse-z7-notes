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
  PCW_USE_S_AXI_HP0 1
} {
  M_AXI_GP0_ACLK pll_0/clk_out1
  S_AXI_HP0_ACLK pll_0/clk_out1
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
  CFG_DATA_WIDTH 224
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 224 DIN_FROM 0 DIN_TO 0
} {
  din cfg_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 224 DIN_FROM 1 DIN_TO 1
} {
  din cfg_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_2 {
  DIN_WIDTH 224 DIN_FROM 11 DIN_TO 8
} {
  din cfg_0/cfg_data
  dout dac_cfg_o
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_3 {
  DIN_WIDTH 224 DIN_FROM 25 DIN_TO 16
} {
  din cfg_0/cfg_data
  dout adc_cfg_o
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_4 {
  DIN_WIDTH 224 DIN_FROM 47 DIN_TO 32
} {
  din cfg_0/cfg_data
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

# Create axis_zmod_dac
cell pavel-demin:user:axis_zmod_dac dac_0 {
  DAC_DATA_WIDTH 14
} {
  aclk pll_0/clk_out1
  locked pll_0/locked
  s_axis_tvalid const_0/dout
  dac_clk dac_clk_o
  dac_data dac_data_o
}

# DDS

for {set i 0} {$i <= 3} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer slice_[expr $i + 5] {
    DIN_WIDTH 224 DIN_FROM [expr 32 * $i + 95] DIN_TO [expr 32 * $i + 64]
  } {
    din cfg_0/cfg_data
  }

  # Create axis_constant
  cell pavel-demin:user:axis_constant phase_$i {
    AXIS_TDATA_WIDTH 32
  } {
    cfg_data slice_[expr $i + 5]/dout
    aclk pll_0/clk_out1
  }

  # Create dds_compiler
  cell xilinx.com:ip:dds_compiler dds_$i {
    DDS_CLOCK_RATE 100
    SPURIOUS_FREE_DYNAMIC_RANGE 138
    FREQUENCY_RESOLUTION 0.1
    PHASE_INCREMENT Streaming
    HAS_PHASE_OUT false
    PHASE_WIDTH 30
    OUTPUT_WIDTH 24
    DSP48_USE Minimal
    NEGATIVE_SINE true
  } {
    S_AXIS_PHASE phase_$i/M_AXIS
    aclk pll_0/clk_out1
  }

}

# RX

# Create axis_lfsr
cell pavel-demin:user:axis_lfsr lfsr_0 {} {
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

for {set i 0} {$i <= 3} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer adc_slice_$i {
    DIN_WIDTH 32 DIN_FROM [expr 16 * ($i / 2) + 13] DIN_TO [expr 16 * ($i / 2)]
  } {
    din adc_0/m_axis_tdata
  }

  # Create port_slicer
  cell pavel-demin:user:port_slicer dds_slice_$i {
    DIN_WIDTH 48 DIN_FROM [expr 24 * ($i % 2) + 23] DIN_TO [expr 24 * ($i % 2)]
  } {
    din dds_[expr $i / 2]/m_axis_data_tdata
  }

  # Create xbip_dsp48_macro
  cell xilinx.com:ip:xbip_dsp48_macro mult_$i {
    INSTRUCTION1 RNDSIMPLE(A*B+CARRYIN)
    A_WIDTH.VALUE_SRC USER
    B_WIDTH.VALUE_SRC USER
    OUTPUT_PROPERTIES User_Defined
    A_WIDTH 24
    B_WIDTH 14
    P_WIDTH 25
  } {
    A dds_slice_$i/dout
    B adc_slice_$i/dout
    CARRYIN lfsr_0/m_axis_tdata
    CLK pll_0/clk_out1
  }

  # Create axis_variable
  cell pavel-demin:user:axis_variable rate_$i {
    AXIS_TDATA_WIDTH 16
  } {
    cfg_data slice_4/dout
    aclk pll_0/clk_out1
    aresetn rst_0/peripheral_aresetn
  }

  # Create cic_compiler
  cell xilinx.com:ip:cic_compiler cic_$i {
    INPUT_DATA_WIDTH.VALUE_SRC USER
    FILTER_TYPE Decimation
    NUMBER_OF_STAGES 6
    SAMPLE_RATE_CHANGES Programmable
    MINIMUM_RATE 5
    MAXIMUM_RATE 64
    FIXED_OR_INITIAL_RATE 8
    INPUT_SAMPLE_FREQUENCY 100
    CLOCK_FREQUENCY 100
    INPUT_DATA_WIDTH 24
    QUANTIZATION Truncation
    OUTPUT_DATA_WIDTH 32
    USE_XTREME_DSP_SLICE false
    HAS_ARESETN true
  } {
    s_axis_data_tdata mult_$i/P
    s_axis_data_tvalid const_0/dout
    S_AXIS_CONFIG rate_$i/M_AXIS
    aclk pll_0/clk_out1
    aresetn rst_0/peripheral_aresetn
  }

}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  NUM_SI 4
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  S02_AXIS cic_2/M_AXIS_DATA
  S03_AXIS cic_3/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn slice_0/dout
}

# Create fir_compiler
cell xilinx.com:ip:fir_compiler fir_0 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 32
  COEFFICIENTVECTOR {-1.6372889915e-08, -4.6217374326e-08, -3.1430655528e-10, 3.0228204761e-08, 1.7487459055e-08, 3.1945258385e-08, -5.0989680977e-09, -1.4863953312e-07, -8.2668507031e-08, 3.0698727935e-07, 3.0078089673e-07, -4.6261005010e-07, -7.0011979614e-07, 5.3345670192e-07, 1.3080119515e-06, -4.0228512781e-07, -2.1063306593e-06, -7.0166019130e-08, 3.0112222540e-06, 1.0195755111e-06, -3.8611447149e-06, -2.5420218237e-06, 4.4195225624e-06, 4.6526108168e-06, -4.3971232811e-06, -7.2472033322e-06, 3.4959405357e-06, 1.0077764307e-05, -1.4718100090e-06, -1.2752308532e-05, -1.7926956512e-06, 1.4768034675e-05, 6.2186848526e-06, -1.5581398090e-05, -1.1482290103e-05, 1.4710655296e-05, 1.7003281145e-05, -1.1862368502e-05, -2.1993383371e-05, 7.0499386906e-06, 2.5559029610e-05, -6.8992667160e-07, -2.6867281936e-05, -6.3639254297e-06, 2.5350417927e-05, 1.2871648274e-05, -2.0918901639e-05, -1.7359637646e-05, 1.4138792502e-05, 1.8373277904e-05, -6.3252717882e-06, -1.4807361951e-05, -4.9342907207e-07, 6.2685797153e-06, 3.7728529274e-06, 6.5943512235e-06, -8.1793863128e-07, -2.1869712296e-05, -1.0707727609e-05, 3.6342769927e-05, 3.2177088790e-05, -4.5721807011e-05, -6.3436064361e-05, 4.5093206355e-05, 1.0231637728e-04, -2.9673420141e-05, -1.4442499566e-04, -4.2752495144e-06, 1.8327444489e-04, 5.8465061079e-05, -2.1083158269e-04, -1.3170904184e-04, 2.1848886560e-04, 2.1933847447e-04, -1.9838847053e-04, -3.1309143737e-04, 1.4494552769e-04, 4.0160677906e-04, -5.6346626218e-05, -4.7158308807e-04, -6.4250983750e-05, 5.0955512774e-04, 2.0810071603e-04, -5.0413618534e-04, -3.6112538196e-04, 4.4832934542e-04, 5.0501474019e-04, -3.4181578501e-04, -6.1954149390e-04, 1.9241030415e-04, 6.8559781364e-04, -1.6549014162e-05, -6.8881632491e-04, -1.6162599187e-04, 6.2324099568e-04, 3.1274192076e-04, -4.9444720762e-04, -4.0618716964e-04, 3.2146089712e-04, 4.1531752117e-04, -1.3688301312e-04, -3.2332250298e-04, -1.5225701906e-05, 1.2897187934e-04, 8.3890066091e-05, 1.4868152013e-04, -1.8067928923e-05, -4.6765824368e-04, -2.2490070875e-04, 7.6286965541e-04, 6.6929762148e-04, -9.5018356270e-04, -1.3120918540e-03, 9.3342061750e-04, 2.1149404316e-03, -6.1523212730e-04, -2.9992510770e-03, -8.9271515363e-05, 3.8453047550e-03, 1.2372405254e-03, -4.4962951447e-03, -2.8426702107e-03, 4.7676370156e-03, 4.8625571058e-03, -4.4612998571e-03, -7.1863124617e-03, 3.3842752380e-03, 9.6298180574e-03, -1.3696937924e-03, -1.1934905520e-02, -1.7013455799e-03, 1.3773873288e-02, 5.8782503868e-03, -1.4760285901e-02, -1.1126174245e-02, 1.4456538596e-02, 1.7311193750e-02, -1.2381571742e-02, -2.4193683070e-02, 8.0023526406e-03, 3.1422783851e-02, -6.9255098190e-04, -3.8524037742e-02, -1.0383552162e-02, 4.4853516959e-02, 2.6567615852e-02, -4.9431348804e-02, -5.0501411586e-02, 5.0305772087e-02, 8.8584000900e-02, -4.1561839869e-02, -1.6068966987e-01, -8.3823006177e-03, 3.5453273647e-01, 5.5040803615e-01, 3.5453273647e-01, -8.3823006177e-03, -1.6068966987e-01, -4.1561839869e-02, 8.8584000900e-02, 5.0305772087e-02, -5.0501411586e-02, -4.9431348804e-02, 2.6567615852e-02, 4.4853516959e-02, -1.0383552162e-02, -3.8524037742e-02, -6.9255098190e-04, 3.1422783851e-02, 8.0023526406e-03, -2.4193683070e-02, -1.2381571742e-02, 1.7311193750e-02, 1.4456538596e-02, -1.1126174245e-02, -1.4760285901e-02, 5.8782503868e-03, 1.3773873288e-02, -1.7013455799e-03, -1.1934905520e-02, -1.3696937924e-03, 9.6298180574e-03, 3.3842752380e-03, -7.1863124617e-03, -4.4612998571e-03, 4.8625571058e-03, 4.7676370156e-03, -2.8426702107e-03, -4.4962951447e-03, 1.2372405254e-03, 3.8453047550e-03, -8.9271515363e-05, -2.9992510770e-03, -6.1523212730e-04, 2.1149404316e-03, 9.3342061750e-04, -1.3120918540e-03, -9.5018356270e-04, 6.6929762148e-04, 7.6286965541e-04, -2.2490070875e-04, -4.6765824368e-04, -1.8067928923e-05, 1.4868152013e-04, 8.3890066091e-05, 1.2897187934e-04, -1.5225701906e-05, -3.2332250298e-04, -1.3688301312e-04, 4.1531752117e-04, 3.2146089712e-04, -4.0618716964e-04, -4.9444720762e-04, 3.1274192076e-04, 6.2324099568e-04, -1.6162599187e-04, -6.8881632491e-04, -1.6549014162e-05, 6.8559781364e-04, 1.9241030415e-04, -6.1954149390e-04, -3.4181578501e-04, 5.0501474019e-04, 4.4832934542e-04, -3.6112538196e-04, -5.0413618534e-04, 2.0810071603e-04, 5.0955512774e-04, -6.4250983750e-05, -4.7158308807e-04, -5.6346626218e-05, 4.0160677906e-04, 1.4494552769e-04, -3.1309143737e-04, -1.9838847053e-04, 2.1933847447e-04, 2.1848886560e-04, -1.3170904184e-04, -2.1083158269e-04, 5.8465061079e-05, 1.8327444489e-04, -4.2752495144e-06, -1.4442499566e-04, -2.9673420141e-05, 1.0231637728e-04, 4.5093206355e-05, -6.3436064361e-05, -4.5721807011e-05, 3.2177088790e-05, 3.6342769927e-05, -1.0707727609e-05, -2.1869712296e-05, -8.1793863128e-07, 6.5943512235e-06, 3.7728529274e-06, 6.2685797153e-06, -4.9342907207e-07, -1.4807361951e-05, -6.3252717882e-06, 1.8373277904e-05, 1.4138792502e-05, -1.7359637646e-05, -2.0918901639e-05, 1.2871648274e-05, 2.5350417927e-05, -6.3639254297e-06, -2.6867281936e-05, -6.8992667160e-07, 2.5559029610e-05, 7.0499386906e-06, -2.1993383371e-05, -1.1862368502e-05, 1.7003281145e-05, 1.4710655296e-05, -1.1482290103e-05, -1.5581398090e-05, 6.2186848526e-06, 1.4768034675e-05, -1.7926956512e-06, -1.2752308532e-05, -1.4718100090e-06, 1.0077764307e-05, 3.4959405357e-06, -7.2472033322e-06, -4.3971232811e-06, 4.6526108168e-06, 4.4195225624e-06, -2.5420218237e-06, -3.8611447149e-06, 1.0195755111e-06, 3.0112222540e-06, -7.0166019130e-08, -2.1063306593e-06, -4.0228512781e-07, 1.3080119515e-06, 5.3345670192e-07, -7.0011979614e-07, -4.6261005010e-07, 3.0078089673e-07, 3.0698727935e-07, -8.2668507031e-08, -1.4863953312e-07, -5.0989680977e-09, 3.1945258385e-08, 1.7487459055e-08, 3.0228204761e-08, -3.1430655528e-10, -4.6217374326e-08, -1.6372889915e-08}
  COEFFICIENT_WIDTH 24
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_CHANNELS 1
  NUMBER_PATHS 4
  SAMPLE_FREQUENCY 20
  CLOCK_FREQUENCY 100
  OUTPUT_ROUNDING_MODE Convergent_Rounding_to_Even
  OUTPUT_WIDTH 18
  HAS_ARESETN true
} {
  S_AXIS_DATA comb_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_0/dout
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter subset_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 12
  M_TDATA_NUM_BYTES 8
  TDATA_REMAP {tdata[87:72],tdata[63:48],tdata[39:24],tdata[15:0]}
} {
  S_AXIS fir_0/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn slice_0/dout
}

# DMA

# Create xlconstant
cell xilinx.com:ip:xlconstant const_1 {
  CONST_WIDTH 32
  CONST_VAL 1040187392
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer writer_2 {
  ADDR_WIDTH 16
} {
  S_AXIS subset_0/M_AXIS
  M_AXI ps_0/S_AXI_HP0
  cfg_data const_1/dout
  aclk pll_0/clk_out1
  aresetn slice_1/dout
}

# GEN

for {set i 0} {$i <= 1} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer slice_[expr $i + 9] {
    DIN_WIDTH 224 DIN_FROM [expr 16 * $i + 207] DIN_TO [expr 16 * $i + 192]
  } {
    din cfg_0/cfg_data
  }

  # Create xbip_dsp48_macro
  cell xilinx.com:ip:xbip_dsp48_macro mult_[expr $i + 4] {
    INSTRUCTION1 RNDSIMPLE(A*B+CARRYIN)
    A_WIDTH.VALUE_SRC USER
    B_WIDTH.VALUE_SRC USER
    OUTPUT_PROPERTIES User_Defined
    A_WIDTH 24
    B_WIDTH 16
    P_WIDTH 15
  } {
    A dds_[expr $i + 2]/m_axis_data_tdata
    B slice_[expr $i + 7]/dout
    CARRYIN lfsr_0/m_axis_tdata
    CLK pll_0/clk_out1
  }

}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 2
  IN0_WIDTH 16
  IN1_WIDTH 16
} {
  In0 mult_4/P
  In1 mult_5/P
  dout dac_0/s_axis_tdata
}

# STS

# Create axi_sts_register
cell pavel-demin:user:axi_sts_register sts_0 {
  STS_DATA_WIDTH 32
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
} {
  sts_data writer_2/sts_data
}

addr 0x40000000 4K sts_0/S_AXI /ps_0/M_AXI_GP0

addr 0x40001000 4K cfg_0/S_AXI /ps_0/M_AXI_GP0

addr 0x40002000 4K writer_0/S_AXI /ps_0/M_AXI_GP0

addr 0x40003000 4K writer_1/S_AXI /ps_0/M_AXI_GP0

assign_bd_address [get_bd_addr_segs ps_0/S_AXI_HP0/HP0_DDR_LOWOCM]
