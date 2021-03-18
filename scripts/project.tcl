
set project_name [lindex $argv 0]

set part_name [lindex $argv 1]

file delete -force tmp/$project_name.cache tmp/$project_name.hw tmp/$project_name.srcs tmp/$project_name.runs tmp/$project_name.xpr

create_project -part $part_name $project_name tmp

set_property IP_REPO_PATHS tmp/cores [current_project]

update_ip_catalog

set bd_path tmp/$project_name.srcs/sources_1/bd/system

create_bd_design system

source cfg/ports.tcl

proc cell {cell_vlnv cell_name {cell_props {}} {cell_ports {}}} {
  set cell [create_bd_cell -type ip -vlnv $cell_vlnv $cell_name]
  set prop_list {}
  foreach {prop_name prop_value} [uplevel 1 [list subst $cell_props]] {
    lappend prop_list CONFIG.$prop_name $prop_value
  }
  if {[llength $prop_list] > 1} {
    set_property -dict $prop_list $cell
  }
  foreach {local_name remote_name} [uplevel 1 [list subst $cell_ports]] {
    set local_port [get_bd_pins $cell_name/$local_name]
    set remote_port [get_bd_pins $remote_name]
    if {[llength $local_port] == 1 && [llength $remote_port] == 1} {
      connect_bd_net $local_port $remote_port
      continue
    }
    set local_port [get_bd_intf_pins $cell_name/$local_name]
    set remote_port [get_bd_intf_pins $remote_name]
    if {[llength $local_port] == 1 && [llength $remote_port] == 1} {
      connect_bd_intf_net $local_port $remote_port
      continue
    }
    error "** ERROR: can't connect $cell_name/$local_name and $remote_name"
  }
}

proc module {module_name module_body {module_ports {}}} {
  set bd [current_bd_instance .]
  current_bd_instance [create_bd_cell -type hier $module_name]
  eval $module_body
  current_bd_instance $bd
  foreach {local_name remote_name} [uplevel 1 [list subst $module_ports]] {
    set local_port [get_bd_pins $module_name/$local_name]
    set remote_port [get_bd_pins $remote_name]
    if {[llength $local_port] == 1 && [llength $remote_port] == 1} {
      connect_bd_net $local_port $remote_port
      continue
    }
    set local_port [get_bd_intf_pins $module_name/$local_name]
    set remote_port [get_bd_intf_pins $remote_name]
    if {[llength $local_port] == 1 && [llength $remote_port] == 1} {
      connect_bd_intf_net $local_port $remote_port
      continue
    }
    error "** ERROR: can't connect $module_name/$local_name and $remote_name"
  }
}

proc addr {offset range port master} {
  set object [get_bd_intf_pins $port]
  set segment [get_bd_addr_segs -of_objects $object]
  set config [list Master $master Clk Auto]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config $config $object
  assign_bd_address -offset $offset -range $range $segment
}

source projects/$project_name/block_design.tcl

rename cell {}
rename module {}
rename addr {}

if {[version -short] >= 2016.3} {
  set_property synth_checkpoint_mode None [get_files $bd_path/system.bd]
}

generate_target all [get_files $bd_path/system.bd]
make_wrapper -files [get_files $bd_path/system.bd] -top

add_files -norecurse $bd_path/hdl/system_wrapper.v

set files [glob -nocomplain projects/$project_name/*.v projects/$project_name/*.sv]
if {[llength $files] > 0} {
  add_files -norecurse $files
}

set files [glob -nocomplain cfg/*.xdc projects/$project_name/*.xdc]
if {[llength $files] > 0} {
  add_files -norecurse -fileset constrs_1 $files
}

set_property STRATEGY Flow_PerfOptimized_high [get_runs synth_1]
set_property STRATEGY Performance_NetDelay_high [get_runs impl_1]

close_project
