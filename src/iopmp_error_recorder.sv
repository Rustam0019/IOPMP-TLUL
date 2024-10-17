`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2024 01:33:16 PM
// Design Name: 
// Module Name: iopmp_error_recorder
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


module iopmp_error_recorder #(
    parameter int unsigned IOPMPNumChan              =   2
)(
    input    error_report_t                        iopmp_error_report[IOPMPNumChan], 
    input    error_registers_t                     error_report_reg_i,
    output   error_registers_t                     error_report_reg_o
);
    
    always_comb begin
        error_report_reg_o.ERR_CFG                       = error_report_reg_i.ERR_CFG;
        error_report_reg_o.ERR_REQINFO                   = error_report_reg_i.ERR_REQINFO;
        error_report_reg_o.ERR_REQADDRH                  = error_report_reg_i.ERR_REQADDRH;
        error_report_reg_o.ERR_REQADDR                   = error_report_reg_i.ERR_REQADDR;
        error_report_reg_o.ERR_REQID                     = error_report_reg_i.ERR_REQID;
        error_report_reg_o.error_wr_en                   = '0; 
        
        if(!error_report_reg_i.ERR_REQINFO.v) begin
            for(integer i = 0; i < IOPMPNumChan; i++) begin
                if(iopmp_error_report[i].iopmp_fail && iopmp_error_report[i].ttype) begin // good solution?
                    error_report_reg_o.error_wr_en                          = '1;
                    error_report_reg_o.ERR_REQINFO.v                        = 1'b1;
                    error_report_reg_o.ERR_REQINFO.ttype                    = iopmp_error_report[i].ttype;
                    error_report_reg_o.ERR_REQINFO.etype                    = iopmp_error_report[i].etype;
                    error_report_reg_o.ERR_REQADDRH                         = iopmp_error_report[i].ERR_REQADDRH;
                    error_report_reg_o.ERR_REQADDR                          = iopmp_error_report[i].ERR_REQADDR;
                    error_report_reg_o.ERR_REQID                            = iopmp_error_report[i].ERR_REQID;
                    break;
                end
            end 
        end 
    end   
endmodule
