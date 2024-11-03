//  Class: uvm_sco_rh
//
`include "uvm_macros.svh"
`include "../../src/my_macros.svh"
import uvm_pkg::*; 
class uvm_sco_rh extends uvm_component;
    `uvm_component_utils(uvm_sco_rh);

    
    //  Constructor: new
    function new(string name = "uvm_sco_rh", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    //`uvm_analysis_imp_decl(_mon0)

    uvm_analysis_imp#(uvm_transaction_rh, uvm_sco_rh) recv0;
    //bit [7:0] gen_rand_data;
 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        recv0 = new("recv0", this); 
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
    endfunction: connect_phase
    

    virtual function void write(uvm_transaction_rh tr);
        for (int j = 0; j < rh_file_pkg::IOPMPNumChan; j++) begin
            if(tr.mst_address[j] == tr.iopmp_check_addr_o[j]) begin 
                `uvm_info("SCO", $sformatf("DATA MATCHED-> mst_address[%0h]: %0h, iopmp_check_addr_o[%0h]: %0h", j, tr.mst_address[j], j, tr.iopmp_check_addr_o[j]), UVM_NONE);
            end
            else begin                 
                `uvm_error("SCO", $sformatf("DATA DISMATCHED-> mst_address[%0h]: %0h, iopmp_check_addr_o[%0h]: %0h", j, tr.mst_address[j], j, tr.iopmp_check_addr_o[j]));
            end 
            if(((tr.mst_opcode [j] == PutFullData || tr.mst_opcode [j] == PutPartialData) &&  tr.iopmp_check_access_o[j] == IOPMP_ACC_WRITE) || (tr.mst_opcode [j] == Get && tr.iopmp_check_access_o[j] == IOPMP_ACC_READ)) begin 
                `uvm_info("SCO", $sformatf("DATA MATCHED-> mst_address[%0h]: %0s, iopmp_check_addr_o[%0h]: %0s", j, tr.mst_opcode[j].name(), j, tr.iopmp_check_access_o[j].name()), UVM_NONE);
            end
            else begin                 
                `uvm_error("SCO", $sformatf("DATA DISMATCHED-> mst_address[%0h]: %0s, iopmp_check_addr_o[%0h]: %0s", j, tr.mst_opcode[j].name(), j, tr.iopmp_check_access_o[j].name()));
            end 
            if((tr.iopmp_permission_denied[j] == 1 && tr.mst_rsp_o[j].d_error == 1'b1 && tr.mst_rsp_o[j].d_sink == 8'hEE) || (tr.iopmp_permission_denied[j] == 1 && tr.mst_rsp_o[j].d_error == 1'b0 && tr.mst_rsp_o[j].d_sink == 8'hAA) || (tr.iopmp_permission_denied[j] == 0 && tr.mst_rsp_o[j].d_error == 1'b0)) begin 
                `uvm_info("SCO", $sformatf("Req handler behaviour is correct -> tr.iopmp_permission_denied[%0h] == %0h && tr.mst_rsp_o[%0h].d_error == %0h && tr.mst_rsp_o[%0h].d_sink == %0h", j, tr.iopmp_permission_denied[j], j, tr.mst_rsp_o[j].d_error, j, tr.mst_rsp_o[j].d_sink), UVM_NONE);
                `uvm_info("SCO", $sformatf("Sink ID EE is for the error response and AA is for the successful response."), UVM_NONE);
            end
            else begin                 
                `uvm_error("SCO", $sformatf("Req handler behaviour is wrong -> tr.iopmp_permission_denied[%0h] == %0h && tr.mst_rsp_o[%0h].d_error == %0h && tr.mst_rsp_o[%0h].d_sink == %0h", j, tr.iopmp_permission_denied[j], j, tr.mst_rsp_o[j].d_error, j, tr.mst_rsp_o[j].d_sink));
            end
            $display("---------------------------------------------------------------------");
            $display("---------------------------------------------------------------------");
        end
    

        $display("---------------------------------------------------------------------");
        $display("---------------------------------------------------------------------");
        $display("---------------------------------------------------------------------");
        $display("---------------------------------------------------------------------");
    endfunction





    
endclass: uvm_sco_rh
