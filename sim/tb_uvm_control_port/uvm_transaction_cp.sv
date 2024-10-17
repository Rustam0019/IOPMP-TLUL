//  Class: uvm_transaction_cp
//
`include "uvm_macros.svh"
import uvm_pkg::*; 
typedef enum bit [1:0] {write_reg = 0, read_op = 1} op_mode;

class uvm_transaction_cp extends uvm_sequence_item;
    typedef uvm_transaction_cp this_type_t;
    `uvm_object_utils(uvm_transaction_cp);

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


    op_mode op_tr;

    // Register HWCFG0
    rand logic [31:31]                     enable;                 // Indicate if the IOPMP checks transactions by default. If it is implemented, it should be initial to 0 and sticky to 1. If it is not implemented, it should be wired to 1.
    rand logic [9:9]                       rrid_transl_prog;       // A write-1-set bit is sticky to 0 and indicate if the field sid_transl is programmable. Support only for rrid_transl_en=1, otherwise, wired to 0.
    rand logic [7:7]                       prient_prog;            // A write-1-clear bit is sticky to 0 and indicates if HWCFG2.prio_entry is programmable. Reset to 1 if the implementation supports programmable prio_entry, otherwise, wired to 0.
     


    // Register HWCFG1
    logic rrid_num;
    logic entry_num;

    // Register HWCFG2
    //rand logic [31:16] rrid_transl; 
    rand logic [15:0]  prio_entry;
    constraint prio_entry_c {
        prio_entry >= 2 &&  prio_entry <= 16'h4;       
    }
    


    // Configuration Protection
    // Optional not implemented begin
    // rand logic [31:1] mdlck_md;       // md[j] is stickly to 1 and indicates if SRCMD_EN(i).md[j], SRCMD_R(i).md[j] and SRCMD_W(i).md[j] are locked for all i.
    // rand logic mdlck_l;               // Lock bit to MDLCK and MDLCKH register.

      
      
    // rand logic [31:0] mdlckh_mdh;       // mdh[j] is stickly to 1 and indicates if SRCMD_ENH(i).mdh[j], SRCMD_RH(i).mdh[j] and SRCMD_WH(i).mdh[j] are locked for all i.
    // end
      

    rand logic [7:1]  mdcfglck_f;               // Indicate the number of locked MDCFG entries - MDCFG(i) is locked for i < f. For Rapid-k model, Dynamic-k model and Compact-k model, f is ignored. For the rest of the models, the field should be monotonically increased only until the next reset cycle.
    constraint mdcfglck_f_c {
        mdcfglck_f >= 1 &&  mdcfglck_f <= (cp_file_pkg::IOPMPMemoryDomains - 1);  // should be memory domain here     
    }
    rand logic        mdcfglck_l;               // Lock bit to MDCFGLCK register. For Rapid-k model and Compact-k model, l should be 1. For Dynamic-K model, l indicates if MDCFG(0).t is still programmable or locked.

      

    rand logic [16:1]  entrylck_f;                 // Indicate the number of locked IOPMP entries - ENTRY_ADDR(i), ENTRY_ADDRH(i), ENTRY_CFG(i), and ENTRY_USER_CFG(i) are locked for i < f. The field should be monotonically increased only until the next reset cycle.
    constraint entrylck_f_c {
        entrylck_f >= 0 &&  entrylck_f <= (cp_file_pkg::IOPMPRegions - 1);  // should be memory domain here     
    }
    rand logic         entrylck_l;                // Lock bit to ENTRYLCK register.


    // Register ERR_CFG
    rand logic [7:7]  err_cfg_rxe;       // Response on an illegal instruction fetch
    rand logic [6:6]  err_cfg_rwe;       // Response on an illegal write access:
    rand logic [5:5]  err_cfg_rre;       // Response on an illegal read accesses
    rand logic [4:4]  err_cfg_ixe;       // To trigger an interrupt on an illegal instruction fetch. Implemented only for HWCFG0.chk_x=1.
    rand logic [3:3]  err_cfg_iwe;       // To trigger an interrupt on an illegal write access
    rand logic [2:2]  err_cfg_ire;       // To trigger an interrupt on an illegal read access
    rand logic [1:1]  err_cfg_ie;        // Enable the interrupt of the IOPMP
    rand logic [0:0]  err_cfg_l;         // Lock fields to ERR_CFG register



    // Register ERR_REQINFO
    rand logic [0:0]       err_req_info_v; 

    // Register MDCFG
    rand logic [15:0] mdcfg_t[cp_file_pkg::IOPMPMemoryDomains];
    constraint mdcfg_t_c {
        foreach(mdcfg_t[i]) {
            1 <= mdcfg_t[i] && mdcfg_t[i] < cp_file_pkg::IOPMPRegions;
            if (i > 0) {
                mdcfg_t[i] > mdcfg_t[i-1];  // Ensure each element is greater than the previous one
            }
        }
    }

    //Register SRCMD_EN
    rand logic [31:1] srcmd_en_md[cp_file_pkg::NUM_MASTERS];
    constraint srcmd_en_md_c {
        foreach(srcmd_en_md[i]) {
            (srcmd_en_md[i] > 0 ) && (srcmd_en_md[i] < (2**(cp_file_pkg::IOPMPMemoryDomains))); 
            // if (i > 0) {
            //     srcmd_en_md[i] > srcmd_en_md[i-1];  // Ensure each element is greater than the previous one
            // }
        }
    }
    logic [0:0] srcmd_en_l[NUM_MASTERS];

//    // Register SRCMD_ENH
//    rand logic [31:0] srcmd_enh_mdh[NUM_MASTERS];

   // Register ENTRY_CFG
   rand logic entry_cfg_sexe[IOPMPRegions];                 // Supress the (bus) error on an illegal instruction fetch caught by the entry
   rand logic entry_cfg_sewe[IOPMPRegions];                 // Supress the (bus) error on an illegal write access caught by the entry
   rand logic entry_cfg_sere[IOPMPRegions];                 // Supress the (bus) error on an illegal read access caught by the entry
   rand logic entry_cfg_sixe[IOPMPRegions];                 // Suppress interrupt on an illegal instruction fetch caught by the entry
   rand logic entry_cfg_siwe[IOPMPRegions];                 // Suppress interrupt for write violations caught by the entry
   rand logic entry_cfg_sire[IOPMPRegions];                 // To suppress interrupt for an illegal read access caught by the entry
   rand iopmp_cfg_mode_addr entry_cfg_a[IOPMPRegions];      // The address mode of the IOPMP entry
   rand logic entry_cfg_x[IOPMPRegions];                    // The instruction fetch permission to the protected memory region
   rand logic entry_cfg_w[IOPMPRegions];                    // The write permission to the protected memory region
   rand logic entry_cfg_r[IOPMPRegions];                    // The read permission to protected memory region


   // Register ENTRY_ADDR
   rand logic [31:0] entry_addr_addr[cp_file_pkg::IOPMPRegions];
   constraint entry_table_c {
    foreach(entry_addr_addr[i]) {
        entry_addr_addr[i] inside {32'h2000_0000, 32'h4000_0000, 32'h8000_0000};
        if(entry_cfg_a[i] == IOPMP_MODE_TOR){
            entry_addr_addr[i - 1] < entry_addr_addr[i];
        }
        //(entry_addr_addr[i] >= 32'h2000_0000 ) && (entry_addr_addr[i] < (32'h9000_0000)); 
    }
}

    //  Constructor: new
    function new(string name = "uvm_transaction_cp");
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
    
endclass: uvm_transaction_cp


