`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2024 06:58:09 PM
// Design Name: 
// Module Name: iopmp_array_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module receives the address and its request type to check. 
//              Memory Domains(MDs) associated with the RRID and entries associated with those MDs are extracted. 
//              Then, extracted data is sent to the IOPMP checker.



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

module iopmp_array_top #(
    parameter int unsigned IOPMPRegions          =   4,
    parameter int unsigned IOPMPNumChan          =   4,
    parameter int unsigned IOPMPGranularity      =   1,
    parameter int unsigned IOPMPMemoryDomains    =   1
    //parameter int unsigned IOPMPPrioRegions      =   1
)(
    input  logic                clk,
    input  logic                rst,
    
    // Entry Tables
    input  iopmp_pkg::entry_cfg                  entry_conf  [IOPMPRegions],
    input  logic [33:0]                          entry_addr  [IOPMPRegions],
    
    input  logic [15:0]                          mdcfg_table    [IOPMPMemoryDomains],
    input  logic [31:0]                          srcmd_en_table [IOPMPNumChan],
    
    input  logic [15:0]                          prio_entry_num,
    // Request signals
    input  logic [33:0]                          iopmp_req_addr_i[IOPMPNumChan],
    input  iopmp_pkg::iopmp_req_e                iopmp_req_type_i[IOPMPNumChan],
    output logic                                 iopmp_req_err_o[IOPMPNumChan],
    input  logic [SourceWidth - 1 : 0]           iopmp_mst_id[IOPMPNumChan],
    
    // Error Report
    output logic [8:0]                          entry_violated_index_o[IOPMPNumChan],
    output error_report_t                       iopmp_error_report[IOPMPNumChan]
);


assign entry_violated_index_o = entry_violated_index;

logic [8:0]   entry_violated_index[IOPMPNumChan];
logic[31:0]   counter[IOPMPNumChan];
logic[7:0]    last_entry_indx[IOPMPNumChan];
logic         unknown_rrid[IOPMPNumChan];
//logic md_end, md_next;

logic [7:0][IOPMPMemoryDomains-1:0] rrid_md_list[IOPMPNumChan];
logic [7:0][IOPMPRegions-1:0]       md_entry_indexes[IOPMPNumChan];

for(genvar j = 0; j < IOPMPNumChan; j++) begin  
    always_comb begin
        counter[j]            = '0; 
        last_entry_indx[j]    = '0;
        md_entry_indexes[j]   = '0;
        rrid_md_list[j]       = '0;
        unknown_rrid[j]       = 1'b1;
        for(int i=0; i < IOPMPMemoryDomains; i++) begin 
            if(srcmd_en_table[j][i]) begin
                rrid_md_list[j][counter[j]] = i[7:0];
                unknown_rrid[j]             = 1'b0;
                counter[j] += 1;
            end
        end
        for(int i = 0; i < counter[j]; i++) begin 
            if(mdcfg_table[rrid_md_list[j][i]] != 15'h0 && !unknown_rrid[j]) begin
                if(rrid_md_list[j][i] == 0) begin 
                    for(int k = 0; k < mdcfg_table[rrid_md_list[j][i]]; k++) begin
                        md_entry_indexes[j][k] = k[7:0];
                        last_entry_indx[j]++;
                    end
                end
                else begin
                    //md_entry_indexes[j][i] = mdcfg_table[rrid_md_list[i] - 1];
                    for(int k = mdcfg_table[rrid_md_list[j][i] - 1]; k < mdcfg_table[rrid_md_list[j][i]]; k++) begin
                        md_entry_indexes[j][last_entry_indx[j]] = k[7:0];
                        last_entry_indx[j]++;
                    end
                end
            end
        end   
    end
    //always_ff @(posedge clk) begin
    for(genvar j = 0; j < IOPMPNumChan; j++) begin
        assign iopmp_error_report[j].iopmp_fail            = iopmp_req_err_o[j];
        assign iopmp_error_report[j].etype                 = error_type'(iopmp_req_type_i[j]);
        assign iopmp_error_report[j].ttype                 = transaction_type'(iopmp_req_type_i[j]);
        assign iopmp_error_report[j].ERR_REQADDR           = iopmp_req_addr_i[j];
        assign iopmp_error_report[j].ERR_REQADDRH          = '0;
        assign iopmp_error_report[j].ERR_REQID.rrid        = iopmp_mst_id[j];
        assign iopmp_error_report[j].ERR_REQID.eid         = entry_violated_index[j][7:0];  
    end
    //end
     

    iopmp_cfg_i #(
        .IOPMPGranularity(IOPMPGranularity),
        .IOPMPRegions(IOPMPRegions),
        .IOPMPNumChan(IOPMPNumChan)
        //.IOPMPPrioRegions(IOPMPPrioRegions)
    ) iopmp_cfg_0(
        .clk(clk),
        .rst(rst),
        .csr_iopmp_i_cfg(entry_conf),
        .csr_iopmp_addr_i(entry_addr),
        .iopmp_req_addr_i(iopmp_req_addr_i),
        .iopmp_req_type_i(iopmp_req_type_i),
        .iopmp_req_err_o(iopmp_req_err_o),
        .md_entry_indexes(md_entry_indexes),
        .prio_entry_num(prio_entry_num),
        .last_indx(last_entry_indx),
        .entry_violated_index(entry_violated_index)
    );   
end  

endmodule