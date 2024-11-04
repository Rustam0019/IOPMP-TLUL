//  Class: uvm_drv_rh
//
`include "uvm_macros.svh"
import uvm_pkg::*; 
class uvm_drv_rh extends uvm_driver#(uvm_transaction_rh);
    `uvm_component_utils(uvm_drv_rh);

    uvm_transaction_rh              tr;
    virtual             intf_rh     vif;

    //  Constructor: new
    function new(string name = "uvm_drv_rh", uvm_component parent);
        super.new(name, parent);
    endfunction: new


    virtual function void build_phase(uvm_phase phase);
        tr = uvm_transaction_rh::type_id::create("tr");   
        if(!uvm_config_db#(virtual intf_rh)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
          `uvm_error("DRV","Cannot get Virtual Control Port Interface from TOP");
        
        super.build_phase(phase);        

    endfunction: build_phase


    task reset_dut();
        begin
            vif.reset = 0;
            #150ns;
            vif.reset = 1;
            vif.tb_wr = 0;
            vif.tb_valid = 0;
            vif.mst_req_i[0]                     <= '0;
            //vif.tb_rd = 0;
            #500ns;
            vif.reset = 0;
        end
    endtask

    task automatic mst_send_req (input logic  [7:0]   mst_indx);
        vif.mst_req_i[mst_indx]                     <= '0;
        #225;
        vif.mst_req_i[mst_indx].a_param             <= tr.mst_param  [mst_indx];
        vif.mst_req_i[mst_indx].a_size              <= tr.mst_size   [mst_indx];
        vif.mst_req_i[mst_indx].a_source            <= tr.mst_source [mst_indx];
        vif.mst_req_i[mst_indx].a_mask              <= tr.mst_mask   [mst_indx];
        vif.mst_req_i[mst_indx].a_valid             <= 1'b1;
        vif.mst_req_i[mst_indx].a_opcode            <= tr.mst_opcode [mst_indx];
        vif.mst_req_i[mst_indx].a_address           <= tr.mst_address[mst_indx];
        vif.mst_req_i[mst_indx].d_ready             <= 1'b1;
        vif.mst_req_i[mst_indx].a_data              <= tr.mst_data   [mst_indx];
        //#10;
        vif.iopmp_permission_denied[mst_indx]       <= tr.iopmp_permission_denied[mst_indx];
        #100;
        vif.mst_req_i[mst_indx].a_valid             <= 1'b0;
        #100;
        `uvm_info("DRV", $sformatf("Master %d REQUEST SENT ", mst_indx), UVM_MEDIUM);
    endtask;
    

    task automatic slv_send_resp (input logic  [7:0]   mst_indx_resp);
        vif.slv_rsp_i[mst_indx_resp]                  <= '0;
        #100;
        vif.slv_rsp_i[mst_indx_resp].d_param          <= tr.slv_param  [mst_indx_resp];
        vif.slv_rsp_i[mst_indx_resp].d_size           <= tr.slv_size   [mst_indx_resp];
        vif.slv_rsp_i[mst_indx_resp].d_source         <= vif.slv_req_o [mst_indx_resp].a_source;
        vif.slv_rsp_i[mst_indx_resp].d_sink           <= tr.slv_sink   [mst_indx_resp];
        vif.slv_rsp_i[mst_indx_resp].d_valid          <= 1'b1;
        vif.slv_rsp_i[mst_indx_resp].d_opcode         <= tr.mst_opcode  [mst_indx_resp] == Get ? AccessAckData : AccessAck;
        vif.slv_rsp_i[mst_indx_resp].d_error          <= 1'b0; //tr.slv_error   [mst_indx_resp];
        vif.slv_rsp_i[mst_indx_resp].a_ready          <= 1'b1;
        vif.slv_rsp_i[mst_indx_resp].d_data           <= tr.slv_data    [mst_indx_resp];
        #100;
        //vif.slv_rsp_i[mst_indx_resp].d_valid          <= 1'b0;
        vif.slv_rsp_i[mst_indx_resp]                    <= '0;
        #200;
        // `uvm_info("DRV", $sformatf("DATA READ: %0h", vif.mst_req_i.a_data), UVM_MEDIUM);
    endtask;


    virtual task run_phase(uvm_phase phase);
        reset_dut();
        #200ns;

        forever begin
            seq_item_port.get_next_item(tr);
            if (tr.op_tr == send_req) begin
                vif.ERR_CFG                = tr.ERR_CFG;
                vif.entry_violated_index_i = tr.entry_violated_index_i;
                vif.entry_conf             = tr.entry_conf;
                fork
                    mst_send_req(0);
                    mst_send_req(1);
                join
                vif.tb_valid                                = 1;
                slv_send_resp(0);
                slv_send_resp(1);
                vif.tb_valid                                = 0;

            end

            seq_item_port.item_done();
        end
    endtask: run_phase
    


    
endclass: uvm_drv_rh
