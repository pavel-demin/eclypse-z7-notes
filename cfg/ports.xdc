# clock input

set_property IOSTANDARD LVCMOS33 [get_ports clk_i]
set_property PACKAGE_PIN D18 [get_ports clk_i]

### LED

set_property IOSTANDARD LVCMOS33 [get_ports {led_o[*]}]
set_property SLEW SLOW [get_ports {led_o[*]}]
set_property DRIVE 4 [get_ports {led_o[*]}]

set_property PACKAGE_PIN B17 [get_ports {led_o[0]}]
set_property PACKAGE_PIN B16 [get_ports {led_o[1]}]
set_property PACKAGE_PIN A17 [get_ports {led_o[2]}]
set_property PACKAGE_PIN A19 [get_ports {led_o[3]}]
set_property PACKAGE_PIN A18 [get_ports {led_o[4]}]
set_property PACKAGE_PIN A16 [get_ports {led_o[5]}]

### PMOD

set_property IOSTANDARD LVCMOS33 [get_ports {pmod_a_tri_io[*]}]

set_property PACKAGE_PIN B15 [get_ports {pmod_a_tri_io[0]}]
set_property PACKAGE_PIN C15 [get_ports {pmod_a_tri_io[1]}]
set_property PACKAGE_PIN D15 [get_ports {pmod_a_tri_io[2]}]
set_property PACKAGE_PIN E16 [get_ports {pmod_a_tri_io[3]}]
set_property PACKAGE_PIN E15 [get_ports {pmod_a_tri_io[4]}]
set_property PACKAGE_PIN F17 [get_ports {pmod_a_tri_io[5]}]
set_property PACKAGE_PIN F16 [get_ports {pmod_a_tri_io[6]}]
set_property PACKAGE_PIN G16 [get_ports {pmod_a_tri_io[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {pmod_b_tri_io[*]}]

set_property PACKAGE_PIN G15 [get_ports {pmod_b_tri_io[0]}]
set_property PACKAGE_PIN D16 [get_ports {pmod_b_tri_io[1]}]
set_property PACKAGE_PIN D17 [get_ports {pmod_b_tri_io[2]}]
set_property PACKAGE_PIN E18 [get_ports {pmod_b_tri_io[3]}]
set_property PACKAGE_PIN F18 [get_ports {pmod_b_tri_io[4]}]
set_property PACKAGE_PIN G17 [get_ports {pmod_b_tri_io[5]}]
set_property PACKAGE_PIN H18 [get_ports {pmod_b_tri_io[6]}]
set_property PACKAGE_PIN H17 [get_ports {pmod_b_tri_io[7]}]

### ADC

set_property IOSTANDARD LVCMOS18 [get_ports {adc_data_i[*]}]

set_property PACKAGE_PIN N22 [get_ports {adc_data_i[0]}]
set_property PACKAGE_PIN L21 [get_ports {adc_data_i[1]}]
set_property PACKAGE_PIN R16 [get_ports {adc_data_i[2]}]
set_property PACKAGE_PIN J18 [get_ports {adc_data_i[3]}]
set_property PACKAGE_PIN K18 [get_ports {adc_data_i[4]}]
set_property PACKAGE_PIN L19 [get_ports {adc_data_i[5]}]
set_property PACKAGE_PIN L18 [get_ports {adc_data_i[6]}]
set_property PACKAGE_PIN L22 [get_ports {adc_data_i[7]}]
set_property PACKAGE_PIN K20 [get_ports {adc_data_i[8]}]
set_property PACKAGE_PIN P16 [get_ports {adc_data_i[9]}]
set_property PACKAGE_PIN K19 [get_ports {adc_data_i[10]}]
set_property PACKAGE_PIN J22 [get_ports {adc_data_i[11]}]
set_property PACKAGE_PIN J21 [get_ports {adc_data_i[12]}]
set_property PACKAGE_PIN P22 [get_ports {adc_data_i[13]}]

set_property IOSTANDARD LVCMOS18 [get_ports adc_dco_i]
set_property PACKAGE_PIN M19 [get_ports adc_dco_i]

set_property IOSTANDARD LVCMOS18 [get_ports {adc_spi_o[*]}]

set_property PACKAGE_PIN R18 [get_ports {adc_spi_o[0]}]
set_property PACKAGE_PIN T18 [get_ports {adc_spi_o[1]}]
set_property PACKAGE_PIN M21 [get_ports {adc_spi_o[2]}]

### CDCE GPIO

set_property IOSTANDARD LVCMOS18 [get_ports {cdce_tri_io[*]}]

set_property PACKAGE_PIN P17 [get_ports {cdce_tri_io[0]}]
set_property PACKAGE_PIN T16 [get_ports {cdce_tri_io[1]}]
set_property PACKAGE_PIN T19 [get_ports {cdce_tri_io[2]}]
set_property PACKAGE_PIN P18 [get_ports {cdce_tri_io[3]}]
set_property PACKAGE_PIN N15 [get_ports {cdce_tri_io[4]}]

### CDCE IIC

set_property IOSTANDARD LVCMOS18 [get_ports IIC_0_0_*_io]

set_property PACKAGE_PIN T17 [get_ports IIC_0_0_scl_io]
set_property PACKAGE_PIN R19 [get_ports IIC_0_0_sda_io]

### DAC

set_property IOSTANDARD LVCMOS18 [get_ports {dac_data_o[*]}]

set_property PACKAGE_PIN Y19 [get_ports {dac_data_o[0]}]
set_property PACKAGE_PIN Y18 [get_ports {dac_data_o[1]}]
set_property PACKAGE_PIN AB22 [get_ports {dac_data_o[2]}]
set_property PACKAGE_PIN AB20 [get_ports {dac_data_o[3]}]
set_property PACKAGE_PIN AA18 [get_ports {dac_data_o[4]}]
set_property PACKAGE_PIN AA19 [get_ports {dac_data_o[5]}]
set_property PACKAGE_PIN Y21 [get_ports {dac_data_o[6]}]
set_property PACKAGE_PIN Y20 [get_ports {dac_data_o[7]}]
set_property PACKAGE_PIN V15 [get_ports {dac_data_o[8]}]
set_property PACKAGE_PIN V14 [get_ports {dac_data_o[9]}]
set_property PACKAGE_PIN AB15 [get_ports {dac_data_o[10]}]
set_property PACKAGE_PIN AB14 [get_ports {dac_data_o[11]}]
set_property PACKAGE_PIN W13 [get_ports {dac_data_o[12]}]
set_property PACKAGE_PIN V13 [get_ports {dac_data_o[13]}]

set_property IOSTANDARD LVCMOS18 [get_ports dac_clk_o]
set_property PACKAGE_PIN W16 [get_ports dac_clk_o]

set_property IOSTANDARD LVCMOS18 [get_ports {dac_spi_o[*]}]

set_property PACKAGE_PIN Y14 [get_ports {dac_spi_o[0]}]
set_property PACKAGE_PIN AA13 [get_ports {dac_spi_o[1]}]
set_property PACKAGE_PIN AA14 [get_ports {dac_spi_o[2]}]

set_property IOSTANDARD LVCMOS18 [get_ports {dac_tri_io[*]}]

set_property PACKAGE_PIN Y13 [get_ports {dac_tri_io[0]}]
set_property PACKAGE_PIN AA22 [get_ports {dac_tri_io[1]}]
set_property PACKAGE_PIN W15 [get_ports {dac_tri_io[2]}]
set_property PACKAGE_PIN Y15 [get_ports {dac_tri_io[3]}]
