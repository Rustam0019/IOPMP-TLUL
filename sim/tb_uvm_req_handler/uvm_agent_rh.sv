//  Class: uvm_agent_rh
//

class uvm_agent_rh extends uvm_component;
    `uvm_component_utils(uvm_agent_rh);

    // Components
    uvm_drv_rh drv;
    uvm_sequencer#(uvm_transaction_rh) seqr;
    uvm_mon_rh mon;

    //  Constructor: new
    function new(string name = "uvm_agent_rh", uvm_component parent);
        super.new(name, parent);
    endfunction: new

   
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv             = uvm_drv_rh::type_id::create("drv", this);
        seqr            = uvm_sequencer#(uvm_transaction_rh)::type_id::create("seqr", this);
        mon             = uvm_mon_rh::type_id::create("mon", this);

    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction: connect_phase


    
endclass: uvm_agent_rh
