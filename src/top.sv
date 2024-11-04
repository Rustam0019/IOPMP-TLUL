`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2024 04:36:37 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top file which contains the IOPMP control port, the IOPMP array top and the request handler.
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

module top #(
    parameter int unsigned IOPMPRegions          =   6,
    parameter int unsigned IOPMPNumChan          =   3,
    parameter int unsigned IOPMPMemoryDomains    =   3,
    parameter int unsigned NUM_MASTERS           =   3,
    parameter int unsigned IOPMPGranularity      =   1
)(
    input  logic                clk,
    input  logic                rst,
    
    input  tl_h2d_t             tl_i_req[IOPMPNumChan],
    output tl_d2h_t             tl_o_req[IOPMPNumChan], //IOPMP
    
    //input  tl_d2h_t             slv_rsp_i[IOPMPNumChan],
    //output tl_h2d_t             slv_req_o[IOPMPNumChan],
    
    input   tl_h2d_t            reg_prog_i,
    output  tl_d2h_t            reg_prog_o,
    
    output  logic               irq
    
);

// Entry Tables
iopmp_pkg::entry_cfg                  entry_conf  [IOPMPRegions];
logic [33:0]                          entry_addr [IOPMPRegions];

// MDCFG Table
logic [15:0]                          mdcfg_table[IOPMPMemoryDomains];

// SRCMD Table
logic [31:0]                          srcmd_en_table    [NUM_MASTERS];


// Error Registers
error_registers_t                     error_reg_i;
error_registers_t                     error_reg_o;
error_report_t                        iopmp_error_report[IOPMPNumChan];

logic [33:0]                          iopmp_req_addr_i[IOPMPNumChan];
iopmp_pkg::iopmp_req_e                iopmp_req_type_i[IOPMPNumChan];
logic                                 iopmp_req_err_o[IOPMPNumChan];
logic [8:0]                           entry_violated_index[IOPMPNumChan];

tl_d2h_t                              slv_rsp_i[IOPMPNumChan]; // it should be an input, we assume it comes from a slave.
tl_h2d_t                              slv_req_o[IOPMPNumChan]; // it should be an output

tl_d2h_t                              err_tl[IOPMPNumChan];

iopmp_pkg::err_reqinfo    ERR_REQINFO;
iopmp_pkg::err_cfg        ERR_CFG;

logic irq_gen;
logic [SourceWidth - 1 : 0 ]         rrid[IOPMPNumChan];

logic [15:0]                         prio_entry_num;

// interrupt generate
assign irq     = irq_gen;
assign irq_gen = (ERR_CFG.ie && (ERR_REQINFO.ttype == read_access || ERR_REQINFO.ttype == write_access) && ERR_REQINFO.v) ? 1'b1 : 1'b0;


assign ERR_REQINFO = error_reg_o.ERR_REQINFO;
assign ERR_CFG     = error_reg_o.ERR_CFG;



iopmp_control_port #(
    .IOPMPRegions(IOPMPRegions),
    .IOPMPMemoryDomains(IOPMPMemoryDomains),
    .NUM_MASTERS(NUM_MASTERS)
) iopmp_control_port_0(
    .clk(clk),
    .reset(rst),
    .mst_req_i(reg_prog_i),
    .slv_rsp_o(reg_prog_o),
    .error_report_i(error_reg_o),
    .error_report_o(error_reg_i),
    .entry_conf_table(entry_conf),
    .entry_addr_table(entry_addr),
    .mdcfg_table(mdcfg_table),
    .srcmd_en_table(srcmd_en_table),
    .prio_entry_num(prio_entry_num)
);
    
iopmp_req_handler_tlul #(
    .IOPMPNumChan(IOPMPNumChan),
    .IOPMPRegions(IOPMPRegions)
) iopmp_req_handler_0(
    .clk(clk),
    .rst(rst),
    //.iopmp_req_err_o(iopmp_req_err_o),
    .mst_req_i(tl_i_req),
    .mst_rsp_o(tl_o_req),
    .slv_rsp_i(slv_rsp_i),
    .slv_req_o(slv_req_o),
    .iopmp_permission_denied(iopmp_req_err_o),
    .entry_violated_index_i(entry_violated_index),
    .ERR_CFG(ERR_CFG),
    .entry_conf_i(entry_conf),
    .iopmp_check_addr_o(iopmp_req_addr_i),
    .iopmp_check_access_o(iopmp_req_type_i),
    //.iopmp_check_en_o(),
    .rrid(rrid)
);

for(genvar j = 0; j < IOPMPNumChan; j++) begin
slv_resp_generator slv_resp(
        .clk(clk),
        .rst(rst),
        .iopmp_error(iopmp_req_err_o[j]),
        .req_i(slv_req_o[j]),
        .rsp_o(slv_rsp_i[j]));       
end
 
iopmp_array_top #(
    .IOPMPGranularity(IOPMPGranularity),
    .IOPMPRegions(IOPMPRegions),
    .IOPMPNumChan(IOPMPNumChan),
    .IOPMPMemoryDomains(IOPMPMemoryDomains)
) iopmp_array_top_0(
    .clk(clk),
    .rst(rst),
    .entry_conf(entry_conf),
    .entry_addr(entry_addr),
    .mdcfg_table(mdcfg_table),
    .srcmd_en_table(srcmd_en_table),
    .iopmp_req_addr_i(iopmp_req_addr_i),
    .iopmp_req_type_i(iopmp_req_type_i),
    .iopmp_req_err_o(iopmp_req_err_o),
    .iopmp_mst_id(rrid),
    .entry_violated_index_o(entry_violated_index),
    .iopmp_error_report(iopmp_error_report),
    .prio_entry_num(prio_entry_num)
);   
    
iopmp_error_recorder #(
    .IOPMPNumChan(IOPMPNumChan)
) iopmp_err_rec_0(
    .iopmp_error_report(iopmp_error_report),
    .error_report_reg_i(error_reg_i),
    .error_report_reg_o(error_reg_o)
);
     
endmodule
