`timescale 1ns/1ps   
`include "uvm_macros.svh"
import uvm_pkg::*;  
import top_pkg::*;
import tlul_pkg::*;
import config_pkg::*;
import iopmp_pkg::*;
import cp_file_pkg::*;



module uvm_top_cp;
    
    
    logic clk = 1'b0;
    logic rst = 1'b0;
    
    intf_cp vif ();
    
    
    

    always #50 clk <= ~clk; //1.50 20 nsec, 10nsec
    assign vif.clk      = clk;
    //assign vif.reset    = rst;  ????
    


    integer k = 16;
    
    iopmp_control_port #(
        .IOPMPRegions(cp_file_pkg::IOPMPRegions),
        .IOPMPMemoryDomains(cp_file_pkg::IOPMPMemoryDomains),
        .NUM_MASTERS(cp_file_pkg::NUM_MASTERS)
    ) io_control_port_0(
        .clk(vif.clk),
        .reset(vif.reset),
        .mst_req_i(vif.mst_req_i),
        .slv_rsp_o(vif.slv_rsp_o),
        .error_report_i(vif.error_report_i),
        .error_report_o(vif.error_report_o),
        .entry_conf_table(vif.entry_conf_table),
        .entry_addr_table(vif.entry_addr_table),
        .mdcfg_table(vif.mdcfg_table),
        .srcmd_en_table(vif.srcmd_en_table)
    );
    
    initial begin
        uvm_config_db#(virtual intf_cp)::set(null, "*", "vif", vif);
        run_test("uvm_test_cp");
    end

    
    
    
endmodule