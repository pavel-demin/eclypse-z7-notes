set display_name {CDCE IIC}

set core [ipx::current_core]

set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core

core_parameter DATA_SIZE {DATA SIZE} {Size of the configuration data.}
core_parameter DATA_FILE {DATA FILE} {File with the configuration data.}
