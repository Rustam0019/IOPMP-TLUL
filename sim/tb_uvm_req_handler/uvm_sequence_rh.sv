//  Class: uvm_sequence_rh
//
`include "uvm_macros.svh"
import uvm_pkg::*; 
class uvm_sequence_rh extends uvm_sequence#(uvm_transaction_rh);
    `uvm_object_utils(uvm_sequence_rh);

    //  Group: Variables
    uvm_transaction_rh              tr;

    int i = 0;

    //  Constructor: new
    function new(string name = "uvm_sequence_rh");
        super.new(name);
    endfunction: new

    //  Task: body
    //  This is the user-defined task where the main sequence code resides.
    virtual task body();
        repeat(6)
            begin 
                `uvm_info("TR", $sformatf("TRANSACTION %0d", i), UVM_NONE);
                i = i + 1;
                tr = uvm_transaction_rh::type_id::create("tr");
                start_item(tr);
                assert(tr.randomize);
                tr.op_tr = send_req;
    
                // mst request signals
                foreach(tr.mst_valid[j]) begin
                    tr.mst_valid[j] = 1'b1;
                    tr.mst_param[j] = '0;
                    tr.mst_size[j]  = 2'b10;
                    tr.mst_ready[j] = 1'b1;

                    // slv response signals
                    tr.slv_valid [j] = 1'b1;
                    tr.slv_param [j] = '0;
                    tr.slv_size  [j] = 2'b10;   // Bouncing back a_size
                    // tr.slv_source[j] = ;
                    // tr.slv_error [j] = ;
                    tr.slv_ready [j] = 1'b1;
                end

                finish_item(tr);
            end
    endtask


  
    
endclass: uvm_sequence_rh