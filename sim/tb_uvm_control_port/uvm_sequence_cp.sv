//  Class: uvm_sequence_cp
//
`include "uvm_macros.svh"
import uvm_pkg::*; 
class uvm_sequence_cp extends uvm_sequence#(uvm_transaction_cp);
    `uvm_object_utils(uvm_sequence_cp);

    //  Group: Variables
    uvm_transaction_cp              tr;

    int j = 0;

    //  Constructor: new
    function new(string name = "uvm_sequence_cp");
        super.new(name);
    endfunction: new

    //  Task: body
    //  This is the user-defined task where the main sequence code resides.
    virtual task body();
        repeat(1)
            begin 
                `uvm_info("TR", $sformatf("TRANSACTION %0d", j), UVM_NONE);
                j = j + 1;
                tr = uvm_transaction_cp::type_id::create("tr");
                start_item(tr);
                assert(tr.randomize);
                tr.enable               = 1;                 // Indicate if the IOPMP checks transactions by default. If it is implemented, it should be initial to 0 and sticky to 1. If it is not implemented, it should be wired to 1.
                tr.rrid_transl_prog     = 0;                // A write-1-set bit is sticky to 0 and indicate if the field sid_transl is programmable. Support only for rrid_transl_en=1, otherwise, wired to 0.
                tr.prient_prog          = 1;                // A write-1-clear bit is sticky to 0 and indicates if HWCFG2.prio_entry is programmable. Reset to 1 if the implementation supports programmable prio_entry, otherwise, wired to 0.
     
                // Register HWCFG2
                //rand logic [31:16] rrid_transl; 
                //tr.prio_entry           = 2;


                // Configuration Protection
                //tr.mdlck_md;              // md[j] is stickly to 1 and indicates if SRCMD_EN(i).md[j], SRCMD_R(i).md[j] and SRCMD_W(i).md[j] are locked for all i.
                //tr.mdlck_l = 0;           // Lock bit to MDLCK and MDLCKH register.

                //tr.mdlckh_mdh;       // mdh[j] is stickly to 1 and indicates if SRCMD_ENH(i).mdh[j], SRCMD_RH(i).mdh[j] and SRCMD_WH(i).mdh[j] are locked for all i.

      

                tr.mdcfglck_f = 0;                // Indicate the number of locked MDCFG entries - MDCFG(i) is locked for i < f. For Rapid-k model, Dynamic-k model and Compact-k model, f is ignored. For the rest of the models, the field should be monotonically increased only until the next reset cycle.
                tr.mdcfglck_l = 0;               // Lock bit to MDCFGLCK register. For Rapid-k model and Compact-k model, l should be 1. For Dynamic-K model, l indicates if MDCFG(0).t is still programmable or locked.

      

                tr.entrylck_f = 0;        // Indicate the number of locked IOPMP entries - ENTRY_ADDR(i), ENTRY_ADDRH(i), ENTRY_CFG(i), and ENTRY_USER_CFG(i) are locked for i < f. The field should be monotonically increased only until the next reset cycle.
                tr.entrylck_l = 0;        // Lock bit to ENTRYLCK register.


                // Register ERR_CFG
                 tr.err_cfg_rxe = 0;        // Response on an illegal instruction fetch
                // tr.err_cfg_rwe;          // Response on an illegal write access:
                // tr.err_cfg_rre;          // Response on an illegal read accesses
                tr.err_cfg_ixe  = 0;        // To trigger an interrupt on an illegal instruction fetch. Implemented only for HWCFG0.chk_x=1.
                // tr.err_cfg_iwe;          // To trigger an interrupt on an illegal write access
                // tr.err_cfg_ire;          // To trigger an interrupt on an illegal read access
                tr.err_cfg_ie = 1;          // Enable the interrupt of the IOPMP
                tr.err_cfg_l  = 0;          // Lock fields to ERR_CFG register



                // Register ERR_REQINFO
                tr.err_req_info_v = 1; 

                // Register MDCFG
                //tr.mdcfg_t[cp_file_pkg::IOPMPMemoryDomains];

                // Register SRCMD_EN
                //tr.srcmd_en_md[];
                foreach(tr.srcmd_en_l[i]) begin
                    tr.srcmd_en_l[i] = '0;  // Initialize each element to zero
                end
                

                // Register SRCMD_ENH
                //tr.srcmd_enh_mdh = '0;

                // Register ENTRY_CFG
                // tr.entry_cfg_sexe[];                 // Supress the (bus) error on an illegal instruction fetch caught by the entry
                // tr.entry_cfg_sewe[];                 // Supress the (bus) error on an illegal write access caught by the entry
                // tr.entry_cfg_sere[];                 // Supress the (bus) error on an illegal read access caught by the entry
                // tr.entry_cfg_sixe[];                 // Suppress interrupt on an illegal instruction fetch caught by the entry
                // tr.entry_cfg_siwe[];                 // Suppress interrupt for write violations caught by the entry
                // tr.entry_cfg_sire[];                 // To suppress interrupt for an illegal read access caught by the entry
                // tr.cfg_mode_addr entry_cfg_a[];      // The address mode of the IOPMP entry
                // tr.entry_cfg_x[];                    // The instruction fetch permission to the protected memory region
                // tr.entry_cfg_w[];                    // The write permission to the protected memory region
                // tr.entry_cfg_r[];                    // The read permission to protected memory region


                // Register ENTRY_ADDR
                //tr.entry_addr_addr[];
                tr.ID           = 8'b00000111;
                tr.msk          = 8'b11111111;
                tr.op           = PutFullData; 
                tr.op_tr        = write_reg;
                finish_item(tr);
            end
    endtask


  
    
endclass: uvm_sequence_cp