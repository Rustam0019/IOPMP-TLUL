`timescale 1ns/1ps   
`include "uvm_macros.svh"
import uvm_pkg::*;  
import top_pkg::*;
import tlul_pkg::*;
import config_pkg::*;
import iopmp_pkg::*;
import rh_file_pkg::*;



module uvm_top_rh;
    
    
    logic clk = 1'b0;
    //logic rst = 1'b0;
    
    intf_rh vif ();
    
    
    

    always #50 clk <= ~clk; // 10 MHz
    assign vif.clk      = clk;

    
    iopmp_req_handler_tlul #(
        .IOPMPNumChan(rh_file_pkg::IOPMPNumChan)
    ) io_req_handler_tlul_0(
        .clk(vif.clk),
        .rst(vif.reset),
        .mst_req_i(vif.mst_req_i),
        .mst_rsp_o(vif.mst_rsp_o),
        .slv_rsp_i(vif.slv_rsp_i),
        .slv_req_o(vif.slv_req_o),
        .iopmp_permission_denied(vif.iopmp_permission_denied),
        .entry_violated_index_i(vif.entry_violated_index_i),
        .ERR_CFG(vif.ERR_CFG),
        .entry_conf(vif.entry_conf),
        .iopmp_check_addr_o(vif.iopmp_check_addr_o),
        .iopmp_check_access_o(vif.iopmp_check_access_o),
        .rrid(vif.rrid)
    );
    
    initial begin
        uvm_config_db#(virtual intf_rh)::set(null, "*", "vif", vif);
        run_test("uvm_test_rh");
    end

    
    
    
endmodule