// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// This code is derived from the ibex_pmp.sv file from opentitan project and adapted to the IOPMP.
// Description: IOPMP checker asserts the iopmp_req_err_o signal when the master has no access permission to an address.

import top_pkg::*;
import tlul_pkg::*;
import config_pkg::*;
import iopmp_pkg::*;

module iopmp_cfg_i #(
    parameter int unsigned IOPMPGranularity  =   0,
    parameter int unsigned IOPMPRegions      =   0,
    parameter int unsigned IOPMPNumChan      =   2
    //parameter int unsigned IOPMPPrioRegions  =   1
) (
    input logic clk,
    input logic rst,
    input iopmp_pkg::entry_cfg                                  csr_iopmp_i_cfg  [IOPMPRegions],
    input logic [33:0]                                          csr_iopmp_addr_i [IOPMPRegions],
    input logic [7:0][IOPMPRegions-1:0]                         md_entry_indexes[IOPMPNumChan],
    //input logic [RegWidth - 1 : 0]      cfg_reg_data,

    input  logic [15:0]                 prio_entry_num,
    // Access checking channels
    input  logic [33:0]              iopmp_req_addr_i[IOPMPNumChan],
    input  iopmp_pkg::iopmp_req_e    iopmp_req_type_i[IOPMPNumChan],
    output logic                     iopmp_req_err_o[IOPMPNumChan],
    input  logic[7:0]                last_indx[IOPMPNumChan],
    output logic [7:0]               entry_violated_index[IOPMPNumChan]
);


// Access Checking Signals
logic [33:0]                                                  region_start_addr [IOPMPRegions];
logic [33:IOPMPGranularity+2]                                 region_addr_mask  [IOPMPRegions];


logic [IOPMPNumChan-1:0][IOPMPRegions-1:0]                                      region_match_gt_j;
logic [IOPMPNumChan-1:0][IOPMPRegions-1:0]                                      region_match_lt_j;
logic [IOPMPNumChan-1:0][IOPMPRegions-1:0]                                      region_match_eq_j;
logic [IOPMPNumChan-1:0][IOPMPRegions-1:0]                                      region_match_all_j;
logic [IOPMPNumChan-1:0][IOPMPRegions-1:0]                                      region_basic_perm_check_j;


// Access fault determination / prioritization
function automatic logic access_fault_check   (input iopmp_pkg::iopmp_req_e             iopmp_req_type_i_n,
                                               input logic [33:0]                       iopmp_req_addr_i_n,
                                               input logic [7:0][IOPMPRegions - 1:0]    md_entry_indexes_table,
                                               input logic [33:0]                       region_start_addr_n [IOPMPRegions],
                                               input logic [33:IOPMPGranularity+2]      region_addr_mask_n  [IOPMPRegions],
                                               input iopmp_pkg::entry_cfg               csr_iopmp_i_cfg_n  [IOPMPRegions],
                                               input logic  [33:0]                      csr_iopmp_addr_i_n [IOPMPRegions],
                                               input logic  [15:0]                      prio_entry_num,
                                               output logic [IOPMPRegions-1:0]                           region_match_gt,
                                               output logic [IOPMPRegions-1:0]                            region_match_lt,
                                               output logic [IOPMPRegions-1:0]                            region_match_eq,
                                               output logic [IOPMPRegions-1:0]                            region_match_all,
                                               output logic [IOPMPRegions-1:0]                            region_basic_perm_check,
                                               //output logic  [7:0]                      count_test_i,
                                               input  logic[7:0]                        last_index,
                                               output logic [7:0]                       entry_violated_index_o
                                               );


    //logic region_match_eq, region_match_gt, region_match_lt, region_match_all, region_basic_perm_check;
 

    logic matched     =     1'b0;
    logic access_fail =     1'b0;
    logic [7:0] r;
    logic [7:0] h;
    
    h = 0;
    r = md_entry_indexes_table[h]; 
        
    region_match_eq         = '0;
    region_match_gt         = '0;
    region_match_lt         = '0;
    region_match_all        = '0;
    region_basic_perm_check = '0;
    entry_violated_index_o  = 0;
    
    
    while(h < last_index) begin
        region_match_eq[h]  =   (iopmp_req_addr_i_n[33:IOPMPGranularity+2] &
                                      region_addr_mask_n[r]) ==
                                     (region_start_addr_n[r][33:IOPMPGranularity+2] &
                                      region_addr_mask_n[r]);
                                      
        region_match_gt[h]  =    iopmp_req_addr_i_n[33:IOPMPGranularity+2] >
                                    region_start_addr_n[r][33:IOPMPGranularity+2]; 
                                     
        region_match_lt[h]  =    iopmp_req_addr_i_n[33:IOPMPGranularity+2] <
                                    csr_iopmp_addr_i_n[r][33:IOPMPGranularity+2];                              
                                   
        //region_match_all = 1'b0;
        unique case (csr_iopmp_i_cfg[r].a)
          IOPMP_MODE_OFF:   region_match_all[h]        = 1'b0;
          IOPMP_MODE_NA4:   region_match_all[h]        = region_match_eq[h];
          IOPMP_MODE_NAPOT: region_match_all[h]        = region_match_eq[h];
          IOPMP_MODE_TOR: begin
            region_match_all[h]  = (region_match_eq[h] | region_match_gt[h]) &
                                     region_match_lt[h];
          end
          default:        region_match_all[h] = 1'b0;
        endcase
        
        region_basic_perm_check[h]  =
          ((iopmp_req_type_i_n  == IOPMP_ACC_EXEC)  & csr_iopmp_i_cfg_n[r].x) |
          ((iopmp_req_type_i_n  == IOPMP_ACC_WRITE) & csr_iopmp_i_cfg_n[r].w) |
          ((iopmp_req_type_i_n  == IOPMP_ACC_READ)  & csr_iopmp_i_cfg_n[r].r);
          
        if(region_match_all[h] && region_basic_perm_check[h]) begin 
            access_fail = 0;
            region_match_eq[h] = 1'b1;
            region_match_gt[h] = 1'b1;
            region_match_lt[h] = 1'b1;
            region_match_all[h] = 1'b1;
            region_basic_perm_check[h] = 1'b1;
            break;
        end 
        else if (region_match_all[h] && !region_basic_perm_check[h] && r < prio_entry_num) begin
            access_fail            = 1;
            entry_violated_index_o = h;
            //region_match_eq = '0;
            region_match_eq[h] = 1'b1;
            region_match_gt[h] = 1'b1;
            region_match_lt[h] = 1'b1;
            region_match_all[h] = 1'b1;
            region_basic_perm_check[h] = 1'b0;
            break;
        end
        if(h == last_index - 1) begin
            access_fail            = 1;
        end
        entry_violated_index_o = h;
        h++;
        //count_test_i = r;
        r = md_entry_indexes_table[h];
//        if( r ==  $size(md_entry_indexes[0] - 1) begin
//            access_fail = 0;
//        end         
    end
    
    return access_fail;
  endfunction



// ---------------
// Access checking
// ---------------

for (genvar r = 0; r < IOPMPRegions; r++) begin : g_addr_exp
    // Start address for TOR matching
    if (r == 0) begin : g_entry0
      assign region_start_addr[r] = (csr_iopmp_i_cfg[r].a == IOPMP_MODE_TOR) ? 34'h000000000 :
                                                                              csr_iopmp_addr_i[r];
    end else begin : g_oth
      assign region_start_addr[r] = (csr_iopmp_i_cfg[r].a == IOPMP_MODE_TOR) ? csr_iopmp_addr_i[r-1] : // problem here about .a
                                                                              csr_iopmp_addr_i[r];
    end
    // Address mask for NA matching
    for (genvar b = IOPMPGranularity + 2; b < 34; b++) begin : g_bitmask
      if (b == 2) begin : g_bit0
        // Always mask bit 2 for NAPOT
        assign region_addr_mask[r][b] = (csr_iopmp_i_cfg[r].a != IOPMP_MODE_NAPOT);
      end else begin : g_others
        // We will mask this bit if it is within the programmed granule
        // i.e. addr = yyyy 0111
        //                  ^
        //                  | This bit pos is the top of the mask, all lower bits set
        // thus mask = 1111 0000
        if (IOPMPGranularity == 0) begin : g_region_addr_mask_zero_granularity
          assign region_addr_mask[r][b] = (csr_iopmp_i_cfg[r].a != IOPMP_MODE_NAPOT) |
                                          ~&csr_iopmp_addr_i[r][b-1:2];
        end else begin : g_region_addr_mask_other_granularity
          assign region_addr_mask[r][b] = (csr_iopmp_i_cfg[r].a != IOPMP_MODE_NAPOT) |
                                          ~&csr_iopmp_addr_i[r][b-1:IOPMPGranularity+1];
        end
      end
    end
  end
  
  
  for (genvar c = 0; c < IOPMPNumChan; c++) begin : g_access_check
    //always_comb begin
        //for (integer r = 0; r < $size(md_entry_indexes[c]); r++) begin
//       if(rst) begin
//            region_match_gt_j[c] = '0;
//            region_match_lt_j[c] = '0;
//            region_match_eq_j[c] = '0;
//            region_match_all_j[c] = '0;
//            region_basic_perm_check_j[c] = '0;
//        end else begin
           assign iopmp_req_err_o[c] = access_fault_check(iopmp_req_type_i[c],
                                                    iopmp_req_addr_i[c],
                                                    md_entry_indexes[c],
                                                    region_start_addr,
                                                    region_addr_mask,
                                                    csr_iopmp_i_cfg,
                                                    csr_iopmp_addr_i,
                                                    prio_entry_num,
                                                    region_match_gt_j[c],
                                                    region_match_lt_j[c],
                                                    region_match_eq_j[c],
                                                    region_match_all_j[c],
                                                    region_basic_perm_check_j[c],
                                                    //count_test[c],
                                                    last_indx[c],
                                                    entry_violated_index[c]);
        //end
        //end
    //end
  end   
endmodule