set cores [list \
  axi_axis_reader_v1_0 axi_axis_writer_v1_0 axi_cfg_register_v1_0 \
  axis_constant_v1_0 axis_fifo_v1_0 axis_lfsr_v1_0 axis_spi_v1_0 \
  axi_sts_register_v1_0 axis_variable_v1_0 axis_zmod_adc_v1_0 \
  axis_zmod_dac_v1_0 dna_reader_v1_0 port_selector_v1_0 port_slicer_v1_0 \
]

set part_name xc7z020clg484-1

foreach core_name $cores {
  set argv [list $core_name $part_name]
  source scripts/core.tcl
}
