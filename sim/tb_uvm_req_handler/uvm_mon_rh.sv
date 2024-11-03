//  Class: uvm_mon_rh
//
`include "uvm_macros.svh"
import uvm_pkg::*; 
class uvm_mon_rh extends uvm_monitor;
    `uvm_component_utils(uvm_mon_rh);

    uvm_analysis_port#(uvm_transaction_rh) send;
    uvm_transaction_rh              tr;
    virtual             intf_rh    vif;


    //  Constructor: new
    function new(string name = "uvm_mon_rh", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr =  uvm_transaction_rh::type_id::create("tr");
        send = new("send", this);

        if(!uvm_config_db#(virtual intf_rh)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
          `uvm_error("MON","Cannot get Virtual Control Port Interface from TOP");
        
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        forever begin
            if(vif.reset) begin
                tr.reset = 1'b0;
                `uvm_info("Monitor", "SYSTEM RESET", UVM_NONE)
                send.write(tr);
            end

            else begin
                fork
                    begin
                        wait(vif.tb_valid == 1);
                        for (int j = 0; j < (rh_file_pkg::IOPMPNumChan); j++) begin
                            //if(vif.mst_req_i[j].a_valid) begin
                                tr.mst_address              [j]              = vif.mst_req_i[j].a_address;
                                tr.mst_opcode               [j]              = vif.mst_req_i[j].a_opcode;
                                tr.iopmp_check_addr_o       [j]              = vif.iopmp_check_addr_o[j];
                                tr.iopmp_check_access_o     [j]              = vif.iopmp_check_access_o[j];
                                tr.iopmp_permission_denied  [j]              = vif.iopmp_permission_denied[j];
                            //end
                        end
                    end
                    begin
                        // for (int j = 0; j < (rh_file_pkg::IOPMPNumChan); j++) begin
                        //     //@(posedge vif.mst_rsp_o[j].d_valid);
                        //     wait(vif.mst_rsp_o[j].d_valid == 1);
                        //     `uvm_info("Monitor", "HERE 3", UVM_NONE)
                        //     tr.mst_rsp_o                [j]              = vif.mst_rsp_o[j];
                        // end      
                        
                        fork
                            begin
                                wait(vif.mst_rsp_o[0].d_valid == 1);
                                tr.mst_rsp_o                [0]              = vif.mst_rsp_o[0];
                            end
                            begin
                                wait(vif.mst_rsp_o[1].d_valid == 1);
                                tr.mst_rsp_o                [1]              = vif.mst_rsp_o[1];
                            end
                        join
                        // Add the same begin..end block with different index, if you increase the number of masters.
                    end
                join
                wait(vif.tb_valid == 0);
                `uvm_info("MON", $sformatf("DATA COLLECTED"), UVM_MEDIUM);
                send.write(tr);

            end
        end
    endtask: run_phase  
endclass: uvm_mon_rh
