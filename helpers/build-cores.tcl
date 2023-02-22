set cores [list \
  axi_hub_v1_0 axis_constant_v1_0 axis_fifo_v2_0 axis_lfsr_v1_0 \
  axis_maxabs_finder_v1_0 axis_pps_counter_v1_0 axis_ram_writer_v1_0 \
  axis_spi_v1_0 axis_variable_v1_0 axis_zmod_adc_v1_0 axis_zmod_dac_v1_0 \
  cdce_gpio_v1_0 cdce_iic_v1_0 dac_gpio_v1_0 dsp48_v1_0 port_selector_v1_0 \
  port_slicer_v1_0 \
]

set part_name xc7z020clg484-1

foreach core_name $cores {
  set argv [list $core_name $part_name]
  source scripts/core.tcl
}
