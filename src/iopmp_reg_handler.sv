`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2024 08:42:05 PM
// Design Name: 
// Module Name: iopmp_reg_handler
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

// Control port to write/read from the iopmp registers.

module iopmp_reg_handler # (
        parameter int  DataWidth                            = 32,
        parameter      AccessType                           = "RO",
        parameter type data_t                               = logic,
        parameter logic [DataWidth - 1: 0] init_val         = '0
    )(  
        input logic clk,
        input logic rst,
        
        input logic                      reg_we,
        input data_t [DataWidth - 1 : 0] reg_data,
        
        // From HW: valid for HRW, HWO
        input                              hw2reg_we,
        input data_t [DataWidth - 1:0]     hw2reg_data,
        
        output data_t [DataWidth - 1 : 0] q
        
    );
    
    logic                    wr_enable;
    data_t [DataWidth - 1:0] wr_data;
    
    if(AccessType == "RW") begin: read_write
        assign wr_enable = reg_we | hw2reg_we;
        assign wr_data   = reg_we ? reg_data : hw2reg_data;
    end
    else if (AccessType == "RO") begin: read_only
        assign wr_enable = hw2reg_we;
        assign wr_data   = hw2reg_data;
    end
    else if (AccessType == "W1S") begin: write_1_set
        assign wr_enable = reg_we | hw2reg_we;
        assign wr_data   = (hw2reg_we ? hw2reg_data : q) | (reg_we ? reg_data : '0);
    end
    else if (AccessType == "W1C") begin: write_1_clear
        assign wr_enable = reg_we | hw2reg_we;
        assign wr_data   = (hw2reg_we ? hw2reg_data : q) & (reg_we ? ~reg_data : '1);
    end
    else if (AccessType == "W1SS") begin: write_1_set_sticky_1
        assign wr_enable = q ? 0: hw2reg_we | reg_we;
        assign wr_data   = (hw2reg_we ? hw2reg_data : q) | (reg_we ? reg_data : '0);
    end
    else if (AccessType == "W1CS") begin: write_1_clear_sticky_0
        // When you write a 1 to this bit, it clears (resets) the bit to 0.
        // Once the bit is cleared to 0, it stays 0 unless reset conditions change it.
        assign wr_enable = !q ? 0: hw2reg_we | reg_we;
        assign wr_data   = (hw2reg_we ? hw2reg_data : q) & (reg_we ? ~reg_data : '1);
    end
    else begin: hw_to_reg
        assign wr_enable = hw2reg_we;
        assign wr_data   = hw2reg_data;
    end
    
    
    
    always_ff @(posedge clk) begin
        if(rst) begin
            q <= init_val;
        end
        else if(wr_enable) begin // can be changed to intermediate signal, check comment for HW
            q <= wr_data;
        end
    end
    
    
    
    
    
    
endmodule
