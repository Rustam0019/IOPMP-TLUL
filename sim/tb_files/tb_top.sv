`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2024 03:18:01 PM
// Design Name: 
// Module Name: tb_top
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

module tb_top;
    
    localparam IOPMPRegions           = 9;
    localparam IOPMPNumChan           = 3;
    localparam IOPMPMemoryDomains     = 3; 
    localparam NUM_MASTERS            = 3;
    localparam IOPMPGranularity       = 1;
    
    
    logic clk = 1'b0;
    logic rst = 1'b0;
    
    
    tl_h2d_t             tl_i_req[IOPMPNumChan];
    tl_d2h_t             tl_o_req[IOPMPNumChan]; //IOPMP
    
    tl_h2d_t             reg_prog_i;
    tl_d2h_t             reg_prog_o;
    
    logic                irq;
    
    
    integer k = 16;
    
    top #(
        .IOPMPRegions(IOPMPRegions),
        .IOPMPNumChan(IOPMPNumChan),
        .IOPMPMemoryDomains(IOPMPMemoryDomains),
        .IOPMPGranularity(IOPMPGranularity),
        .NUM_MASTERS(NUM_MASTERS)
    ) dut_top_0(
        .clk(clk),
        .rst(rst),
        .tl_i_req(tl_i_req),
        .tl_o_req(tl_o_req),
        //.slv_rsp_i(tl_o_req),
        //.slv_req_o(tl_i_req),
        .reg_prog_i(reg_prog_i),
        .reg_prog_o(reg_prog_o),
        .irq(irq)
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
        reg_prog_i.a_param          <= '0;
        reg_prog_i.a_size           <= 2'b10;
        reg_prog_i.a_source         <= ID;
        reg_prog_i.a_mask           <= msk;
        reg_prog_i.a_valid          <= 1'b1;
        reg_prog_i.a_opcode         <= op;
        reg_prog_i.a_address        <= addr;
        reg_prog_i.d_ready          <= 1'b1;
        reg_prog_i.a_data           <= w_data;
        #100;
        reg_prog_i.a_valid        <= 1'b0;
    endtask;
    
    task automatic master_send_req (input logic  [top_pkg::TL_AIW-1:0]  ID  = 8'b10000000, 
                                    input logic [top_pkg::TL_DBW-1:0]   msk = 8'b11111111, 
                                    input tl_a_op_e                     op, 
                                    input logic   [top_pkg::TL_AW-1:0]   addr,
                                    input logic   [top_pkg::TL_DW-1:0]  w_data,
                                    input int     indx        
                                     );
        tl_i_req[indx].a_param          <= '0;
        tl_i_req[indx].a_size           <= 2'b10;
        tl_i_req[indx].a_source         <= ID;
        tl_i_req[indx].a_mask           <= msk;
        tl_i_req[indx].a_valid          <= 1'b1;
        tl_i_req[indx].a_opcode         <= op;
        tl_i_req[indx].a_address        <= addr;
        tl_i_req[indx].d_ready          <= 1'b1;
        tl_i_req[indx].a_data           <= w_data;
        #100;
        tl_i_req[indx].a_valid          <= 1'b0;
    endtask; 
    
        
    always #50 clk <= ~clk;
    
    initial begin
        rst <= 1;
        #200;
        rst <= 0;
        #1000;
        // Register Programming
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
                          32'h4); // Initialize HWCFG2 
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ERR_CFG_OFFSET,
                          32'h2E); // Initialize ERR_CFG ie, ire, iwe and rre enabled
         
//         #300;
//         iopmp_reg_write (8'b11100111, 
//                          8'b11111111, 
//                          PutFullData, 
//                          ERR_REQINFO_OFFSET,
//                          32'h1); // Initialize ERR_REQINFO, CLEAR v bit 


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
                          32'h4); // Initialize MDCFG0 
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          MDCFG_OFFSET + 4,
                          32'h5); // Initialize MDCFG1 
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          MDCFG_OFFSET + 8,
                          32'h9); // Initialize MDCFG2 
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          SRCMD_EN_OFFSET,
                          3'b111); // Initialize SRCMD_EN0 
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          SRCMD_EN_OFFSET + 32,
                          3'b110); // Initialize SRCMD_EN1 
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          SRCMD_EN_OFFSET + 64,
                          3'b011); // Initialize SRCMD_EN2
         
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
                          32'h08000000); // Initialize ENTRY_ADDR0 - 2000_0000
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k,
                          32'h0c000000); // Initialize ENTRY_ADDR1 3000_0000
                          
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k * 2,
                          32'h10000000); // Initialize ENTRY_ADDR2 4000_0000
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k * 3,
                          32'h14000000); // Initialize ENTRY_ADDR3 5000_0000
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k * 4,
                          32'h20000000); // Initialize ENTRY_ADDR4 8000_0000
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k * 5,
                          32'h20001400); // Initialize ENTRY_ADDR5 8000_5000
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k * 6,
                          32'h10000000); // Initialize ENTRY_ADDR6 4000_0000                
          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k * 7,
                          32'h14000000); // Initialize ENTRY_ADDR7 5000_0000
          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_ADDR_OFFSET + k * 8,
                          32'h20001400); // Initialize ENTRY_ADDR7 8000_5000
          // ENTRY_ADDR end 
         
         
         // ENTRY_CFG init
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET,
                          32'h3); // Initialize ENTRY_CFG0
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k,
                          32'hB); // Initialize ENTRY_CFG1
                          
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k * 2,
                          32'h1); // Initialize ENTRY_CFG2
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k * 3,
                          32'h9); // Initialize ENTRY_CFG3
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k * 4,
                          32'h1B); // Initialize ENTRY_CFG4
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k * 5,
                          32'h19); // Initialize ENTRY_CFG5                 
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k * 6,
                          32'h3); // Initialize ENTRY_CFG6
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k * 7,
                          32'hB); // Initialize ENTRY_CFG7
         
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ENTRY_CFG_OFFSET + k * 8,
                          32'h1B); // Initialize ENTRY_CFG8
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
                      
         // Register Programming END
         
         
         
         // -----------------------------------------------------------------
         // -----------------------------------------------------------------
         // -----------------------------------------------------------------
         // -----------------------------------------------------------------
         // -----------------------------------------------------------------
         
         
         // Master Requests
         #300;
         master_send_req (8'b00000001, 
                          8'b11111111, 
                          PutFullData, 
                          32'h20004000,
                          32'hABCD,
                          0); // 
         
         
         #300;
         master_send_req (8'b00000011, 
                          8'b11111111, 
                          Get, 
                          32'h40080000,
                          32'hABCD,
                          1); // 
                          
         #300;
         master_send_req (8'b00000101, 
                          8'b11111111, 
                          PutFullData, 
                          32'h80005000,
                          32'hABCD,
                          2); // 
          
         
         
         #1000;
         master_send_req (8'b00000111, 
                          8'b11111111, 
                          Get, 
                          32'h80000000,
                          32'hABCD,
                          2); // 
                          
         #300;
         iopmp_reg_write (8'b11100111, 
                          8'b11111111, 
                          PutFullData, 
                          ERR_REQINFO_OFFSET,
                          32'h1); // Initialize ERR_REQINFO, CLEAR v bit
                          
//         #2000;
//         master_send_req (8'b00000001, 
//                          8'b11111111, 
//                          PutFullData, 
//                          32'h41000000,
//                          32'hABCD,
//                          2); //                              
         #20000;
         $finish();
    end

    
    
    
endmodule
