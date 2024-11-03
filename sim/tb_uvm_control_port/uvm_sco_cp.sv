//  Class: uvm_sco_cp
//
`include "uvm_macros.svh"
`include "../../src/my_macros.svh"
import uvm_pkg::*; 
class uvm_sco_cp extends uvm_component;
    `uvm_component_utils(uvm_sco_cp);

    
    //  Constructor: new
    function new(string name = "uvm_sco_cp", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    //`uvm_analysis_imp_decl(_mon0)

    uvm_analysis_imp#(uvm_transaction_cp, uvm_sco_cp) recv0;
    //bit [7:0] gen_rand_data;
 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        recv0 = new("recv0", this); 
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
    endfunction: connect_phase
    

    virtual function void write(uvm_transaction_cp tr);
        
        logic   [config_pkg::AddrWidth -  1: 0] MDCFG_I_OFFSET;
        logic   [config_pkg::AddrWidth -  1: 0] SRCMD_EN_I_OFFSET;
        logic   [config_pkg::AddrWidth -  1: 0] ENTRY_ADDR_I_OFFSET;
        //logic   [config_pkg::AddrWidth -  1: 0] ENTRY_ADDRH_I_OFFSET;
        logic   [config_pkg::AddrWidth -  1: 0] ENTRY_CFG_I_OFFSET;
        int j;
        logic [7:0] indx;
        for(j = 0; j < cp_file_pkg::IOPMPMemoryDomains; j++) begin
            if(tr.reg_address == (MDCFG_OFFSET + j * 4)) begin 
                MDCFG_I_OFFSET = MDCFG_OFFSET + j * 4;
                indx                = j;
                break;
            end
        end

        for(j = 0; j < cp_file_pkg::NUM_MASTERS; j++) begin
            if(tr.reg_address == (SRCMD_EN_OFFSET + j * 32)) begin 
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
            if(tr.reg_address == (ENTRY_OFFSET + j * 16)) begin 
                ENTRY_ADDR_I_OFFSET = ENTRY_OFFSET + j * 16;
                indx                = j;
            end
            // else if(reg_addr == (ENTRY_OFFSET + j * 16 + 4)) begin 
            //     ENTRY_ADDRH_I_OFFSET = ENTRY_OFFSET + j * 16 + 4;
            //     indx                = j;
            // end
            else if(tr.reg_address == (ENTRY_OFFSET + j * 16 + 8)) begin 
                ENTRY_CFG_I_OFFSET = ENTRY_OFFSET + j * 16 + 8;
                indx                = j;
            end
        end
        case (tr.reg_address)
            HWCFG0_OFFSET: begin
                if({tr.ref_wr_data[31], 7'(cp_file_pkg::IOPMPMemoryDomains), {16{`HW_ZERO}}, !tr.ref_wr_data[7], {2{`HW_ZERO}}, `HW_ONE, 4'(`FULL_MODEL_M) } == tr.reg_data) begin 
                    `uvm_info("SCO", $sformatf("HWCFG0 DATA MATCHED-> ref_wr_data: %0h, reg_data: %0h", tr.ref_wr_data, tr.reg_data), UVM_NONE);
                    `uvm_info("SCO", $sformatf("note: some bits are hardwired to zero."), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("HWCFG0 DATA MISMATCHED-> ref_wr_data: %0b, reg_data: %0b", {tr.ref_wr_data[31], 7'(cp_file_pkg::IOPMPMemoryDomains), {16{`HW_ZERO}}, !tr.ref_wr_data[7], {2{`HW_ZERO}}, `HW_ONE, 4'(`FULL_MODEL_M) }, tr.reg_data));
                end 
            end
            HWCFG1_OFFSET: begin
                if({16'(cp_file_pkg::IOPMPRegions), 16'(cp_file_pkg::NUM_MASTERS)} == tr.reg_data) begin 
                    `uvm_info("SCO", $sformatf("HWCFG1 WRITE DATA MATCHED-> ref_wr_data: %0h, reg_data: %0h", tr.ref_wr_data, tr.reg_data), UVM_NONE);
                    `uvm_info("SCO", $sformatf("note: only readable, data can not be changed in the register."), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("HWCFG1 WRITE DATA MISMATCHED-> ref_wr_data: %0h, reg_data: %0h", tr.ref_wr_data, tr.reg_data));
                end 
            end
            HWCFG2_OFFSET: begin
                if(tr.ref_wr_data == tr.reg_data) begin 
                    `uvm_info("SCO", $sformatf("HWCFG2 DATA MATCHED-> ref_wr_data: %0h, reg_data: %0h", tr.ref_wr_data, tr.reg_data), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("HWCFG2 DATA MISMATCHED-> ref_wr_data: %0b, reg_data: %0b", tr.ref_wr_data, tr.reg_data));
                    if (tr.ref_wr_data > cp_file_pkg::IOPMPRegions - 1) begin
                        `uvm_info("SCO", $sformatf("The value you sent is greater than the number of Regions"), UVM_NONE);
                    end
                end 
            end
            ENTRY_OFFSET_OFFSET: begin
                if(config_pkg::ENTRY_OFFSET == tr.reg_data) begin 
                    `uvm_info("SCO", $sformatf("ENTRY_OFFSET DATA MATCHED-> ref_wr_data: %0h, reg_data: %0h", tr.ref_wr_data, tr.reg_data), UVM_NONE);
                    `uvm_info("SCO", $sformatf("note: only readable, data can not be changed in the register."), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("ENTRY_OFFSET DATA MISMATCHED-> ref_wr_data: %0b, reg_data: %0b", tr.ref_wr_data, tr.reg_data));
                end 
            end
            MDCFGLCK_OFFSET: begin
                if(tr.ref_wr_data == tr.reg_data) begin 
                    `uvm_info("SCO", $sformatf("MDCFGLCK DATA MATCHED-> ref_wr_data: %0b, reg_data: %0b", tr.ref_wr_data, tr.reg_data), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("MDCFGLCK DATA MISMATCHED-> ref_wr_data: %0h, reg_data: %0h", tr.ref_wr_data, tr.reg_data));
                end 
            end
            ENTRYLCK_OFFSET: begin
                if(tr.ref_wr_data == tr.reg_data) begin 
                    `uvm_info("SCO", $sformatf("ENTRYLCK DATA MATCHED-> ref_wr_data: %0b, reg_data: %0b", tr.ref_wr_data, tr.reg_data), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("ENTRYLCK DATA MISMATCHED-> ref_wr_data: %0b, reg_data: %0b", tr.ref_wr_data, tr.reg_data));
                end 
            end
            ERR_CFG_OFFSET: begin
                if(tr.ref_wr_data == tr.reg_data) begin 
                    `uvm_info("SCO", $sformatf("ERR_CFG DATA MATCHED-> ref_wr_data: %0b, reg_data: %0b", tr.ref_wr_data, tr.reg_data), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("ERR_CFG DATA MISMATCHED-> ref_wr_data: %0b, reg_data: %0b", tr.ref_wr_data, tr.reg_data));
                end 
            end
            ERR_REQINFO_OFFSET: begin
                if(!tr.ref_wr_data[0] == tr.reg_data[0]) begin 
                    `uvm_info("SCO", $sformatf("ERR_REQINFO DATA MATCHED (v bit cleared)-> ref_wr_data: %0b, reg_data: %0b", tr.ref_wr_data[0], tr.reg_data[0]), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("ERR_REQINFO DATA MISMATCHED-> ref_wr_data: %0b, reg_data: %0b", tr.ref_wr_data[0], tr.reg_data[0]));
                end 
            end
            ERR_REQINFO_OFFSET: begin
                if(!tr.ref_wr_data[0] == tr.reg_data[0]) begin 
                    `uvm_info("SCO", $sformatf("ERR_REQINFO DATA MATCHED (v bit cleared)-> ref_wr_data: %0b, reg_data: %0b", tr.ref_wr_data[0], tr.reg_data[0]), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("ERR_REQINFO DATA MISMATCHED-> ref_wr_data: %0b, reg_data: %0b", tr.ref_wr_data[0], tr.reg_data[0]));
                end 
            end
            MDCFG_I_OFFSET: begin
                if(tr.ref_wr_data == tr.reg_data) begin 
                    `uvm_info("SCO", $sformatf("MDCFG[%0h] DATA MATCHED-> ref_wr_data: %0h, reg_data: %0h", indx, tr.ref_wr_data, tr.reg_data), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("MDCFG[%0h] DATA MISMATCHED-> ref_wr_data: %0h, reg_data: %0h", indx, tr.ref_wr_data, tr.reg_data));
                end 
            end
            SRCMD_EN_I_OFFSET: begin
                `uvm_info("SCO", $sformatf("Printing only md part..."), UVM_NONE);

                if(tr.ref_wr_data[31:1] == tr.reg_data[31:1]) begin 
                    `uvm_info("SCO", $sformatf("SRCMD_EN[%0h] DATA MATCHED-> ref_wr_data: %0h, reg_data: %0h", indx, tr.ref_wr_data[31:1], tr.reg_data[31:1]), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("SRCMD_EN[%0h] DATA MISMATCHED-> ref_wr_data: %0h, reg_data: %0h", indx, tr.ref_wr_data[31:1], tr.reg_data[31:1]));
                end 
            end
            ENTRY_ADDR_I_OFFSET: begin
                if(tr.ref_wr_data == tr.reg_data) begin 
                    `uvm_info("SCO", $sformatf("ENTRY_ADDR[%0h] DATA MATCHED-> ref_wr_data: %0h, reg_data: %0h", indx, tr.ref_wr_data, tr.reg_data), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("ENTRY_ADDR[%0h] DATA MISMATCHED-> ref_wr_data: %0h, reg_data: %0h", indx, tr.ref_wr_data, tr.reg_data));
                end 
            end
            ENTRY_CFG_I_OFFSET: begin
                if(tr.ref_wr_data == tr.reg_data) begin 
                    `uvm_info("SCO", $sformatf("ENTRY_CFG[%0h] DATA MATCHED-> ref_wr_data: %0h, reg_data: %0h", indx, tr.ref_wr_data, tr.reg_data), UVM_NONE);
                end
                else begin                 
                    `uvm_error("SCO", $sformatf("ENTRY_CFG[%0h] DATA MISMATCHED-> ref_wr_data: %0h, reg_data: %0h", indx, tr.ref_wr_data, tr.reg_data));
                end 
            end
            
        endcase
        // if(tr.ref_wr_data == tr.reg_data) begin
        //     `uvm_info("SCO", $sformatf("WRITE DATA MATCHED-> ref_wr_data: %0h, reg_data: %0h", tr.ref_wr_data, tr.reg_data), UVM_NONE);
        //     end
                
        //     else begin                 
        //         `uvm_error("SCO", $sformatf("WRITE DATA MISMATCHED-> ref_wr_data: %0h, reg_data: %0h", tr.ref_wr_data, tr.reg_data));
        //     end

        $display("---------------------------------------------------------------------");
        $display("---------------------------------------------------------------------");
        $display("---------------------------------------------------------------------");
        $display("---------------------------------------------------------------------");
    endfunction





    
endclass: uvm_sco_cp
