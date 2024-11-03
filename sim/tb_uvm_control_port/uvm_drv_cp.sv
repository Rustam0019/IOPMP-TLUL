//  Class: uvm_drv_cp
//
`include "uvm_macros.svh"
import uvm_pkg::*; 
class uvm_drv_cp extends uvm_driver#(uvm_transaction_cp);
    `uvm_component_utils(uvm_drv_cp);

    uvm_transaction_cp              tr;
    virtual             intf_cp     vif;

    //  Constructor: new
    function new(string name = "uvm_drv_cp", uvm_component parent);
        super.new(name, parent);
    endfunction: new


    virtual function void build_phase(uvm_phase phase);
        tr = uvm_transaction_cp::type_id::create("tr");   
        if(!uvm_config_db#(virtual intf_cp)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
          `uvm_error("DRV","Cannot get Virtual Control Port Interface from TOP");
        
        super.build_phase(phase);        

    endfunction: build_phase


    task reset_dut();
        begin
            vif.reset = 0;
            #150ns;
            vif.reset = 1;
            vif.tb_wr = 0;
            vif.tb_rd = 0;
            #500ns;
            vif.reset = 0;
        end
    endtask

    task automatic iopmp_reg_write (input logic  [top_pkg::TL_AW-1:0]   addr);

        logic   [top_pkg::TL_DW-1:0]  w_data;
        logic   [config_pkg::AddrWidth -  1: 0] MDCFG_I_OFFSET;
        logic   [config_pkg::AddrWidth -  1: 0] SRCMD_EN_I_OFFSET;
        logic   [config_pkg::AddrWidth -  1: 0] ENTRY_ADDR_I_OFFSET;
        //logic   [config_pkg::AddrWidth -  1: 0] ENTRY_ADDRH_I_OFFSET;
        logic   [config_pkg::AddrWidth -  1: 0] ENTRY_CFG_I_OFFSET;
        int j;
        logic [7:0] indx;
        for(j = 0; j < cp_file_pkg::IOPMPMemoryDomains; j++) begin
            if(addr == (MDCFG_OFFSET + j * 4)) begin 
                MDCFG_I_OFFSET = MDCFG_OFFSET + j * 4;
                indx                = j;
                break;
            end
        end

        for(j = 0; j < cp_file_pkg::NUM_MASTERS; j++) begin
            if(addr == (SRCMD_EN_OFFSET + j * 32)) begin 
                SRCMD_EN_I_OFFSET = SRCMD_EN_OFFSET + j * 32;
                indx                = j;
                break;
            end
            // else if(reg_addr == (SRCMD_ENH_OFFSET + j * 32)) begin 
            //     SRCMD_ENH_I_OFFSET = SRCMD_ENH_OFFSET + j * 32;
            //     indx                = j;
            // end
        end 

        for(integer j = 0; j < cp_file_pkg::IOPMPRegions; j++) begin
            if(addr == (ENTRY_OFFSET + j * 16)) begin 
                ENTRY_ADDR_I_OFFSET = ENTRY_OFFSET + j * 16;
                indx                = j;
            end
            // else if(reg_addr == (ENTRY_OFFSET + j * 16 + 4)) begin 
            //     ENTRY_ADDRH_I_OFFSET = ENTRY_OFFSET + j * 16 + 4;
            //     indx                = j;
            // end
            else if(addr == (ENTRY_OFFSET + j * 16 + 8)) begin 
                ENTRY_CFG_I_OFFSET = ENTRY_OFFSET + j * 16 + 8;
                indx                = j;
            end
        end


        case (addr)
            HWCFG0_OFFSET: begin
                w_data      = '1;
                w_data[31]  = tr.enable;
                w_data[9]   = tr.rrid_transl_prog;
                w_data[7]   = tr.prient_prog;
            end
            HWCFG1_OFFSET: begin
                w_data      = '1;
            end
            HWCFG2_OFFSET: begin
                w_data        = '0;
                w_data[15:0]  = tr.prio_entry;
            end
            ENTRY_OFFSET_OFFSET: begin
                w_data = $urandom();
            end
            MDCFGLCK_OFFSET: begin
                w_data              = '0;
                w_data[0]           = tr.mdcfglck_l;
                w_data[7:1]         = tr.mdcfglck_f;
            end
            ENTRYLCK_OFFSET: begin
                w_data               = '0;
                w_data[0]            = tr.entrylck_l;
                w_data[16:1]         = tr.entrylck_f;
            end
            ERR_CFG_OFFSET: begin
                w_data               = '0;
                w_data[0]            = tr.err_cfg_l;
                w_data[1]            = tr.err_cfg_ie;
                w_data[2]            = tr.err_cfg_ire;
                w_data[3]            = tr.err_cfg_iwe;
                w_data[4]            = tr.err_cfg_ixe;
                w_data[5]            = tr.err_cfg_rre;
                w_data[6]            = tr.err_cfg_rwe;
                w_data[7]            = tr.err_cfg_rxe;
            end
            ERR_REQINFO_OFFSET: begin
                w_data               = '0;
                w_data[0]            = tr.err_req_info_v;
            end
            
            MDCFG_I_OFFSET: begin
                w_data                  = '0;
                w_data[15:0]            = tr.mdcfg_t[indx];
            end
            SRCMD_EN_I_OFFSET: begin
                w_data[0]                  = tr.srcmd_en_l[indx];
                w_data[31:1]               = tr.srcmd_en_md[indx];
            end
            ENTRY_ADDR_I_OFFSET: begin
                w_data[31:0]               = tr.entry_addr_addr[indx];
            end
            ENTRY_CFG_I_OFFSET: begin
                w_data                     = '0;
                w_data[0]                  = tr.entry_cfg_r[indx];
                w_data[1]                  = tr.entry_cfg_w[indx];
                w_data[2]                  = tr.entry_cfg_x[indx];
                w_data[4:3]                = tr.entry_cfg_a[indx];
                w_data[5]                  = tr.entry_cfg_sire[indx];
                w_data[6]                  = tr.entry_cfg_siwe[indx];
                w_data[7]                  = tr.entry_cfg_sixe[indx];
                w_data[8]                  = tr.entry_cfg_sere[indx];
                w_data[9]                  = tr.entry_cfg_sewe[indx];
                w_data[10]                 = tr.entry_cfg_sexe[indx];               
            end
            default: w_data      = '0;
        endcase

        vif.mst_req_i.a_param          <= '0;
        vif.mst_req_i.a_size           <= 2'b10;
        vif.mst_req_i.a_source         <= tr.ID;
        vif.mst_req_i.a_mask           <= tr.msk;
        vif.mst_req_i.a_valid          <= 1'b1;
        vif.mst_req_i.a_opcode         <= tr.op;
        vif.mst_req_i.a_address        <= addr;
        vif.mst_req_i.d_ready          <= 1'b1;
        vif.mst_req_i.a_data           <= w_data;
        #100;
        vif.mst_req_i.a_valid        <= 1'b0;
        #200;
        `uvm_info("DRV", $sformatf("DATA WRITE: %0h", vif.mst_req_i.a_data), UVM_MEDIUM);
    endtask;
    

    task automatic iopmp_reg_read (input logic  [top_pkg::TL_AW-1:0]   addr);
        vif.mst_req_i.a_param          <= '0;
        vif.mst_req_i.a_size           <= 2'b10;
        vif.mst_req_i.a_source         <= tr.ID;
        vif.mst_req_i.a_mask           <= tr.msk;
        vif.mst_req_i.a_valid          <= 1'b1;
        vif.mst_req_i.a_opcode         <= Get;
        vif.mst_req_i.a_address        <= addr;
        vif.mst_req_i.d_ready          <= 1'b1;
        vif.mst_req_i.a_data           <= '0;
        #100;
        vif.mst_req_i.a_valid          <= 1'b0;
        #200;
        // `uvm_info("DRV", $sformatf("DATA READ: %0h", vif.mst_req_i.a_data), UVM_MEDIUM);
    endtask;


    virtual task run_phase(uvm_phase phase);
        reset_dut();
        #200ns;

        forever begin
            seq_item_port.get_next_item(tr);
            if (tr.op_tr == write_reg) begin
                //vif.tb_rd = 1;
                iopmp_reg_write(HWCFG0_OFFSET);
                vif.tb_wr = 1;
                iopmp_reg_read(HWCFG0_OFFSET);

                // //vif.tb_rd = 1; // remember
                iopmp_reg_write(HWCFG1_OFFSET);
                vif.tb_wr = 1;
                iopmp_reg_read(HWCFG1_OFFSET);
                // //vif.tb_rd = 1;

                iopmp_reg_write(HWCFG2_OFFSET);
                vif.tb_wr = 1;
                iopmp_reg_read(HWCFG2_OFFSET);

                iopmp_reg_write(ENTRY_OFFSET_OFFSET);
                vif.tb_wr = 1;
                iopmp_reg_read(ENTRY_OFFSET_OFFSET);

                iopmp_reg_write(MDCFGLCK_OFFSET);
                vif.tb_wr = 1;
                iopmp_reg_read(MDCFGLCK_OFFSET);

                iopmp_reg_write(ENTRYLCK_OFFSET);
                vif.tb_wr = 1;
                iopmp_reg_read(ENTRYLCK_OFFSET);

                iopmp_reg_write(ERR_CFG_OFFSET);
                vif.tb_wr = 1;
                iopmp_reg_read(ERR_CFG_OFFSET);

                iopmp_reg_write(ERR_REQINFO_OFFSET);
                vif.tb_wr = 1;
                iopmp_reg_read(ERR_REQINFO_OFFSET);

                for (int i = 0; i < cp_file_pkg::IOPMPMemoryDomains; i++) begin
                    iopmp_reg_write(MDCFG_OFFSET + i * 4);
                    vif.tb_wr = 1;
                    iopmp_reg_read(MDCFG_OFFSET + i * 4);
                end

                for (int i = 0; i < cp_file_pkg::NUM_MASTERS; i++) begin
                    iopmp_reg_write(SRCMD_EN_OFFSET + i * 32);
                    vif.tb_wr = 1;
                    iopmp_reg_read(SRCMD_EN_OFFSET + i * 32);
                end

                for (int i = 0; i < cp_file_pkg::IOPMPRegions; i++) begin
                    iopmp_reg_write(ENTRY_OFFSET + i * 16);
                    vif.tb_wr = 1;
                    iopmp_reg_read(ENTRY_OFFSET + i * 16);
                end

                for (int i = 0; i < cp_file_pkg::IOPMPRegions; i++) begin
                    iopmp_reg_write(ENTRY_OFFSET + i * 16 + 8);
                    vif.tb_wr = 1;
                    iopmp_reg_read(ENTRY_OFFSET + i * 16 + 8);
                end




            end

            seq_item_port.item_done();
        end
    endtask: run_phase
    


    
endclass: uvm_drv_cp
