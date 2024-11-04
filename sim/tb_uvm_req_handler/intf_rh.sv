import top_pkg::*;
import tlul_pkg::*;
import config_pkg::*;
import iopmp_pkg::*;

interface intf_rh();

    logic                                   clk;
    logic                                   reset;

    tl_h2d_t                                mst_req_i[rh_file_pkg::IOPMPNumChan];
    tl_d2h_t                                mst_rsp_o[rh_file_pkg::IOPMPNumChan]; 
    
    tl_d2h_t                                slv_rsp_i[rh_file_pkg::IOPMPNumChan];
    tl_h2d_t                                slv_req_o[rh_file_pkg::IOPMPNumChan];
    logic                                   iopmp_permission_denied[rh_file_pkg::IOPMPNumChan];
    logic [8:0]                             entry_violated_index_i[rh_file_pkg::IOPMPNumChan];
    iopmp_pkg::err_cfg                      ERR_CFG;
    iopmp_pkg::entry_cfg                    entry_conf  [rh_file_pkg::IOPMPRegions];

    
    logic [33:0]                            iopmp_check_addr_o  [rh_file_pkg::IOPMPNumChan];
    iopmp_req_e                             iopmp_check_access_o[rh_file_pkg::IOPMPNumChan];
    //logic                                   iopmp_check_en_o[rh_file_pkg::IOPMPNumChan],
    logic [SourceWidth - 1 : 0 ]            rrid[rh_file_pkg::IOPMPNumChan];

    logic                                   tb_wr;
    logic                                   tb_valid;

endinterface