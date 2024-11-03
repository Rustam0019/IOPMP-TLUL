add wave -noupdate -expand -group CONTROL_PORT /uvm_top_cp/io_control_port_0/clk
add wave -noupdate -expand -group CONTROL_PORT /uvm_top_cp/io_control_port_0/reset
add wave -noupdate -expand -group CONTROL_PORT /uvm_top_cp/io_control_port_0/mst_req_i
add wave -noupdate -expand -group CONTROL_PORT /uvm_top_cp/io_control_port_0/slv_rsp_o
add wave -noupdate -expand -group CONTROL_PORT /uvm_top_cp/io_control_port_0/error_report_i
add wave -noupdate -expand -group CONTROL_PORT /uvm_top_cp/io_control_port_0/error_report_o
add wave -noupdate -expand -group CONTROL_PORT /uvm_top_cp/io_control_port_0/entry_conf_table
add wave -noupdate -expand -group CONTROL_PORT /uvm_top_cp/io_control_port_0/entry_addr_table
add wave -noupdate -expand -group CONTROL_PORT /uvm_top_cp/io_control_port_0/mdcfg_table
add wave -noupdate -expand -group CONTROL_PORT /uvm_top_cp/io_control_port_0/srcmd_en_table
add wave -noupdate -expand -group CONTROL_PORT /uvm_top_cp/io_control_port_0/prio_entry_num

add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/VERSION
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/IMPLEMENTATION
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/HWCFG0
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/HWCFG1
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/HWCFG2
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/ENTRYOFFSET
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/MDCFGLCK
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/ENTRYLCK
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/ERR_REQID
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/ERR_REQADDR
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/ERR_REQADDRH
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/ERR_REQINFO
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/ERR_CFG
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/MDCFG
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/SRCMD_EN
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/SRCMD_ENH
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/ENTRY_ADDR
add wave -noupdate -expand -group REGISTERS /uvm_top_cp/io_control_port_0/ENTRY_CFG

WaveRestoreCursors {{Cursor 1} {70965 ps} 0} {{Cursor 2} {484084 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 202
configure wave -valuecolwidth 126
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {19174 ps} {48532 ps}


