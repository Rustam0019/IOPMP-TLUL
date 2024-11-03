//  Class: uvm_test_cp
//
class uvm_test_cp extends uvm_component;
    `uvm_component_utils(uvm_test_cp);

    //  Group: Configuration Object(s)

    //  Var: config_obj
    //config_obj_t config_obj;

    uvm_env_cp                  env;
    virtual     intf_cp         vif;
    uvm_sequence_cp             single_write;
    //write_cmd single_write;
    //read_cmd single_read;


    //  Group: Functions

    //  Constructor: new
    function new(string name = "uvm_test_cp", uvm_component parent);
        super.new(name, parent);
    endfunction: new



    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env                 =        uvm_env_cp::type_id::create("env",this);  
        single_write        =        uvm_sequence_cp::type_id::create("single_write");
        //single_read         =        read_cmd::type_id::create("single_read");
    
        
        
        // if(!uvm_config_db#(virtual intf_cp)::get(this, "", "vif", vif))
        // `uvm_fatal("BASE_TEST", "Cannot get Virtual Control Port Interface from TOP")
        
        
        //uvm_config_db#(env_config)::set(this, "*", "env_config", env_cfg);
        

        super.build_phase(phase);

    endfunction
         
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        single_write.start(env.agent0.seqr, null, 1);
        #2000;


        phase.drop_objection(this);
    endtask


    
endclass: uvm_test_cp
