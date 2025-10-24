# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 122.88
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 122.88
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
  PCW_USE_S_AXI_ACP 1
  PCW_USE_DEFAULT_ACP_USER_VAL 1
} {
  M_AXI_GP0_ACLK pll_0/clk_out1
  S_AXI_ACP_ACLK pll_0/clk_out1
}

# Create cdce_iic
cell pavel-demin:user:cdce_iic iic_0 {
  DATA_SIZE 132
  DATA_FILE cdce_122_88.mem
} {
  iic cdce_iic_tri_io
  aclk ps_0/FCLK_CLK0
}

# Create cdce_gpio
cell pavel-demin:user:cdce_gpio gpio_0 {} {
  gpio cdce_gpio_tri_io
  aclk ps_0/FCLK_CLK0
}

# Create dac_gpio
cell pavel-demin:user:dac_gpio gpio_1 {} {
  gpio dac_tri_io
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

# Create axi_hub
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 224
  STS_DATA_WIDTH 32
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 224 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 224 DIN_FROM 1 DIN_TO 1
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_2 {
  DIN_WIDTH 224 DIN_FROM 31 DIN_TO 16
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_3 {
  DIN_WIDTH 224 DIN_FROM 63 DIN_TO 32
} {
  din hub_0/cfg_data
}

# ADC SPI

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

# Create axis_zmod_dac
cell pavel-demin:user:axis_zmod_adc adc_0 {
  ADC_DATA_WIDTH 14
} {
  aclk pll_0/clk_out1
  adc_data adc_data_i
}

# DAC SPI

# Create axis_data_fifo
cell pavel-demin:user:axis_fifo fifo_1 {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 1024
} {
  S_AXIS hub_0/M01_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
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
  cell pavel-demin:user:port_slicer slice_[expr $i + 4] {
    DIN_WIDTH 224 DIN_FROM [expr 32 * $i + 95] DIN_TO [expr 32 * $i + 64]
  } {
    din hub_0/cfg_data
  }

  # Create axis_constant
  cell pavel-demin:user:axis_constant phase_$i {
    AXIS_TDATA_WIDTH 32
  } {
    cfg_data slice_[expr $i + 4]/dout
    aclk pll_0/clk_out1
  }

  # Create dds_compiler
  cell xilinx.com:ip:dds_compiler dds_$i {
    DDS_CLOCK_RATE 122.88
    SPURIOUS_FREE_DYNAMIC_RANGE 138
    FREQUENCY_RESOLUTION 0.2
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

for {set i 0} {$i <= 3} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer adc_slice_$i {
    DIN_WIDTH 32 DIN_FROM [expr 16 * ($i / 2) + 15] DIN_TO [expr 16 * ($i / 2)]
  } {
    din adc_0/m_axis_tdata
  }

  # Create port_slicer
  cell pavel-demin:user:port_slicer dds_slice_$i {
    DIN_WIDTH 48 DIN_FROM [expr 24 * ($i % 2) + 23] DIN_TO [expr 24 * ($i % 2)]
  } {
    din dds_[expr $i / 2]/m_axis_data_tdata
  }

  # Create dsp48
  cell pavel-demin:user:dsp48 mult_$i {
    A_WIDTH 24
    B_WIDTH 14
    P_WIDTH 24
  } {
    A dds_slice_$i/dout
    B adc_slice_$i/dout
    CLK pll_0/clk_out1
  }

  # Create axis_variable
  cell pavel-demin:user:axis_variable rate_$i {
    AXIS_TDATA_WIDTH 16
  } {
    cfg_data slice_2/dout
    aclk pll_0/clk_out1
    aresetn slice_0/dout
  }

  # Create cic_compiler
  cell xilinx.com:ip:cic_compiler cic_$i {
    INPUT_DATA_WIDTH.VALUE_SRC USER
    FILTER_TYPE Decimation
    NUMBER_OF_STAGES 6
    SAMPLE_RATE_CHANGES Programmable
    MINIMUM_RATE 6
    MAXIMUM_RATE 64
    FIXED_OR_INITIAL_RATE 6
    INPUT_SAMPLE_FREQUENCY 122.88
    CLOCK_FREQUENCY 122.88
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
    aresetn slice_0/dout
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
  COEFFICIENTVECTOR {-4.4259364517e-08, 1.9591721996e-08, 3.9165053708e-08, 2.1406462646e-09, 1.2052492783e-08, -4.5013401668e-08, -1.4089840167e-07, 1.0508605332e-07, 3.8614063144e-07, -1.6962155598e-07, -7.9205170106e-07, 2.1439203919e-07, 1.4052963799e-06, -2.0155826029e-07, -2.2704135733e-06, 7.8629401964e-08, 3.4239612299e-06, 2.2090577791e-07, -4.8876255152e-06, -7.7473981259e-07, 6.6607223185e-06, 1.6659615536e-06, -8.7135517981e-06, -2.9756394892e-06, 1.0979674068e-05, 4.7696189258e-06, -1.3353111614e-05, -7.0849633658e-06, 1.5686844209e-05, 9.9128783675e-06, -1.7796185361e-05, -1.3180470768e-05, 1.9467341747e-05, 1.6732376064e-05, -2.0472101098e-05, -2.0314219567e-05, 2.0588741921e-05, 2.3559759142e-05, -1.9629123914e-05, -2.5984125748e-05, 1.7470873159e-05, 2.6985152480e-05, -1.4093321406e-05, -2.5855044887e-05, 9.6143622400e-06, 2.1801675802e-05, -4.3325049262e-06, -1.3996658009e-05, -1.2575302784e-06, 1.6098602473e-06, 6.4296824087e-06, 1.6117124720e-05, -1.0225189283e-05, -3.9799166581e-05, 1.1463461508e-05, 6.9826338157e-05, -8.7756790171e-06, -1.0628037429e-04, 6.6317031068e-07, 1.4885386188e-04, 1.4416443242e-05, -1.9678010632e-04, -3.7935668632e-05, 2.4878070347e-04, 7.1156563057e-05, -3.0304009809e-04, -1.1496736534e-04, 3.5721505009e-04, 1.6969989566e-04, -4.0849927717e-04, -2.3497592473e-04, 4.5365981819e-04, 3.0943492809e-04, -4.8927929477e-04, -3.9064017139e-04, 5.1190132167e-04, 4.7489513444e-04, -5.1830069089e-04, -5.5713330578e-04, 5.0579103358e-04, 6.3085777460e-04, -4.7257480791e-04, -6.8814579710e-04, 4.1812368863e-04, 7.1972628687e-04, -3.4357890673e-04, -7.1513982989e-04, 2.5215458011e-04, 6.6298268452e-04, -1.4953058135e-04, -5.5123503265e-04, 4.4221570172e-05, 3.6766258177e-04, 5.2036227029e-05, -1.0046690177e-04, -1.2430817358e-04, -2.6156554413e-04, 1.5382160285e-04, 7.2808916378e-04, -1.1810266933e-04, -1.3067522292e-03, -9.1797008756e-06, 2.0025860977e-03, 2.5828998186e-04, -2.8174266976e-03, -6.6351755561e-04, 3.7493825352e-03, 1.2633536870e-03, -4.7923666907e-03, -2.1008643117e-03, 5.9356940473e-03, 3.2244157936e-03, -7.1637379988e-03, -4.6890058045e-03, 8.4556181929e-03, 6.5586229442e-03, -9.7848494141e-03, -8.9105938427e-03, 1.1117680139e-02, 1.1840522627e-02, -1.2414193018e-02, -1.5476302731e-02, 1.3623301949e-02, 1.9996186081e-02, -1.4678198164e-02, -2.5664920730e-02, 1.5484270202e-02, 3.2901945040e-02, -1.5891399706e-02, -4.2420992869e-02, 1.5624461958e-02, 5.5544678033e-02, -1.4085272221e-02, -7.5010079690e-02, 9.6739968517e-03, 1.0742995096e-01, 3.2799116389e-03, -1.7298142407e-01, -5.6493493430e-02, 3.5894940737e-01, 5.9997309227e-01, 3.5894940737e-01, -5.6493493430e-02, -1.7298142407e-01, 3.2799116389e-03, 1.0742995096e-01, 9.6739968517e-03, -7.5010079690e-02, -1.4085272221e-02, 5.5544678033e-02, 1.5624461958e-02, -4.2420992869e-02, -1.5891399706e-02, 3.2901945040e-02, 1.5484270202e-02, -2.5664920730e-02, -1.4678198164e-02, 1.9996186081e-02, 1.3623301949e-02, -1.5476302731e-02, -1.2414193018e-02, 1.1840522627e-02, 1.1117680139e-02, -8.9105938427e-03, -9.7848494141e-03, 6.5586229442e-03, 8.4556181929e-03, -4.6890058045e-03, -7.1637379988e-03, 3.2244157936e-03, 5.9356940473e-03, -2.1008643117e-03, -4.7923666907e-03, 1.2633536870e-03, 3.7493825352e-03, -6.6351755561e-04, -2.8174266976e-03, 2.5828998186e-04, 2.0025860977e-03, -9.1797008756e-06, -1.3067522292e-03, -1.1810266933e-04, 7.2808916378e-04, 1.5382160285e-04, -2.6156554413e-04, -1.2430817358e-04, -1.0046690177e-04, 5.2036227029e-05, 3.6766258177e-04, 4.4221570172e-05, -5.5123503265e-04, -1.4953058135e-04, 6.6298268452e-04, 2.5215458011e-04, -7.1513982989e-04, -3.4357890673e-04, 7.1972628687e-04, 4.1812368863e-04, -6.8814579710e-04, -4.7257480791e-04, 6.3085777460e-04, 5.0579103358e-04, -5.5713330578e-04, -5.1830069089e-04, 4.7489513444e-04, 5.1190132167e-04, -3.9064017139e-04, -4.8927929477e-04, 3.0943492809e-04, 4.5365981819e-04, -2.3497592473e-04, -4.0849927717e-04, 1.6969989566e-04, 3.5721505009e-04, -1.1496736534e-04, -3.0304009809e-04, 7.1156563057e-05, 2.4878070347e-04, -3.7935668632e-05, -1.9678010632e-04, 1.4416443242e-05, 1.4885386188e-04, 6.6317031068e-07, -1.0628037429e-04, -8.7756790171e-06, 6.9826338157e-05, 1.1463461508e-05, -3.9799166581e-05, -1.0225189283e-05, 1.6117124720e-05, 6.4296824087e-06, 1.6098602473e-06, -1.2575302784e-06, -1.3996658009e-05, -4.3325049262e-06, 2.1801675802e-05, 9.6143622400e-06, -2.5855044887e-05, -1.4093321406e-05, 2.6985152480e-05, 1.7470873159e-05, -2.5984125748e-05, -1.9629123914e-05, 2.3559759142e-05, 2.0588741921e-05, -2.0314219567e-05, -2.0472101098e-05, 1.6732376064e-05, 1.9467341747e-05, -1.3180470768e-05, -1.7796185361e-05, 9.9128783675e-06, 1.5686844209e-05, -7.0849633658e-06, -1.3353111614e-05, 4.7696189258e-06, 1.0979674068e-05, -2.9756394892e-06, -8.7135517981e-06, 1.6659615536e-06, 6.6607223185e-06, -7.7473981259e-07, -4.8876255152e-06, 2.2090577791e-07, 3.4239612299e-06, 7.8629401964e-08, -2.2704135733e-06, -2.0155826029e-07, 1.4052963799e-06, 2.1439203919e-07, -7.9205170106e-07, -1.6962155598e-07, 3.8614063144e-07, 1.0508605332e-07, -1.4089840167e-07, -4.5013401668e-08, 1.2052492783e-08, 2.1406462646e-09, 3.9165053708e-08, 1.9591721996e-08, -4.4259364517e-08}
  COEFFICIENT_WIDTH 24
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_CHANNELS 1
  NUMBER_PATHS 4
  SAMPLE_FREQUENCY 20.48
  CLOCK_FREQUENCY 122.88
  OUTPUT_ROUNDING_MODE Convergent_Rounding_to_Even
  OUTPUT_WIDTH 18
  M_DATA_HAS_TREADY true
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
  CONST_WIDTH 16
  CONST_VAL 65535
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer writer_0 {
  ADDR_WIDTH 16
  AXI_ID_WIDTH 3
  AXIS_TDATA_WIDTH 64
  FIFO_WRITE_DEPTH 512
} {
  S_AXIS subset_0/M_AXIS
  M_AXI ps_0/S_AXI_ACP
  min_addr slice_3/dout
  cfg_data const_1/dout
  sts_data hub_0/sts_data
  aclk pll_0/clk_out1
  aresetn slice_1/dout
}

# GEN

for {set i 0} {$i <= 1} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer slice_[expr $i + 8] {
    DIN_WIDTH 224 DIN_FROM [expr 16 * $i + 207] DIN_TO [expr 16 * $i + 192]
  } {
    din hub_0/cfg_data
  }

  # Create dsp48
  cell pavel-demin:user:dsp48 mult_[expr $i + 4] {
    A_WIDTH 24
    B_WIDTH 16
    P_WIDTH 14
  } {
    A dds_[expr $i + 2]/m_axis_data_tdata
    B slice_[expr $i + 8]/dout
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
