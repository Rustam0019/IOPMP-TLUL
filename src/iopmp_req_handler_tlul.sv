//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/15/2024 04:15:22 PM
// Design Name: 
// Module Name: iopmp_req_handler_tlul
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module handles the requests coming from masters and depending on the IOPMP result, request is forwarded to a slave.
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


module iopmp_req_handler_tlul #(
    parameter int unsigned IOPMPNumChan              =   2
)(
    input   logic                           clk,
    input   logic                           rst,
    input   tl_h2d_t                        mst_req_i[IOPMPNumChan],
    output  tl_d2h_t                        mst_rsp_o[IOPMPNumChan], 
    
    input   tl_d2h_t                        slv_rsp_i[IOPMPNumChan],
    output  tl_h2d_t                        slv_req_o[IOPMPNumChan],
    input logic                             iopmp_permission_denied[IOPMPNumChan],
    input iopmp_pkg::err_cfg                ERR_CFG,
    
    output  logic [33:0]                     iopmp_check_addr_o  [IOPMPNumChan],
    output  iopmp_req_e                      iopmp_check_access_o[IOPMPNumChan],
    //output  logic                            iopmp_check_en_o[IOPMPNumChan],
    output  logic [SourceWidth - 1 : 0 ]     rrid[IOPMPNumChan]
    
    // output error_reporting 
);


    // IOPMP signals
    logic [31 : 0 ]                     iopmp_check_addr  [IOPMPNumChan];
    iopmp_req_e                         iopmp_check_access[IOPMPNumChan];
    //logic                               iopmp_check_en[IOPMPNumChan];

    logic                                mst_valid [IOPMPNumChan];
    tl_a_op_e                            mst_opcode[IOPMPNumChan];
    logic [SourceWidth - 1 : 0]          mst_id    [IOPMPNumChan];
    logic [31 : 0 ]                      mst_addr  [IOPMPNumChan];
    logic                                mst_ready [IOPMPNumChan];

    logic                                slv_valid [IOPMPNumChan];
    tl_d_op_e                            slv_opcode[IOPMPNumChan];
    logic [SinkWidth - 1 : 0]            slv_sink  [IOPMPNumChan];
    logic                                slv_ready [IOPMPNumChan];

    logic                                slv_rsp_pending;
    tl_d2h_t                             err_tl_rsp[IOPMPNumChan];
    tl_d2h_t                             success_tl_rsp[IOPMPNumChan];
    //tl_d2h_t                             slv_tl_rsp[IOPMPNumChan];
    // end

    // tl_h2d_t req_i[IOPMPNumChan];
    // tl_d2h_t rsp_o[IOPMPNumChan];

    //assign req_i    = mst_req_i;
    //assign rsp_o    = slv_rsp_o;

    assign rrid = mst_id;

    // Request to IOPMP signals
    for(genvar i = 0; i < IOPMPNumChan; i++) begin
        assign mst_valid[i]            = mst_req_i[i].a_valid;
        assign mst_addr[i]             = mst_req_i[i].a_address;
        assign mst_ready[i]            = mst_req_i[i].d_ready;
        assign mst_opcode[i]           = mst_req_i[i].a_opcode;
        assign mst_id[i]               = i; //mst_req_i[i].a_source;
        
        assign slv_valid[i]            = slv_rsp_i[i].d_valid;
        assign slv_ready[i]            = slv_rsp_i[i].a_ready;
        assign slv_opcode[i]           = slv_rsp_i[i].d_opcode;
        assign slv_sink[i]             = slv_rsp_i[i].d_sink;  
        
        assign iopmp_check_addr_o[i]   = iopmp_check_addr[i];
        assign iopmp_check_access_o[i] = iopmp_check_access[i];
        //assign iopmp_check_en_o[i]     = iopmp_check_en[i];
    end


    genvar j;
    for(j=0; j < IOPMPNumChan; j++) begin 
        state_t current_state, next_state;
        always_ff @(posedge clk) begin
            if (rst) begin
                current_state      <= IDLE;
                slv_rsp_pending    <= 0;
            end
            else begin
                current_state <= next_state; 
            end
        end

        always_comb begin
            next_state = current_state;
            case (current_state)
                IDLE: begin
                    slv_rsp_pending = 1'b0;
                    if(mst_valid[j]) begin
                        next_state            = BLOCK;
                        iopmp_check_addr[j]   = mst_addr[j];
                        iopmp_check_access[j] = (mst_opcode[j] == PutFullData || mst_opcode[j] == PutPartialData) ? IOPMP_ACC_WRITE : IOPMP_ACC_READ; // ?????? 
                        // slv_ready[j] && removed from if
                        if(!iopmp_permission_denied[j]) begin // how do we know when the result will be here????(consider mdcfg)
                            slv_req_o[j] = mst_req_i[j]; // I think this should be in the next state, // check this part!!!!!!!!!!
                        end
                    end 
                    else begin
                        next_state = IDLE;
                    end              
                end       
                BLOCK: begin
                        if(iopmp_permission_denied[j]) begin 
                            if(mst_ready[j]) begin // if response was already generated between err_rsp_gen and mst, do I need this?
                                if(ERR_CFG.rre && success_tl_rsp[j].d_opcode == AccessAckData || (ERR_CFG.rwe && success_tl_rsp[j].d_opcode == AccessAck)) begin
                                    mst_rsp_o[j] = success_tl_rsp[j];
                                end
                                else begin
                                    mst_rsp_o[j] = err_tl_rsp[j];
                                end                 
                                next_state = IDLE;
                            end
                            else begin 
                                next_state = BLOCK; 
                            end
                        end
                        else begin
                            if(mst_ready[j] && slv_valid[j]) begin // if response was already generated between slv_rsp_gen and mst, do I need this?
                                mst_rsp_o[j]    = slv_rsp_i[j];
                                slv_rsp_pending = 0;
                                next_state      = IDLE;
                                //slv_ready[j]   = 1'b1;
                            end
                            else begin 
                                next_state      = BLOCK; 
                                slv_rsp_pending = 1;
                                // do I need to put smth slv_ready here?
                                //slv_ready[j]   = 1'b0;
                            end
                        end
                end
        
                default: begin
                    next_state = IDLE;
                end
            endcase
        end
        
        tlul_err_resp err_resp(
            .clk_i(clk),
            .rst_ni(!rst),
            .tl_h_i(mst_req_i[j]),
            .tl_h_o(err_tl_rsp[j]));
        
        tlul_success_resp success_resp(
            .clk(clk),
            .rst(rst),
            .req_i(mst_req_i[j]),
            .rsp_o(success_tl_rsp[j]));
    end
endmodule