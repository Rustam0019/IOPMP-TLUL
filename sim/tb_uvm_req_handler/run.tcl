set library_file_list {	
    work {
		../../src/my_macros.svh
		../../src/config_pkg.sv
		../../src/top_pkg.sv
		../../src/tlul_pkg.sv
		../../src/iopmp_pkg.sv
		../../src/tlul_err_resp.sv
		../../src/tlul_success_resp.sv
		../../src/iopmp_req_handler_tlul.sv
		rh_file_pkg.sv
		intf_rh.sv
		uvm_top_rh.sv
		}
}

global fileList
set fileList {
		../../src/my_macros.svh
		../../src/config_pkg.sv
		../../src/top_pkg.sv
		../../src/tlul_pkg.sv
		../../src/iopmp_pkg.sv
		../../src/tlul_err_resp.sv
		../../src/tlul_success_resp.sv
		../../src/iopmp_req_handler_tlul.sv
		rh_file_pkg.sv
		intf_rh.sv
		uvm_top_rh.sv
}


# Define top level file
set top_level work.uvm_top_rh


proc AddWave {} {
	noview wave
	# add wave /*
	do ./wave.do
}
proc DeleteWave {} {
#	delete wave /*
}


proc cr  {fileList} {comp $fileList
			 restart
			 run -all}

proc r  {} {uplevel #0 source run.tcl}
proc rr {} {global last_compile_time
            set last_compile_time 0
            r                            }
proc q  {} {quit -force                  }


proc comp {library_file_list} {
		foreach {library file_list} $library_file_list {
				vlib $library
				foreach file $file_list {
					vlog -sv $file				
				}	
	}
}


# Prefer a fixed point font for the transcript
set PrefMain(font) {Courier 10 roman normal}

foreach {library file_list} $library_file_list {
		vlib $library
		foreach file $file_list {
			vlog -sv $file		
		}
}

vlog -sv rh_file_pkg.sv


# Load the simulation +acc
eval vopt +acc $top_level -o top
eval vsim -t ps top 
#-sv_seed random
#AddWave -sv_seed random 
AddWave
configure wave -signalnamewidth 1

# Run the simulation
run -all


puts {
Script commands are:
  r = Recompile changed and dependent files
 rr = Recompile everything
  q = Quit without confirmation
}

