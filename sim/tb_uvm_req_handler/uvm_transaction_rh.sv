//  Class: uvm_transaction_rh
//
`include "uvm_macros.svh"
import uvm_pkg::*; 
typedef enum bit [1:0] {send_req = 0, def = 1} op_mode_t;

class uvm_transaction_rh extends uvm_sequence_item;
    typedef uvm_transaction_rh this_type_t;
    `uvm_object_utils(uvm_transaction_rh);

    //  Group: Variables
    // Reference data
    logic   reset;
    logic   [top_pkg::TL_DW-1:0]  ref_wr_data;
    logic   [top_pkg::TL_DW-1:0]  reg_data;
    logic   [top_pkg::TL_AW-1:0]  reg_address;

    // TL_UL
    logic           [top_pkg::TL_AIW-1:0]           ID;
    rand logic      [top_pkg::TL_DBW-1:0]           msk; 
    tl_a_op_e                                       op; 


    op_mode_t op_tr;
    
    // mst request signals
    logic                              mst_valid  [rh_file_pkg::IOPMPNumChan];
    rand tl_a_op_e                     mst_opcode [rh_file_pkg::IOPMPNumChan];
    logic                  [2:0]       mst_param  [rh_file_pkg::IOPMPNumChan];
    logic  [top_pkg::TL_SZW-1:0]       mst_size   [rh_file_pkg::IOPMPNumChan];
    rand logic  [top_pkg::TL_AIW-1:0]  mst_source [rh_file_pkg::IOPMPNumChan];
    rand logic  [top_pkg::TL_AW-1:0]   mst_address[rh_file_pkg::IOPMPNumChan];
    rand logic  [top_pkg::TL_DBW-1:0]  mst_mask   [rh_file_pkg::IOPMPNumChan];
    rand logic  [top_pkg::TL_DW-1:0]   mst_data   [rh_file_pkg::IOPMPNumChan];
    logic                              mst_ready  [rh_file_pkg::IOPMPNumChan];

    // slv response signals
    logic                              slv_valid [rh_file_pkg::IOPMPNumChan];
    rand tl_d_op_e                     slv_opcode[rh_file_pkg::IOPMPNumChan];
    logic                  [2:0]       slv_param;
    logic       [top_pkg::TL_SZW-1:0]  slv_size;   // Bouncing back a_size
    logic       [top_pkg::TL_AIW-1:0]  slv_source[rh_file_pkg::IOPMPNumChan];
    rand logic  [top_pkg::TL_DIW-1:0]  slv_sink  [rh_file_pkg::IOPMPNumChan];
    rand logic  [top_pkg::TL_DW-1:0]   slv_data  [rh_file_pkg::IOPMPNumChan];
    logic                              slv_error [rh_file_pkg::IOPMPNumChan];
    logic                              slv_ready [rh_file_pkg::IOPMPNumChan];
    

    logic [33:0]                           iopmp_check_addr_o     [rh_file_pkg::IOPMPNumChan];
    iopmp_req_e                            iopmp_check_access_o   [rh_file_pkg::IOPMPNumChan];
    rand logic                             iopmp_permission_denied[rh_file_pkg::IOPMPNumChan];
    rand logic [8:0]                       entry_violated_index_i[rh_file_pkg::IOPMPNumChan];
    rand iopmp_pkg::entry_cfg              entry_conf            [rh_file_pkg::IOPMPRegions];
    rand iopmp_pkg::err_cfg                ERR_CFG;

    //logic [7:7]  err_cfg_rxe;       // Response on an illegal instruction fetch
    rand logic [6:6]  err_cfg_rwe;       // Response on an illegal write access:
    rand logic [5:5]  err_cfg_rre;       // Response on an illegal read accesses
    //logic [4:4]  err_cfg_ixe;       // To trigger an interrupt on an illegal instruction fetch. Implemented only for HWCFG0.chk_x=1.
    //rand logic [3:3]  err_cfg_iwe;       // To trigger an interrupt on an illegal write access
    //rand logic [2:2]  err_cfg_ire;       // To trigger an interrupt on an illegal read access
    //logic [1:1]  err_cfg_ie;        // Enable the interrupt of the IOPMP

    constraint  entry_violated_index_i_c{
        foreach (entry_violated_index_i[i]) {
            0 <= entry_violated_index_i[i][7:0] && entry_violated_index_i[i][7:0] <= rh_file_pkg::IOPMPRegions;       
        }
    }
    


    // Outputs to compare
    tl_d2h_t                               mst_rsp_o[rh_file_pkg::IOPMPNumChan];

    //  Constructor: new
    function new(string name = "uvm_transaction_rh");
        super.new(name);
    endfunction: new

    //  Function: do_copy
    // extern function void do_copy(uvm_object rhs);
    //  Function: do_compare
    // extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    //  Function: convert2string
    // extern function string convert2string();
    //  Function: do_print
    // extern function void do_print(uvm_printer printer);
    //  Function: do_record
    // extern function void do_record(uvm_recorder recorder);
    //  Function: do_pack
    // extern function void do_pack();
    //  Function: do_unpack
    // extern function void do_unpack();
    
endclass: uvm_transaction_rh


