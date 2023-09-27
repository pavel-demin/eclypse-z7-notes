set files [glob -nocomplain cores/*.v]

set part_name xc7z020clg484-1

foreach file_name $files {
  set core_name [file rootname [file tail $file_name]]
  set argv [list $core_name $part_name]
  source scripts/core.tcl
}
