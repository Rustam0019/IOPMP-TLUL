set library_file_list {	
    work {
		../../src/config_pkg.sv
		../../src/top_pkg.sv
		../../src/tlul_pkg.sv
		../../src/iopmp_pkg.sv
		../../src/iopmp_reg_handler.sv
		../../src/iopmp_control_port.sv
		intf_cp.sv
		cp_file_pkg.sv
		uvm_top_cp.sv
		}
}

global fileList
set fileList {
		../../src/config_pkg.sv
		../../src/top_pkg.sv
		../../src/tlul_pkg.sv
		../../src/iopmp_pkg.sv
		../../src/iopmp_reg_handler.sv
		../../src/iopmp_control_port.sv
		intf_cp.sv
		cp_file_pkg.sv
		uvm_top_cp.sv
}



# CCFLAGS for DPI compile
#set ccflags "-O3 -std=c99"

# Define top level file
set top_level work.uvm_top_cp


proc AddWave {} {
	noview wave
	# add wave /*
	do ./wave.do
}
proc DeleteWave {} {
#	delete wave /*
}

# After sourcing the script from ModelSim for the
# first time use these commands to recompile.

proc cr  {fileList} {comp $fileList
			 restart
			 run -all}

proc r  {} {uplevel #0 source run.tcl}
proc rr {} {global last_compile_time
            set last_compile_time 0
            r                            }
proc q  {} {quit -force                  }

# proc comp {fileList} {foreach file $fileList {
# 						vlog -sv $file } 
# 					 }


proc comp {library_file_list} {
		global time_now
		set time_now [clock seconds]
		if [catch {set last_compile_time}] {
				set last_compile_time 0
		}
		foreach {library file_list} $library_file_list {
				vlib $library
				foreach file $file_list {
						if { $last_compile_time < [file mtime $file] } {
								if [regexp {.vhdl?$} $file] {
										vcom -93 $file
								} else {
										vlog -sv $file +define+ARM_UD_MODEL+define+ARM_UD_DP=#0.05+define+ARM_UD_CP=#0.05+define+SIM_CTREE=1
										
                                        #vlog -sv $file +define+ARM_UD_MODEL+define+ARM_UD_DP=#0.025+define+ARM_UD_CP=#0.025+define+SIM=1+SIM_CTREE=1
								}
								set last_compile_time 0
						}
				}
		}
}

###+define+SIM=1

#Does this installation support Tk?
set tk_ok 1
if [catch {package require Tk}] {set tk_ok 0}

# Prefer a fixed point font for the transcript
set PrefMain(font) {Courier 10 roman normal}

# Compile out of date files
set time_now [clock seconds]
if [catch {set last_compile_time}] {
		set last_compile_time 0
}
foreach {library file_list} $library_file_list {
		vlib $library
		foreach file $file_list {
				if { $last_compile_time < [file mtime $file] } {
						if [regexp {.vhdl?$} $file] {
								vcom -93 $file
						} else {
								vlog -sv $file +define+ARM_UD_MODEL+define+ARM_UD_DP=#0.05+define+ARM_UD_CP=#0.05+define+SIM_CTREE=1
							
                            #	vlog -sv $file +define+ARM_UD_MODEL+define+ARM_UD_DP=#0.025+define+ARM_UD_CP=#0.025+define+SIM=1+SIM_CTREE=1
						}
						set last_compile_time 0
				}
		}
}

vlog -sv cp_file_pkg.sv +define+ARM_UD_MODEL+define+ARM_UD_DP=#0.05+define+ARM_UD_CP=#0.05+define+SIM_CTREE=1

set last_compile_time $time_now

# vlib work
# vlog uvm_datax8.sv
#qrun -work work uvm_datax8.sv

# Load the simulation +acc
eval vopt +acc $top_level -o top
eval vsim -t ps top -sv_seed random
#AddWave -sv_seed random 
AddWave
configure wave -signalnamewidth 1

# Run the simulation
run -all

# If waves are required
# if [llength $wave_patterns] {
if $tk_ok {wave zoomfull}
# }

puts {
Script commands are:
  r = Recompile changed and dependent files
 rr = Recompile everything
  q = Quit without confirmation
}

# How long since project began?
if {[file isfile start_time.txt] == 0} {
		set f [open start_time.txt w]
		puts $f "Start time was [clock seconds]"
		close $f
} else {
		set f [open start_time.txt r]
		set line [gets $f]
		close $f
		regexp {\d+} $line start_time
		set total_time [expr ([clock seconds]-$start_time)/60]
		puts "Project time is $total_time minutes"
}