//  Class: uvm_agent_cp
//

class uvm_agent_cp extends uvm_component;
    `uvm_component_utils(uvm_agent_cp);

    // Components
    uvm_drv_cp drv;
    uvm_sequencer#(uvm_transaction_cp) seqr;
    uvm_mon_cp mon;

    //  Constructor: new
    function new(string name = "uvm_agent_cp", uvm_component parent);
        super.new(name, parent);
    endfunction: new

   
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv             = uvm_drv_cp::type_id::create("drv", this);
        seqr            = uvm_sequencer#(uvm_transaction_cp)::type_id::create("seqr", this);
        mon             = uvm_mon_cp::type_id::create("mon", this);

    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction: connect_phase


    
endclass: uvm_agent_cp
