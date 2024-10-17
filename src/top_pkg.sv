`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2024 11:24:09 AM
// Design Name: 
// Module Name: top_pkg
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


//  Package: top_pkg
//
package top_pkg;
    // size??
    localparam int TL_AW            = 32;
    localparam int TL_DW            = 32;    // = TL_DBW * 8; TL_DBW must be a power-of-two //  should it be a const or?
    localparam int TL_AIW           = 8;    // a_source, d_source
    localparam int TL_DIW           = 8;    // d_sink
    localparam int TL_AUW           = 21;   // a_user
    localparam int TL_DUW           = 14;   // d_user
    localparam int TL_DBW           = (TL_DW>>3);
    localparam int TL_SZW           = $clog2($clog2(TL_DBW)+1);
    
    localparam IOPMPRegions           = 6;
    localparam IOPMPMemoryDomains     = 3; 
    localparam NUM_MASTERS            = 3;
    
    typedef enum logic [1:0] {
        IDLE              = 2'b00,
        BLOCK             = 2'b01
    } state_t;
    
    typedef enum logic [1:0] {
        NO_OP              = 2'b00,
        RESP               = 2'b01
    } state_t_control;

endpackage: top_pkg