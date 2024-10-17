//  Class: uvm_mon_cp
//
`include "uvm_macros.svh"
import uvm_pkg::*; 
class uvm_mon_cp extends uvm_monitor;
    `uvm_component_utils(uvm_mon_cp);

    uvm_analysis_port#(uvm_transaction_cp) send;
    uvm_transaction_cp              tr;
    virtual             intf_cp    vif;


    //  Constructor: new
    function new(string name = "uvm_mon_cp", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr =  uvm_transaction_cp::type_id::create("tr");
        send = new("send", this);

        if(!uvm_config_db#(virtual intf_cp)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
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
                // bit wr_signal_detect = 0;
                // bit rd_signal_detect = 0;

                // fork
                //     begin
                //     @ (negedge x_cfg.vif.local_wr);
                //     wr_signal_detect = 1;
                //     end

                //     begin
                //     @(negedge x_cfg.vif.rddata_en_i or negedge x_cfg.vif.local_rd);
                //     rd_signal_detect = 1;
                //     end
                // join_none

                // wait (wr_signal_detect || rd_signal_detect);

                //wait(vif.tb_rd == 1'b1);

                @(posedge vif.mst_req_i.a_valid);

                // wait(vif.tb_wr == 1'b1);
                tr.reg_address    = vif.mst_req_i.a_address;
                // case (tr.reg_address)
                //     HWCFG0_OFFSET: begin
                //         tr.ref_wr_data    = vif.mst_req_i.a_data;
                //     end
                //     HWCFG1_OFFSET: begin
                //         tr.ref_wr_data    = {cp_file_pkg::IOPMPRegions, cp_file_pkg::NUM_MASTERS};
                //     end
                //     HWCFG2_OFFSET: begin
                //         tr.ref_wr_data    = vif.mst_req_i.a_data;
                //     end
                // endcase
                tr.ref_wr_data    = vif.mst_req_i.a_data;
                wait(vif.tb_wr == 1'b1);
                //wait(vif.tb_rd == 1'b1);
 
                @(posedge vif.slv_rsp_o.d_valid);
                // @(negedge vif.mst_req_i.a_valid);
                vif.tb_wr = 0;
                vif.tb_rd = 0;
                tr.reg_data    = vif.slv_rsp_o.d_data;
                `uvm_info("MON", $sformatf("REF: %0b, REG: %0b", tr.ref_wr_data,  tr.reg_data), UVM_NONE);
                send.write(tr);

            end
        end
    endtask: run_phase


    

    
endclass: uvm_mon_cp
