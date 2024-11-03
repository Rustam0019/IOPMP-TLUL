`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 11:26:03 AM
// Design Name: 
// Module Name: tb_control_port
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

import top_pkg::*;
import tlul_pkg::*;
import config_pkg::*;
import iopmp_pkg::*;

module tb_control_port;
    
    localparam IOPMPRegions           = 6;
    localparam IOPMPMemoryDomains     = 3; 
    localparam NUM_MASTERS            = 3;
    
    
    logic clk = 1'b0;
    logic rst = 1'b0;
    
    tl_h2d_t          mst_req_i;
    tl_d2h_t          slv_rsp_o;
    
    
    error_registers_t                     error_report_i;
    error_registers_t                     error_report_o;    
    
    iopmp_pkg::entry_cfg                  entry_conf_table  [IOPMPRegions];
    logic [33:0]                          entry_addr_table  [IOPMPRegions];
    logic [15:0]                          mdcfg_table       [IOPMPMemoryDomains];
    logic [31:0]                          srcmd_en_table    [NUM_MASTERS];
    
    integer k = 16;
    
    iopmp_control_port #(
        .IOPMPRegions(IOPMPRegions),
        .IOPMPMemoryDomains(IOPMPMemoryDomains),
        .NUM_MASTERS(NUM_MASTERS)
    ) io_control_port_0(
        .clk(clk),
        .reset(rst),
        .mst_req_i(mst_req_i),
        .slv_rsp_o(slv_rsp_o),
        .error_report_i(error_report_i),
        .error_report_o(error_report_o),
        .entry_conf_table(entry_conf_table),
        .entry_addr_table(entry_addr_table),
        .mdcfg_table(mdcfg_table),
        .srcmd_en_table(srcmd_en_table)
    );
    
    
    task rand_64bit_number(output logic [63:0] num);
        num = $urandom() << 32 | $urandom();
    endtask
    
    task automatic iopmp_reg_write (input logic  [top_pkg::TL_AIW-1:0]  ID  = 8'b00000111, 
                                    input logic [top_pkg::TL_DBW-1:0]   msk = 8'b11111111, 
                                    input tl_a_op_e                     op, 
                                    input logic  [top_pkg::TL_AW-1:0]   addr,
                                    input logic   [top_pkg::TL_DW-1:0]  w_data       
                                     );
        mst_req_i.a_param          <= '0;
        mst_req_i.a_size           <= 2'b10;
        mst_req_i.a_source         <= ID;
        mst_req_i.a_mask           <= msk;
        mst_req_i.a_valid          <= 1'b1;
        mst_req_i.a_opcode         <= op;
        mst_req_i.a_address        <= addr;
        mst_req_i.d_ready          <= 1'b1;
        mst_req_i.a_data           <= w_data;
        #100;
        mst_req_i.a_valid        <= 1'b0;
    endtask;
    
    
    always #50 clk <= ~clk;
    
    initial begin
        rst <= 1;
        #200;
        rst <= 0;
        #1000;
        iopmp_reg_write (8'b11100111, 
                         8'b11111111, 
                         PutFullData, 
                         HWCFG0_OFFSET,
                         32'hFFFF0000); // Initialize HWCFG0
          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          HWCFG2_OFFSET,
                          32'h1); // Initialize HWCFG0 
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ERR_CFG_OFFSET,
                          32'h2E); // Initialize ERR_CFG ie, ire, iwe and rre enabled
         
//         #300;
//         iopmp_reg_write (8'b11100111, 
//                          8'b11111111, 
//                          Get, 
//                          ERR_REQINFO_OFFSET,
//                          32'hE); // Initialize ERR_REQINFO, CLEAR v bit 


//         #300;
//         iopmp_reg_write (8'b11100111, 
//                          8'b11111111, 
//                          Get, 
//                          ERR_REQADDR,
//                          32'hE); // READ ERR_REQADDR

//         #300;
//         iopmp_reg_write (8'b11100111, 
//                          8'b11111111, 
//                          Get, 
//                          ERR_REQADDRH,
//                          32'hE); // READ ERR_REQADDRH 

//         #300;
//         iopmp_reg_write (8'b11100111, 
//                          8'b11111111, 
//                          Get, 
//                          ERR_REQID,
//                          32'hE); // READ ERR_REQID
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          MDCFG_OFFSET,
                          32'h2); // Initialize MDCFG0 
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          MDCFG_OFFSET + 4,
                          32'h4); // Initialize MDCFG1 
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          MDCFG_OFFSET + 8,
                          32'h6); // Initialize MDCFG2 
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          SRCMD_EN_OFFSET,
                          3'b110); // Initialize SRCMD_EN0 
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          SRCMD_EN_OFFSET + 32,
                          3'b001); // Initialize SRCMD_EN1 
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          SRCMD_EN_OFFSET + 64,
                          4'b100); // Initialize SRCMD_EN2
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRYLCK_OFFSET,
                          32'h0); // Initialize ENTRYLCK
         
         
         
         // ENTRY_ADDR init
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET,
                          32'h20000000); // Initialize ENTRY_ADDR0
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k,
                          32'h40000070); // Initialize ENTRY_ADDR1
                          
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k * 2,
                          32'h50000000); // Initialize ENTRY_ADDR2
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k * 3,
                          32'h70000000); // Initialize ENTRY_ADDR3
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k * 4,
                          32'h80000000); // Initialize ENTRY_ADDR4
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k * 5,
                          32'h90000000); // Initialize ENTRY_ADDR5
                          
          // ENTRY_ADDR end 
         
         
         // ENTRY_CFG init
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET,
                          32'h19); // Initialize ENTRY_CFG0
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k,
                          32'h19); // Initialize ENTRY_CFG1
                          
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k * 2,
                          32'h19); // Initialize ENTRY_CFG2
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k * 3,
                          32'h19); // Initialize ENTRY_CFG3
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k * 4,
                          32'h19); // Initialize ENTRY_CFG4
         // ENTRY_CFG end
                                      
                          
                                                                            
                                          
         
//         #500;
//         iopmp_reg_write (8'b11100111, 
//                          8'b11111111, 
//                          Get, 
//                          SRCMD_EN_OFFSET + 32,
//                          32'h00000010); // READ SRCMD_EN_OFFSET + 32 
                          
         #500;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          Get, 
                          HWCFG0_OFFSET,
                          32'h00000010); // READ HWCFG0_OFFSET
         
         #500;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          Get, 
                          HWCFG1_OFFSET,
                          32'h00000010); // READ HWCFG0_OFFSET
          
         #500;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          Get, 
                          ENTRY_CFG_OFFSET + k * 3,
                          32'h00000010); // READ ENTRY_CFG_OFFSET + k * 3
                      
         
         
         
                     
         #2000;
         $finish();
    end





endmodule
