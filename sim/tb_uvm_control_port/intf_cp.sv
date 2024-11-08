import top_pkg::*;
import tlul_pkg::*;
import config_pkg::*;
import iopmp_pkg::*;
import cp_file_pkg::*;

interface intf_cp();
    
    logic                                    clk;
    logic                                    reset;
    tl_h2d_t                                 mst_req_i;
    tl_d2h_t                                 slv_rsp_o;
    
    error_registers_t                        error_report_i;
    error_registers_t                        error_report_o;
    
    iopmp_pkg::entry_cfg                    entry_conf_table  [cp_file_pkg::IOPMPRegions];
    logic [33:0]                            entry_addr_table  [cp_file_pkg::IOPMPRegions];
    logic [15:0]                            mdcfg_table       [cp_file_pkg::IOPMPMemoryDomains];
    logic [31:0]                            srcmd_en_table    [cp_file_pkg::NUM_MASTERS];
    logic [15:0]                            prio_entry_num;

    logic                                   tb_wr;
    logic                                   tb_rd;

endinterface