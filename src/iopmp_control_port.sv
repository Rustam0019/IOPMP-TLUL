`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2024 10:21:03 PM
// Design Name: 
// Module Name: iopmp_control_port
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


module iopmp_control_port #(
    parameter int unsigned IOPMPRegions           =   2,
    parameter int unsigned IOPMPMemoryDomains     =   1,
    parameter int unsigned NUM_MASTERS            =   1
)(
    input    logic                              clk,
    input    logic                              reset,
    input    tl_h2d_t                           mst_req_i,
    output   tl_d2h_t                           slv_rsp_o,
    
    input    error_registers_t                     error_report_i,
    output   error_registers_t                     error_report_o,
        
    output   iopmp_pkg::entry_cfg               entry_conf_table  [IOPMPRegions],
    output   logic [33:0]                       entry_addr_table  [IOPMPRegions],
    output   logic [15:0]                       mdcfg_table       [IOPMPMemoryDomains],
    output   logic [31:0]                       srcmd_en_table    [NUM_MASTERS],
    output   logic [15:0]                       prio_entry_num
    //output   logic [31:0]                       srcmd_enh_table    [NUM_MASTERS] 
);



// register request signals
logic                                reg_wr_enable;
logic                                reg_rd_enable;
logic [SourceWidth - 1 : 0]          mst_id;
logic                                mst_valid;
logic                                mst_ready;
tl_a_op_e                            mst_opcode;
logic  [top_pkg::TL_SZW-1:0]         mst_size;
logic                  [2:0]         mst_param;
logic [top_pkg::TL_DBW-1:0]          reg_mask;
logic [AddrWidth - 1 : 0 ]           reg_addr;
logic [DataWidth - 1 : 0 ]           reg_wr_data;

logic [SourceWidth - 1 : 0]          mst_id_d;
logic [SourceWidth - 1 : 0]          mst_id_q;
logic                  [2:0]         mst_param_d;
logic                  [2:0]         mst_param_q;
logic  [top_pkg::TL_SZW-1:0]         mst_size_d;
logic  [top_pkg::TL_SZW-1:0]         mst_size_q;
tl_a_op_e                            opcode_d;
tl_a_op_e                            opcode_q;
logic [DataWidth - 1 : 0 ]           reg_rr_data_d;
logic [DataWidth - 1 : 0 ]           reg_rr_data_q;
//tl_a_op_e                            reg_opcode;
// end

// register response signals
logic                                       slv_valid;
logic                                       slv_ready;
tl_d_op_e                                   slv_opcode;
logic       [SourceWidth - 1: 0]            slv_mst_id;
logic       [SinkWidth - 1 : 0]             slv_sink;
logic       [DataWidth - 1 : 0 ]            slv_data;
logic       [2:0]                           slv_param;
logic       [top_pkg::TL_SZW-1:0]           slv_size;
logic                                       slv_error;

logic                                       reg_error_d;
logic                                       reg_error_q; 
// end

//logic slv_rsp_pending;

tl_h2d_t reg_req_i;
tl_d2h_t reg_rsp_o;

assign reg_req_i   = mst_req_i;
assign slv_rsp_o   = reg_rsp_o;

// TileLink to register signal translation
assign reg_wr_enable    = reg_req_i.a_valid & reg_rsp_o.a_ready & (reg_req_i.a_opcode == PutFullData || reg_req_i.a_opcode == PutPartialData);
assign reg_rd_enable    = reg_req_i.a_valid & reg_rsp_o.a_ready & reg_req_i.a_opcode == Get;
assign mst_id           = reg_req_i.a_source;
assign reg_addr         = reg_req_i.a_address[AddrWidth - 1 : 0] & ADDRESS_MASK;
assign reg_wr_data      = reg_req_i.a_data; //& reg_mask; // should I put wr_enable here?
assign reg_mask         = (mst_opcode == PutPartialData) ? reg_req_i.a_mask : '1;
assign mst_valid        =  reg_req_i.a_valid;
assign mst_opcode       =  reg_req_i.a_opcode;
assign mst_ready        =  reg_req_i.d_ready;
assign mst_param        =  reg_req_i.a_param;
assign mst_size         =  reg_req_i.a_size;


assign reg_rsp_o.a_ready                =       slv_ready;
assign reg_rsp_o.d_valid                =       slv_valid;
assign reg_rsp_o.d_opcode               =       slv_opcode;
assign reg_rsp_o.d_source               =       slv_mst_id;
assign reg_rsp_o.d_sink                 =       slv_sink;
assign reg_rsp_o.d_data                 =       slv_data;
assign reg_rsp_o.d_param                =       slv_param;
assign reg_rsp_o.d_size                 =       slv_size;
assign reg_rsp_o.d_error                =       slv_error;


error_registers_t                        error_report;



// INFO Registers
iopmp_pkg::version                  VERSION;
iopmp_pkg::implementation           IMPLEMENTATION;
iopmp_pkg::hwcfg0                   HWCFG0;
iopmp_pkg::hwcfg1                   HWCFG1;
iopmp_pkg::hwcfg2                   HWCFG2;
iopmp_pkg::entryoffset              ENTRYOFFSET;


// Configuration Protection Registers
iopmp_pkg::mdcfglck                 MDCFGLCK;
iopmp_pkg::entrylck                 ENTRYLCK;


// Error Reporting Registers
//iopmp_pkg::err_user                 ERR_USER;
iopmp_pkg::err_mfr                  ERR_MFR;
iopmp_pkg::err_reqid                ERR_REQID;
iopmp_pkg::err_reqaddr              ERR_REQADDR;
iopmp_pkg::err_reqaddrh             ERR_REQADDRH;
iopmp_pkg::err_reqinfo              ERR_REQINFO;
iopmp_pkg::err_cfg                  ERR_CFG;

// MDCFG Table
iopmp_pkg::mdcfg                    MDCFG[IOPMPMemoryDomains];

// SRCMD Table
iopmp_pkg::srcmd_en                 SRCMD_EN [NUM_MASTERS];
iopmp_pkg::srcmd_enh                SRCMD_ENH[NUM_MASTERS];

// ENTRY Table
iopmp_pkg::entry_addr               ENTRY_ADDR[IOPMPRegions];
iopmp_pkg::entry_cfg                ENTRY_CFG[IOPMPRegions];


for (genvar j = 0; j < IOPMPMemoryDomains; j++) begin
    assign mdcfg_table[j]                                = MDCFG[j].t;
end

for (genvar j = 0; j < NUM_MASTERS; j++) begin
    assign srcmd_en_table[j]                             = SRCMD_EN[j];
end

for (genvar j = 0; j < IOPMPRegions; j++) begin
    assign entry_conf_table[j]                                 = ENTRY_CFG[j];
    assign entry_addr_table[j][33:2]                           = ENTRY_ADDR[j];
    assign entry_addr_table[j][1:0]                            = '0;
end


assign error_report                                 = error_report_i;
assign error_report_o.ERR_CFG                       = ERR_CFG;
assign error_report_o.ERR_REQINFO                   = ERR_REQINFO;
assign error_report_o.ERR_REQADDRH                  = ERR_REQADDRH;
assign error_report_o.ERR_REQADDR                   = ERR_REQADDR;
assign error_report_o.ERR_REQID                     = ERR_REQID;
assign error_report_o.error_wr_en                   = '0;


assign prio_entry_num = HWCFG2.prio_entry;

logic [7:0] indx;

// hwcfg0 register in signals
logic hwcfg0_prient_prog_data_in;
logic hwcfg0_prient_prog_we;

logic hwcfg0_enable_data_in;
logic hwcfg0_enable_we;

// hwcfg2 register in signals
logic [15:0] hwcfg2_prio_entry_data_in;
logic        hwcfg2_prio_entry_we;

logic [15:0] hwcfg2_rrid_transl_data_in;
logic        hwcfg2_rrid_transl_we;


// Configuration Protection Registers
logic        mdcfglck_l_data_in;
logic        mdcfglck_l_we;

logic [6:0]  mdcfglck_f_data_in;
logic        mdcfglck_f_we;

logic        entrylck_l_data_in;
logic        entrylck_l_we;

logic [15:0] entrylck_f_data_in;
logic        entrylck_f_we;


// Err_Cfg register in signals
logic        err_cfg_l_data_in;
logic        err_cfg_l_we;

logic        err_cfg_ie_data_in;
logic        err_cfg_ie_we;

logic        err_cfg_ire_data_in;
logic        err_cfg_ire_we;

logic        err_cfg_iwe_data_in;
logic        err_cfg_iwe_we;

logic        err_cfg_ixe_data_in;
logic        err_cfg_ixe_we;

logic        err_cfg_rre_data_in;
logic        err_cfg_rre_we;

logic        err_cfg_rwe_data_in;
logic        err_cfg_rwe_we;

logic        err_cfg_rxe_data_in;
logic        err_cfg_rxe_we;

// Err_ReqInfo register in signals
logic        err_reqinfo_v_data_in;
logic        err_reqinfo_v_we;


// MDCFG Table register in signals
logic [15:0] mdcfg_t_data_in [IOPMPMemoryDomains];
logic [15:0] mdcfg_t_we [IOPMPMemoryDomains];


// SRCMD Table register in signals
logic srcmd_en_l_data_in         [NUM_MASTERS];
logic srcmd_en_l_we              [NUM_MASTERS];

logic [30:0] srcmd_en_md_data_in  [NUM_MASTERS];
logic        srcmd_en_md_we       [NUM_MASTERS];

logic [31:0] srcmd_enh_md_data_in  [NUM_MASTERS];
logic        srcmd_enh_md_we       [NUM_MASTERS];

// Entry_Addr register in signals
logic [31:0]        entry_addr_data_in[IOPMPRegions];
logic               entry_addr_we[IOPMPRegions];

// Entry_cfg register in signals
logic [31:0]        entry_cfg_data_in[IOPMPRegions];
logic               entry_cfg_we[IOPMPRegions];


// Version register
assign VERSION.vendor  = 24'hABCD;
assign VERSION.specver = 8'h0; 


// Implementation register
assign IMPLEMENTATION.impid  = '1;

// hwcfg0 register
assign HWCFG0.model             =           FULL_MODEL;
assign HWCFG0.tor_en            =           1'h1;
assign HWCFG0.sps_en            =           1'h0; // not yet
assign HWCFG0.user_cfg_en       =           1'h0;

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("W1CS"),
  .init_val(1'h1)
) i_hwcfg0_prient_prog(
  .clk(clk),
  .rst(reset),
  .reg_we(hwcfg0_prient_prog_we),
  .reg_data(hwcfg0_prient_prog_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(HWCFG0.prient_prog)
);

assign HWCFG0.rrid_transl_en            = 1'h0;
assign HWCFG0.rrid_transl_prog          = 1'h0;
assign HWCFG0.chk_x                     = 1'h0;
assign HWCFG0.no_x                      = 1'h0;
assign HWCFG0.no_w                      = 1'h0;
assign HWCFG0.stall_en                  = 1'h0;
assign HWCFG0.peis                      = 1'h0; // can be changed, check the datasheet
assign HWCFG0.pees                      = 1'h0;
assign HWCFG0.mfr_en                    = 1'h0;
assign HWCFG0.rsv                       = '0;
assign HWCFG0.md_num                    = IOPMPMemoryDomains;

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("W1SS"),
  .init_val(1'h0)
) i_hwcfg0_enable(
  .clk(clk),
  .rst(reset),
  .reg_we(hwcfg0_enable_we),
  .reg_data(hwcfg0_enable_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(HWCFG0.enable)
);

// hwcfg1 register
assign HWCFG1.rrid_num  = NUM_MASTERS;
assign HWCFG1.entry_num = IOPMPRegions;

// hwcfg2 register
iopmp_reg_handler #(
  .DataWidth(16),
  .AccessType("RW"),
  .init_val(16'h0) // NUMBER_PRIO_ENTRIES - add to the parameter list of the module
) i_hwcfg2_prio_entry(
  .clk(clk),
  .rst(reset),
  .reg_we(hwcfg2_prio_entry_we),
  .reg_data(hwcfg2_prio_entry_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(HWCFG2.prio_entry)
);

iopmp_reg_handler #(
  .DataWidth(16),
  .AccessType("RW"),
  .init_val(16'h0)
) i_hwcfg2_rrid_transl(
  .clk(clk),
  .rst(reset),
  .reg_we(hwcfg2_rrid_transl_we),
  .reg_data(hwcfg2_rrid_transl_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(HWCFG2.rrid_transl)
);



// Configuration Protection Registers
// MDLCK and MDLCKH optional for now...

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("W1SS"),
  .init_val(1'h0)
) i_mdcfglck_l(
  .clk(clk),
  .rst(reset),
  .reg_we(mdcfglck_l_we),
  .reg_data(mdcfglck_l_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(MDCFGLCK.l)
);

iopmp_reg_handler #(
  .DataWidth(7),
  .AccessType("RW"),
  .init_val(7'h0)
) i_mdcfglck_f(
  .clk(clk),
  .rst(reset),
  .reg_we(mdcfglck_f_we),
  .reg_data(mdcfglck_f_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(MDCFGLCK.f)
);

assign MDCFGLCK.rsv = '0;

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("W1SS"),
  .init_val(1'h0)
) i_entrylck_l(
  .clk(clk),
  .rst(reset),
  .reg_we(entrylck_l_we),
  .reg_data(entrylck_l_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(ENTRYLCK.l)
);

iopmp_reg_handler #(
  .DataWidth(16),
  .AccessType("RW"),
  .init_val(16'h0)
) i_entrylck_f(
  .clk(clk),
  .rst(reset),
  .reg_we(entrylck_f_we),
  .reg_data(entrylck_f_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(ENTRYLCK.f)
);

assign ENTRYLCK.rsv = '0;


// Entry_offset register
assign ENTRYOFFSET.offset = ENTRY_OFFSET;
// iopmp_reg_handler #(
//   .DataWidth(32),
//   .AccessType("RW"),
//   .init_val(32'h2000)
// ) i_entry_offset(
//   .clk(clk),
//   .rst(reset),
//   .reg_we(1'b0),
//   .reg_data('0),
//   .hw2reg_we(1'b0),
//   .hw2reg_data('0),
//   .q(ENTRYOFFSET.offset)
// );

// Err_Cfg register
iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("W1SS"),
  .init_val(1'h0)
) i_err_cfg_l(
  .clk(clk),
  .rst(reset),
  .reg_we(err_cfg_l_we),
  .reg_data(err_cfg_l_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(ERR_CFG.l)
);

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("RW"),
  .init_val(1'h0)
) i_err_cfg_ie(
  .clk(clk),
  .rst(reset),
  .reg_we(err_cfg_ie_we),
  .reg_data(err_cfg_ie_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(ERR_CFG.ie)
);

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("RW"), // WARL ?????
  .init_val(1'h0)
) i_err_cfg_ire(
  .clk(clk),
  .rst(reset),
  .reg_we(err_cfg_ire_we),
  .reg_data(err_cfg_ire_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(ERR_CFG.ire)
);

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("RW"),
  .init_val(1'h0)
) i_err_cfg_iwe(
  .clk(clk),
  .rst(reset),
  .reg_we(err_cfg_iwe_we),
  .reg_data(err_cfg_iwe_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(ERR_CFG.iwe)
);

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("RW"),
  .init_val(1'h0)
) i_err_cfg_ixe(
  .clk(clk),
  .rst(reset),
  .reg_we(err_cfg_ixe_we),
  .reg_data(err_cfg_ixe_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(ERR_CFG.ixe)
);

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("RW"),
  .init_val(1'h0)
) i_err_cfg_rre(
  .clk(clk),
  .rst(reset),
  .reg_we(err_cfg_rre_we),
  .reg_data(err_cfg_rre_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(ERR_CFG.rre)
);

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("RW"),
  .init_val(1'h0)
) i_err_cfg_rwe(
  .clk(clk),
  .rst(reset),
  .reg_we(err_cfg_rwe_we),
  .reg_data(err_cfg_rwe_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(ERR_CFG.rwe)
);

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("RW"),
  .init_val(1'h0)
) i_err_cfg_rxe(
  .clk(clk),
  .rst(reset),
  .reg_we(err_cfg_rxe_we),
  .reg_data(err_cfg_rxe_data_in),
  .hw2reg_we(1'b0),
  .hw2reg_data('0),
  .q(ERR_CFG.rxe)
);

assign ERR_CFG.rsv = '0;



// Err_ReqInfo register
iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("W1C"),
  .init_val(1'h0)
) i_err_reqinfo_v(
  .clk(clk),
  .rst(reset),
  .reg_we(err_reqinfo_v_we),
  .reg_data(err_reqinfo_v_data_in),
  .hw2reg_we(error_report.error_wr_en.v_we),
  .hw2reg_data(error_report.ERR_REQINFO.v),
  .q(ERR_REQINFO.v)
);

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("RO"),
  .data_t(transaction_type),
  .init_val(rsv)
) i_err_reqinfo_ttype(
  .clk(clk),
  .rst(reset),
  .reg_we(1'b0),
  .reg_data(rsv),
  .hw2reg_we(error_report.error_wr_en.ttype_we),
  .hw2reg_data(error_report.ERR_REQINFO.ttype),
  .q(ERR_REQINFO.ttype)
);

assign ERR_REQINFO.rsv1 = '0;

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("RO"),
  .data_t(error_type),
  .init_val(no_error)
) i_err_reqinfo_etype(
  .clk(clk),
  .rst(reset),
  .reg_we(1'b0),
  .reg_data(no_error),
  .hw2reg_we(error_report.error_wr_en.etype_we),
  .hw2reg_data(error_report.ERR_REQINFO.etype),
  .q(ERR_REQINFO.etype)
);

iopmp_reg_handler #(
  .DataWidth(1),
  .AccessType("RO"),
  .data_t(logic),
  .init_val(1'h0)
) i_err_reqinfo_svc(
  .clk(clk),
  .rst(reset),
  .reg_we(1'b0),
  .reg_data(rsv),
  .hw2reg_we(1'b0), // do not know yet!!!!
  .hw2reg_data('0),
  .q(ERR_REQINFO.svc)
);


assign ERR_REQINFO.rsv2 = '0;

// Err_ReqAddr register
iopmp_reg_handler #(
  .DataWidth(32),
  .AccessType("RO"),
  .data_t(logic),
  .init_val(32'h0)
) i_err_reqaddr_addr(
  .clk(clk),
  .rst(reset),
  .reg_we(1'b0),
  .reg_data('0),
  .hw2reg_we(error_report.error_wr_en.reqaddr_we), // do not know yet!!!!
  .hw2reg_data(error_report.ERR_REQADDR.addr),
  .q(ERR_REQADDR.addr)
);


// Err_ReqAddrH register
iopmp_reg_handler #(
  .DataWidth(32),
  .AccessType("RO"),
  .data_t(logic),
  .init_val(32'h0)
) i_err_reqaddr_addrh(
  .clk(clk),
  .rst(reset),
  .reg_we(1'b0),
  .reg_data('0),
  .hw2reg_we(error_report.error_wr_en.reqaddrh_we), // do not know yet!!!!
  .hw2reg_data(error_report.ERR_REQADDRH.addrh),
  .q(ERR_REQADDRH.addrh)
);

// Err_ReqID register
iopmp_reg_handler #(
  .DataWidth(16),
  .AccessType("RO"),
  .data_t(logic),
  .init_val(16'h0)
) i_err_reqid_rrid(
  .clk(clk),
  .rst(reset),
  .reg_we(1'b0),
  .reg_data('0),
  .hw2reg_we(error_report.error_wr_en.rrid_we), // do not know yet!!!!
  .hw2reg_data(error_report.ERR_REQID.rrid),
  .q(ERR_REQID.rrid)
);

iopmp_reg_handler #(
  .DataWidth(16),
  .AccessType("RO"),
  .data_t(logic),
  .init_val(16'h0)
) i_err_reqid_eid(
  .clk(clk),
  .rst(reset),
  .reg_we(1'b0),
  .reg_data('0),
  .hw2reg_we(error_report.error_wr_en.eid_we), // do not know yet!!!!
  .hw2reg_data(error_report.ERR_REQID.eid),
  .q(ERR_REQID.eid)
);


// ERR_MFR and ERR_USER - optional
// ...

for(genvar i = 0; i < IOPMPMemoryDomains; i++) begin 
    // MDCFG Table
    
    iopmp_reg_handler #(
      .DataWidth(16),
      .AccessType("RW"),
      .data_t(logic),
      .init_val(16'h0)
    ) i_mdcfg_t(
      .clk(clk),
      .rst(reset),
      .reg_we(mdcfg_t_we[i]),
      .reg_data(mdcfg_t_data_in[i]),
      .hw2reg_we(1'b0),
      .hw2reg_data('0),
      .q(MDCFG[i].t)
    );
    
    //assign MDCFG[0].t = IOPMPRegions / 2; // for now for compact-k model
    assign MDCFG[i].rsv = '0;
end

for(genvar i = 0; i < NUM_MASTERS; i++) begin 
    // SRCMD_EN Table
    
    iopmp_reg_handler #(
      .DataWidth(1),
      .AccessType("W1SS"),
      .data_t(logic),
      .init_val(1'h0)
    ) i_srcmd_l(
      .clk(clk),
      .rst(reset),
      .reg_we(srcmd_en_l_we[i]),
      .reg_data(srcmd_en_l_data_in[i]),
      .hw2reg_we(1'b0),
      .hw2reg_data('0),
      .q(SRCMD_EN[i].l)
    );
    
    iopmp_reg_handler #(
      .DataWidth(31),
      .AccessType("RW"),
      .data_t(logic),
      .init_val(31'h0)
    ) i_srcmd_md(
      .clk(clk),
      .rst(reset),
      .reg_we(srcmd_en_md_we[i]),
      .reg_data(srcmd_en_md_data_in[i]),
      .hw2reg_we(1'b0),
      .hw2reg_data('0),
      .q(SRCMD_EN[i].md)
    );
    
    iopmp_reg_handler #(
      .DataWidth(31),
      .AccessType("RW"),
      .data_t(logic),
      .init_val(31'h0)
    ) i_srcmdh_md(
      .clk(clk),
      .rst(reset),
      .reg_we(srcmd_enh_md_we[i]),
      .reg_data(srcmd_enh_md_data_in[i]),
      .hw2reg_we(1'b0),
      .hw2reg_data('0),
      .q(SRCMD_ENH[i].mdh)
    );
end

// ENTRY Table
for(genvar i = 0; i < IOPMPRegions; i++) begin 
    iopmp_reg_handler #(
      .DataWidth(32),
      .AccessType("RW"),
      .data_t(logic),
      .init_val(32'h0)
    ) i_entry_addr(
      .clk(clk),
      .rst(reset),
      .reg_we(entry_addr_we[i]),
      .reg_data(entry_addr_data_in[i]),
      .hw2reg_we(1'b0),
      .hw2reg_data('0),
      .q(ENTRY_ADDR[i].addr)
    );
    
    iopmp_reg_handler #(
      .DataWidth(32),
      .AccessType("RW"),
      .data_t(logic),
      .init_val(32'h0)
    ) i_entry_cfg(
      .clk(clk),
      .rst(reset),
      .reg_we(entry_cfg_we[i]),
      .reg_data(entry_cfg_data_in[i]),
      .hw2reg_we(1'b0),
      .hw2reg_data('0),
      .q(ENTRY_CFG[i])
    );
end





logic [AddrWidth -  1: 0] MDCFG_I_OFFSET;
logic [AddrWidth -  1: 0] SRCMD_EN_I_OFFSET;
logic [AddrWidth -  1: 0] SRCMD_ENH_I_OFFSET;

// entry address decoding
logic [AddrWidth -  1: 0] ENTRY_ADDR_I_OFFSET;
logic [AddrWidth -  1: 0] ENTRY_ADDRH_I_OFFSET;
logic [AddrWidth -  1: 0] ENTRY_CFG_I_OFFSET;




// State machine for controlling wr_enable
state_t_control state, next_state;

always_ff @(posedge clk) begin
    if (reset) begin
        state                       <= NO_OP;
        mst_id_q                    <= '0;
        opcode_q                    <= PutFullData;
        reg_rr_data_q               <= '0;
        reg_error_q                 <= '0;
        mst_param_q                 <= '0;
        mst_size_q                  <= '0;
    end
    else begin
        state                       <= next_state;
        mst_id_q                    <= mst_id_d;
        opcode_q                    <= opcode_d;
        reg_rr_data_q               <= reg_rr_data_d;
        reg_error_q                 <= reg_error_d;
        mst_param_q                 <= mst_param_d;
        mst_size_q                  <= mst_size_d;
    end
end

// WRITE to regs
always_comb begin
    next_state                              = state;
    mst_id_d                                = mst_id_q;
    opcode_d                                = opcode_q;
    reg_rr_data_d                           = reg_rr_data_q;
    reg_error_d                             = reg_error_q;
    mst_param_d                             = mst_param_q;
    mst_size_d                              = mst_size_q;
    hwcfg0_prient_prog_we                   = '0;
    hwcfg0_enable_we                        = '0;
    hwcfg2_prio_entry_we                    = '0;
    hwcfg2_rrid_transl_we                   = '0;
    mdcfglck_l_we                           = '0;
    mdcfglck_f_we                           = '0;
    entrylck_l_we                           = '0;
    entrylck_f_we                           = '0;
    err_cfg_l_we                            = '0;
    err_cfg_ie_we                           = '0;
    err_cfg_ire_we                          = '0;
    err_cfg_iwe_we                          = '0;
    err_cfg_ixe_we                          = '0;
    err_cfg_rre_we                          = '0;
    err_cfg_rwe_we                          = '0;
    err_cfg_rxe_we                          = '0;
    err_reqinfo_v_we                        = '0;
    slv_valid                        = 0;
                slv_ready                        = 1;
    for(integer j = 0; j < IOPMPMemoryDomains; j++) begin
        mdcfg_t_we [j] = '0;
    end
            
    for(integer j = 0; j < NUM_MASTERS; j++) begin
        srcmd_en_l_we   [j]           = '0;
        srcmd_en_md_we  [j]           = '0;
        srcmd_enh_md_we [j]           = '0;
    end
                
    for(integer j = 0; j < IOPMPRegions; j++) begin
        entry_addr_we   [j]             = '0;
        entry_cfg_we    [j]             = '0;
    end
    case(state)
        NO_OP: begin
            if(mst_valid) begin
                next_state                       = RESP;
                mst_id_d                         = mst_id;
                opcode_d                         = mst_opcode;
                reg_error_d                      = 0;
                mst_size_d                       = mst_size;
                mst_param_d                      = mst_param;
                for(integer j = 0; j < IOPMPRegions; j++) begin
                    if(reg_addr == (ENTRY_OFFSET + j * 16)) begin 
                        ENTRY_ADDR_I_OFFSET = ENTRY_OFFSET + j * 16;
                        indx                = j;
                    end
                    else if(reg_addr == (ENTRY_OFFSET + j * 16 + 4)) begin 
                        ENTRY_ADDRH_I_OFFSET = ENTRY_OFFSET + j * 16 + 4;
                        indx                = j;
                    end
                    else if(reg_addr == (ENTRY_OFFSET + j * 16 + 8)) begin 
                        ENTRY_CFG_I_OFFSET = ENTRY_OFFSET + j * 16 + 8;
                        indx                = j;
                    end
                end
                        
                for(integer j = 0; j < IOPMPMemoryDomains; j++) begin
                    if(reg_addr == (MDCFG_OFFSET + j * 4)) begin 
                        MDCFG_I_OFFSET = MDCFG_OFFSET + j * 4;
                        indx                = j;
                    end
                end
                        
                for(integer j = 0; j < NUM_MASTERS; j++) begin
                    if(reg_addr == (SRCMD_EN_OFFSET + j * 32)) begin 
                        SRCMD_EN_I_OFFSET = SRCMD_EN_OFFSET + j * 32;
                        indx                = j;
                    end
                    else if(reg_addr == (SRCMD_ENH_OFFSET + j * 32)) begin 
                        SRCMD_ENH_I_OFFSET = SRCMD_ENH_OFFSET + j * 32;
                        indx                = j;
                    end
                end 
                if(reg_wr_enable) begin    
                    unique case(reg_addr)
                        HWCFG0_OFFSET: begin
                            hwcfg0_prient_prog_we         = '1;
                            hwcfg0_prient_prog_data_in    = reg_wr_data[7];
                            
                            hwcfg0_enable_we              = '1;
                            hwcfg0_enable_data_in         = reg_wr_data[31]; 
                            
                            // rrid_transl_prog !!!!
                        end
                        HWCFG2_OFFSET: begin
                            hwcfg2_prio_entry_we          = HWCFG0.prient_prog ? '1 : '0;
                            hwcfg2_prio_entry_data_in     = (reg_wr_data[15:0] > IOPMPRegions - 1)? HWCFG2.prio_entry: reg_wr_data[15:0];
                            
                            hwcfg2_rrid_transl_we         = '1;
                            hwcfg2_rrid_transl_data_in    = reg_wr_data[31:16];
                        end
                        MDCFGLCK_OFFSET: begin 
                            mdcfglck_l_we         = '1;
                            mdcfglck_l_data_in    = reg_wr_data[0];
                            
                            mdcfglck_f_we         = (MDCFGLCK.l) ? 0: '1;
                            mdcfglck_f_data_in    = reg_wr_data[7:1]; 
                        end
                        ENTRYLCK_OFFSET: begin 
                            entrylck_l_we         = '1;
                            entrylck_l_data_in    = reg_wr_data[0];
                            
                            entrylck_f_we         = (ENTRYLCK.l) ? 0: '1;
                            entrylck_f_data_in    = (reg_wr_data[16:1] < ENTRYLCK.f | reg_wr_data[16:1] > IOPMPRegions) ? ENTRYLCK.f: reg_wr_data[16:1];
                        end 
                        ERR_CFG_OFFSET: begin
                            err_cfg_l_we                  = '1;
                            err_cfg_l_data_in             = reg_wr_data[0];
                            
                            err_cfg_ie_we                 = ERR_CFG.l ? 0 : '1;
                            err_cfg_ie_data_in            = reg_wr_data[1];
                            
                            err_cfg_ire_we                = ERR_CFG.l ? 0 : '1;
                            err_cfg_ire_data_in           = reg_wr_data[2];
                            
                            err_cfg_iwe_we                = ERR_CFG.l ? 0 : '1;
                            err_cfg_iwe_data_in           = reg_wr_data[3];
                            
                            err_cfg_ixe_we                = ERR_CFG.l ? 0 : '1;
                            err_cfg_ixe_data_in           = reg_wr_data[4] && HWCFG0.chk_x;
                            
                            err_cfg_rre_we                = ERR_CFG.l ? 0 : '1;
                            err_cfg_rre_data_in           = reg_wr_data[5];
                            
                            err_cfg_rwe_we                = ERR_CFG.l ? 0 : '1;
                            err_cfg_rwe_data_in           = reg_wr_data[6];
                            
                            err_cfg_rxe_we                = ERR_CFG.l ? 0 : '1; 
                            err_cfg_rxe_data_in           = reg_wr_data[7] && HWCFG0.chk_x;
                        end
                        ERR_REQINFO_OFFSET: begin
                            err_reqinfo_v_we              = '1;
                            err_reqinfo_v_data_in         = reg_wr_data[0];
                        end
                        MDCFG_I_OFFSET: begin
                            mdcfg_t_we[indx]                        =  MDCFGLCK.f > 0 ? 0 : '1; 
                            if(indx == 0) begin
                                mdcfg_t_data_in[indx]               =  reg_wr_data[15:0] > IOPMPRegions ? MDCFG[indx].t : reg_wr_data[15:0];
                            end    
                            else begin
                                mdcfg_t_data_in[indx]               =  (reg_wr_data[15:0] > IOPMPRegions) | reg_wr_data[15:0] < MDCFG[indx - 1].t
                                                                                                          ? MDCFG[indx].t: reg_wr_data[15:0];
                            end 
                        end
                        SRCMD_EN_I_OFFSET: begin
                            srcmd_en_l_we[indx]                    =  '1; 
                            srcmd_en_l_data_in [indx]              =  reg_wr_data[0];
                           
                            srcmd_en_md_we[indx]      = (SRCMD_EN[indx].l == 1)? 0: '1;
                            srcmd_en_md_data_in[indx] = reg_wr_data[31:1];
                        end
                        SRCMD_ENH_I_OFFSET: begin
                            srcmd_enh_md_we[indx]      = (SRCMD_EN[indx].l == 1)? 0: '1;
                            srcmd_enh_md_data_in[indx] = reg_wr_data[31:0];
                        end
                        ENTRY_ADDR_I_OFFSET: begin
                            if((ENTRYLCK.f < indx) | (ENTRYLCK.f == 0 )) begin 
                                entry_addr_we[indx]      = '1;
                                entry_addr_data_in[indx] = reg_wr_data[31:0];
                                //entrylck_f_we = '0;
                                // shifting?
                            end
                        end
            //            ENTRY_ADDRH_I_OFFSET: begin
            //                if(reg_wr_enable & ((ENTRYLCK.f < indx) | (ENTRYLCK.f == 0 ))) begin 
            //                    entry_addrh_table[indx] = reg_wr_data[31:0];
            //                    // shifting?
            //                end
            //            end
                        ENTRY_CFG_I_OFFSET: begin
                            entry_cfg_we[indx]          = '1;
                            if((ENTRYLCK.f < indx) | (ENTRYLCK.f == 0 )) begin 
                                entry_cfg_data_in[indx]        = reg_wr_data[10:0];
                                entry_cfg_data_in[indx][31:11] = '0;
                            end
                        end
            //            default: begin
            //                entrylck_f_we = '0; 
            //            end
                    endcase      
                end
                if(reg_rd_enable) begin
                    unique case(reg_addr)
                        VERSION_OFFSET: begin
                            reg_rr_data_d[23:0] =  VERSION.vendor;
                            reg_rr_data_d[31:24] = VERSION.specver;
                        end
                        IMPLEMENTATION_OFFSET: begin
                            reg_rr_data_d[31:0] = IMPLEMENTATION.impid;
                        end
                        HWCFG0_OFFSET: begin
                            reg_rr_data_d[3:0]   = HWCFG0.model;
                            reg_rr_data_d[4]     = HWCFG0.tor_en;
                            reg_rr_data_d[5]     = HWCFG0.sps_en;
                            reg_rr_data_d[6]     = HWCFG0.user_cfg_en;
                            reg_rr_data_d[7]     = HWCFG0.prient_prog;
                            reg_rr_data_d[8]     = HWCFG0.rrid_transl_en;
                            reg_rr_data_d[9]     = HWCFG0.rrid_transl_prog;
                            reg_rr_data_d[10]    = HWCFG0.chk_x;
                            reg_rr_data_d[11]    = HWCFG0.no_x;
                            reg_rr_data_d[12]    = HWCFG0.no_w;
                            reg_rr_data_d[13]    = HWCFG0.stall_en;
                            reg_rr_data_d[14]    = HWCFG0.peis;
                            reg_rr_data_d[15]    = HWCFG0.pees;
                            reg_rr_data_d[16]    = HWCFG0.mfr_en;
                            reg_rr_data_d[23:17] = HWCFG0.rsv;
                            reg_rr_data_d[30:24] = HWCFG0.md_num;
                            reg_rr_data_d[31]    = HWCFG0.enable;
                        end
                        HWCFG1_OFFSET: begin
                            reg_rr_data_d[15:0]      = HWCFG1.rrid_num;
                            reg_rr_data_d[31:16]     = HWCFG1.entry_num;
                        end
                        HWCFG2_OFFSET: begin
                            reg_rr_data_d[15:0]       = HWCFG2.prio_entry;
                            reg_rr_data_d[31:16]      = HWCFG2.rrid_transl;
                        end
                        ENTRY_OFFSET_OFFSET: begin
                            reg_rr_data_d[31:0]       = ENTRYOFFSET.offset;
                        end
                        MDCFGLCK_OFFSET: begin
                            reg_rr_data_d[0]          = MDCFGLCK.l; 
                            reg_rr_data_d[7:1]        = MDCFGLCK.f; 
                            // mdcfglck_f_data_in    = later... 
                        end
                        ENTRYLCK_OFFSET: begin 
                            reg_rr_data_d[0]          = ENTRYLCK.l; 
                            reg_rr_data_d[16:1]       = ENTRYLCK.f; 
                        end 
                        ERR_CFG_OFFSET: begin
                            reg_rr_data_d[0]           = ERR_CFG.l;
                            reg_rr_data_d[1]           = ERR_CFG.ie;
                            reg_rr_data_d[2]           = ERR_CFG.ire;
                            reg_rr_data_d[3]           = ERR_CFG.iwe;
                            reg_rr_data_d[4]           = ERR_CFG.ixe;
                            reg_rr_data_d[5]           = ERR_CFG.rre;
                            reg_rr_data_d[6]           = ERR_CFG.rwe;
                            reg_rr_data_d[7]           = ERR_CFG.rxe;
                        end
                        ERR_REQINFO_OFFSET: begin
                            reg_rr_data_d[0]           = ERR_REQINFO.v;
                            reg_rr_data_d[2:1]         = ERR_REQINFO.ttype;
                            reg_rr_data_d[6:4]         = ERR_REQINFO.etype;
                            reg_rr_data_d[7]           = ERR_REQINFO.svc;
                        end
                        ERR_REQADDR_OFFSET: begin
                            reg_rr_data_d[31:0]           = ERR_REQADDR.addr;
                        end
                        ERR_REQADDRH_OFFSET: begin
                            reg_rr_data_d[31:0]           = ERR_REQADDRH.addrh;
                        end
                        ERR_REQID_OFFSET: begin
                            reg_rr_data_d[15:0]           = ERR_REQID.rrid;
                            reg_rr_data_d[31:16]          = ERR_REQID.eid;
                        end
                        // ERR_MFR and ERR_USER optinal
                        MDCFG_I_OFFSET: begin
                            reg_rr_data_d[15:0]  = MDCFG[indx].t;
                            reg_rr_data_d[31:16] = '0;
                        end
                        SRCMD_EN_I_OFFSET: begin
                            reg_rr_data_d[31:0] = srcmd_en_table[indx];
                        end
        //                SRCMD_ENH_I_OFFSET: begin
        //                    reg_rr_data_next[31:0] = srcmd_enh_table[indx];
        //                end
                        ENTRY_ADDR_I_OFFSET: begin
                            reg_rr_data_d[31:0] = ENTRY_ADDR[indx].addr; // we take it from the register, 
                                                                        //if we want to take it from the table use this -> //entry_addr_table[indx][33:2]; 
                        end
                //        ENTRY_ADDRH_I_OFFSET: begin
                //            if(reg_wr_enable & ((ENTRYLCK.f < indx) | (ENTRYLCK.f == 0 ))) begin 
                //                entry_addrh_table[indx] = reg_wr_data[31:0];
                //                // shifting?
                //            end
                //        end
                        ENTRY_CFG_I_OFFSET: begin
                            reg_rr_data_d[31:0] = entry_conf_table[indx][10:0];
                        end
                    endcase
                end
            end 
        end
        
        RESP: begin
            slv_opcode = (opcode_q == Get) ? AccessAckData : AccessAck;     
            slv_valid  = 1;
            slv_ready  = 0;
            slv_mst_id = mst_id_q;
            slv_sink   = 8'hAB;
            slv_data   = reg_rr_data_q;
            slv_param  = mst_param_q;
            slv_size   = mst_size_q;
            slv_error  = reg_error_q; 
            if(mst_ready) begin
                next_state = NO_OP;
            end
        end
    endcase       
end

endmodule



