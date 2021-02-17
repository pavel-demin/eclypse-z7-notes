### clock input

create_bd_port -dir I clk_i

### LED

create_bd_port -dir O -from 5 -to 0 led_o

### PMOD

create_bd_port -dir IO -from 7 -to 0 pmod_a_tri_io
create_bd_port -dir IO -from 7 -to 0 pmod_b_tri_io

### ADC

create_bd_port -dir I -from 13 -to 0 adc_data_i

create_bd_port -dir I adc_dco_i

create_bd_port -dir O adc_clk_p_o
create_bd_port -dir O adc_clk_n_o

create_bd_port -dir O -from 2 -to 0 adc_spi_o

create_bd_port -dir O -from 9 -to 0 adc_cfg_o

### DAC

create_bd_port -dir O -from 13 -to 0 dac_data_o

create_bd_port -dir O dac_clk_o

create_bd_port -dir O -from 2 -to 0 dac_spi_o

create_bd_port -dir O -from 3 -to 0 dac_cfg_o
