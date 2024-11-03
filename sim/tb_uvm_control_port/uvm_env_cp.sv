//  Class: uvm_env_cp
//
`include "uvm_macros.svh"
import uvm_pkg::*; 
class uvm_env_cp extends uvm_component;
    `uvm_component_utils(uvm_env_cp);

    uvm_agent_cp                agent0;
    uvm_sco_cp                  sco;
    virtual     intf_cp         vif;

    
    //  Group: Functions

    //  Constructor: new
    function new(string name = "uvm_env_cp", uvm_component parent);
        super.new(name, parent);
    endfunction: new


    virtual function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);
        sco           =       uvm_sco_cp::type_id::create("sco", this);
       
        
        
        if (!uvm_config_db #(virtual intf_cp)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "Cannot get Virtual Control Port Interface from TOP")
    
        
        agent0          =       uvm_agent_cp::type_id::create("agent0",this);
        
        
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent0.mon.send.connect(sco.recv0);
    endfunction


    
endclass: uvm_env_cp
