`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2024 11:27:42 AM
// Design Name: 
// Module Name: config_pkg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Base addresses for the IOPMP registers.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//  Package: config
//
package config_pkg;
    
    localparam int N                     = 5;
    localparam int AddrWidth             = 14;
    localparam int SourceWidth           = 8;
    localparam int SinkWidth             = 8;
    localparam int DataWidth             = 32;
    
    // address offset
    localparam  logic [AddrWidth -  1: 0] VERSION_OFFSET                =           14'h0;
    localparam  logic [AddrWidth -  1: 0] IMPLEMENTATION_OFFSET         =           14'h4;
    localparam  logic [AddrWidth -  1: 0] HWCFG0_OFFSET                 =           14'h8;
    localparam  logic [AddrWidth -  1: 0] HWCFG1_OFFSET                 =           14'hC;
    localparam  logic [AddrWidth -  1: 0] HWCFG2_OFFSET                 =           14'h10;
    localparam  logic [AddrWidth -  1: 0] ENTRY_OFFSET_OFFSET           =           14'h14;
    localparam  logic [AddrWidth -  1: 0] MDSTALL_OFFSET                =           14'h30;
    localparam  logic [AddrWidth -  1: 0] MDSTALLH_OFFSET               =           14'h34;
    localparam  logic [AddrWidth -  1: 0] RRIDSCP_OFFSET                =           14'h38;
    localparam  logic [AddrWidth -  1: 0] MDLCK_OFFSET                  =           14'h40;
    localparam  logic [AddrWidth -  1: 0] MDLCKH_OFFSET                 =           14'h44;
    localparam  logic [AddrWidth -  1: 0] MDCFGLCK_OFFSET               =           14'h48;
    localparam  logic [AddrWidth -  1: 0] ENTRYLCK_OFFSET               =           14'h4C;
    localparam  logic [AddrWidth -  1: 0] ERR_CFG_OFFSET                =           14'h60;
    localparam  logic [AddrWidth -  1: 0] ERR_REQINFO_OFFSET            =           14'h64;
    localparam  logic [AddrWidth -  1: 0] ERR_REQADDR_OFFSET            =           14'h68;
    localparam  logic [AddrWidth -  1: 0] ERR_REQADDRH_OFFSET           =           14'h6C;
    localparam  logic [AddrWidth -  1: 0] ERR_REQID_OFFSET              =           14'h70;
    localparam  logic [AddrWidth -  1: 0] ERR_MFR_OFFSET                =           14'h74;
    localparam  logic [AddrWidth -  1: 0] ERR_USER_OFFSET               =           14'h80;
    localparam  logic [AddrWidth -  1: 0] MDCFG_OFFSET                  =           14'h800;
    localparam  logic [AddrWidth -  1: 0] SRCMD_EN_OFFSET               =           14'h1000;
    localparam  logic [AddrWidth -  1: 0] SRCMD_ENH_OFFSET              =           14'h1004;
//    localparam  logic [AddrWidth -  1: 0] SRCMD_R_OFFSET                =           14'h1008;
//    localparam  logic [AddrWidth -  1: 0] SRCMD_RH_OFFSET               =           14'h100C;
//    localparam  logic [AddrWidth -  1: 0] SRCMD_W_OFFSET                =           14'h1010;
//    localparam  logic [AddrWidth -  1: 0] SRCMD_WH_OFFSET               =           14'h1014;

    localparam  logic [AddrWidth -  1: 0] ENTRY_OFFSET                  =           14'h2000;
    localparam  logic [AddrWidth -  1: 0] ENTRY_ADDR_OFFSET             =           14'h2000;
    localparam  logic [AddrWidth -  1: 0] ENTRY_ADDRH_OFFSET            =           14'h2004;
    localparam  logic [AddrWidth -  1: 0] ENTRY_CFG_OFFSET              =           14'h2008;
    localparam  logic [AddrWidth -  1: 0] ENTRY_USER_CFG_OFFSET         =           14'h200C;
    
    
    // mask for 4 bytes
    localparam  logic [AddrWidth -  1: 0] ADDRESS_MASK                  =           14'h3FFC;
    
    
endpackage: config_pkg