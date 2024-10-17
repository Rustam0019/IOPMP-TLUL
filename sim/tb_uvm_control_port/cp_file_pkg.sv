//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2024 01:21:54 PM
// Design Name: 
// Module Name: cp_file_pkg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


package cp_file_pkg;
    
    `timescale 1ns/1ps   
    `include "uvm_macros.svh"
    import uvm_pkg::*;  
    import top_pkg::*;
    import tlul_pkg::*; 
    import config_pkg::*;
    import iopmp_pkg::*; 

    localparam IOPMPRegions           = 6;
    localparam IOPMPMemoryDomains     = 3; 
    localparam NUM_MASTERS            = 3;
       
    `include "uvm_transaction_cp.sv" 
    `include "uvm_sequence_cp.sv"       
                                                                                                                                
    `include "uvm_drv_cp.sv"             
    `include "uvm_mon_cp.sv"          
                                                                                                  
    `include "uvm_sco_cp.sv"                                
                            
    `include "uvm_agent_cp.sv"           
    `include "uvm_env_cp.sv"                          
                                                                                  
    `include "uvm_test_cp.sv"


endpackage
