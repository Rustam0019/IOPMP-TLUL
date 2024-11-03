`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2024 11:30:09 AM
// Design Name: 
// Module Name: iopmp_pkg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: IOPMP registers.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import config_pkg::*;

package iopmp_pkg;

   
   // iopmp structures
   
   // INFO Registers
   typedef enum logic [3:0] {
      FULL_MODEL         = 4'h0,
      RAPID_K            = 4'h1,
      DYNAMIC_K          = 4'h2,
      ISOLATION          = 4'h3,
      COMPACT_K          = 4'h4
    } model_name;
    
    
   typedef struct packed{
        logic [31:24] specver; // the specification version
        logic [23:0]  vendor;  // the vendor ID
   } version;
   
   typedef struct packed{
     logic [31:0] impid;  // the implementation ID;
   } implementation;
   
   typedef struct packed{
     logic [31:31]                      enable;                 // Indicate if the IOPMP checks transactions by default. If it is implemented, it should be initial to 0 and sticky to 1. If it is not implemented, it should be wired to 1.
     logic [30:24]                      md_num;                 // Indicate the supported number of MD in the instance
     logic [23:16]                      rsv;                    // problem here
     logic [16:16]                      mfr_en;                 // problem Indicate if the IOPMP implements Multi Faults Record Extension, that is ERR_MFR and ERR_REQINFO.svc. 
     logic [15:15]                      pees;                   // Indicate if the IOPMP implements the error suppression per entry, including fields esre, eswe, and esxe in ENTRY_CFG(i). 
     logic [14:14]                      peis;                   // Indicate if the IOPMP implements interrupt suppression per entry, including fields sire, siwe, and sixe in ENTRY_CFG(i).
     logic [13:13]                      stall_en;               // Indicate if the IOPMP implements stall-related features, which are MDSTALL, MDSTALLH, and RRIDSCP registers. 
     logic [12:12]                      no_w;                   // Indicate if the IOPMP always fails write accesses considered as as no rule matched.
     logic [11:11]                      no_x;                   // For chk_x=1, the IOPMP with no_x=1 always fails on an instruction fetch; otherwise, it should depend on x-bit in ENTRY_CFG(i). For chk_x=0, no_x has no effect.
     logic [10:10]                      chk_x;                  // Indicate if the IOPMP implements the check of an instruction fetch. On chk_x=0, all fields of illegal instruction fetchs are ignored, including HWCFG0.no_x, ERR_CFG.ixe, ERR_CFG.rxe, ENTRY_CFG(i).sixe, ENTRY_CFG(i).esxe, and ENTRY_CFG(i).x. It should be wired to zero if there is no indication for an instruction fetch.
     logic [9:9]                        rrid_transl_prog;       // A write-1-set bit is sticky to 0 and indicate if the field sid_transl is programmable. Support only for rrid_transl_en=1, otherwise, wired to 0.
     logic [8:8]                        rrid_transl_en;         // Indicate the if tagging a new RRID on the initiator port is supported
     logic [7:7]                        prient_prog;            // A write-1-clear bit is sticky to 0 and indicates if HWCFG2.prio_entry is programmable. Reset to 1 if the implementation supports programmable prio_entry, otherwise, wired to 0.
     logic [6:6]                        user_cfg_en;            // Indicate if user customized attributes is supported; which are ENTRY_USER_CFG(i) registers.
     logic [5:5]                        sps_en;                 // Indicate secondary permission settings is supported; which are SRCMD_R/RH(i) and SRCMD_W/WH registers.     
     logic [4:4]                        tor_en;                 // Indicate if TOR is supported
     model_name                         model;                  // Indicate the iopmp instance model
   } hwcfg0;
   
   typedef struct packed {
     logic [31:16] entry_num;   // Indicate the supported number of entries in the instance
     logic [15:0]  rrid_num;    // Indicate the supported number of RRID in the instance
   } hwcfg1;
   
   typedef struct packed{
     logic [31:16] rrid_transl; // The RRID tagged to outgoing transactions. Support only for HWCFG0.rrid_transl_en=1.
     logic [15:0]  prio_entry;  // Indicate the number of entries matched with priority. These rules should be placed in the lowest order. Within these rules, the lower order has a higher priority.
   } hwcfg2;
   
   typedef struct packed{
     logic [31:0] offset;       // Indicate the offset address of the IOPMP array from the base of an IOPMP instance, a.k.a. the address of VERSION. Note: the offset is a signed number. That is, the IOPMP array can be placed in front of VERSION.
   } entryoffset;
   
   typedef struct packed{
     version                VERSION;
     implementation         IMPLEMENTATION;
     hwcfg0                 HWCFG0;
     hwcfg1                 HWCFG1;
     hwcfg2                 HWCFG2;
     entryoffset            ENTRYOFFSET;
   } INFO;
   
   
   // Configuration Protection Registers
   typedef struct packed{
     logic [31:1] md;       // md[j] is stickly to 1 and indicates if SRCMD_EN(i).md[j], SRCMD_R(i).md[j] and SRCMD_W(i).md[j] are locked for all i.
     logic l;               // Lock bit to MDLCK and MDLCKH register.
   } mdlck;
   
   typedef struct packed{
     logic [31:0] mdh;       // mdh[j] is stickly to 1 and indicates if SRCMD_ENH(i).mdh[j], SRCMD_RH(i).mdh[j] and SRCMD_WH(i).mdh[j] are locked for all i.
   } mdlckh;
   
  typedef struct packed{
     logic [31:8] rsv;      // reserved
     logic [7:1]  f;        // Indicate the number of locked MDCFG entries - MDCFG(i) is locked for i < f. For Rapid-k model, Dynamic-k model and Compact-k model, f is ignored. For the rest of the models, the field should be monotonically increased only until the next reset cycle.
     logic l;               // Lock bit to MDCFGLCK register. For Rapid-k model and Compact-k model, l should be 1. For Dynamic-K model, l indicates if MDCFG(0).t is still programmable or locked.
   } mdcfglck;
   
   typedef struct packed{
     logic [31:17] rsv;      // reserved
     logic [16:1]  f;        // Indicate the number of locked IOPMP entries - ENTRY_ADDR(i), ENTRY_ADDRH(i), ENTRY_CFG(i), and ENTRY_USER_CFG(i) are locked for i < f. The field should be monotonically increased only until the next reset cycle.
     logic l;                // Lock bit to ENTRYLCK register.
   } entrylck;
   
   
   typedef struct packed{
     entrylck                ENTRYLCK;
     mdcfglck                MDCFGLCK;
     mdlckh                  MDLCKH;
     mdlck                   MDLCK; 
   } configuration_protection_t;
   
   // Error Capture Registers
   typedef enum logic [1:0] {
      rsv                       = 2'b00,
      read_access               = 2'b01,
      write_access              = 2'b10,
      instruction_fetch         = 2'b11
    } transaction_type;
    
    typedef enum logic [2:0] {
      no_error                          = 3'b000,
      illegal_read_access               = 3'b001,
      illegal_write_access              = 3'b010,
      illegal_instruction_fetch         = 3'b011,
      partial_hit_priority_rule         = 3'b100,
      not_hit                           = 3'b101,
      unknown_RRID                      = 3'b110,
      user_defined_error                = 3'b111
    } error_type;
   
   
   
   typedef struct packed{
     logic [31:8] rsv;       // Must be zero on write, reserved for future
     logic [7:7]  rxe;       // Response on an illegal instruction fetch
     logic [6:6]  rwe;       // Response on an illegal write access:
     logic [5:5]  rre;       // Response on an illegal read accesses
     logic [4:4]  ixe;       // To trigger an interrupt on an illegal instruction fetch. Implemented only for HWCFG0.chk_x=1.
     logic [3:3]  iwe;       // To trigger an interrupt on an illegal write access
     logic [2:2]  ire;       // To trigger an interrupt on an illegal read access
     logic [1:1]  ie;        // Enable the interrupt of the IOPMP
     logic [0:0]  l;         // Lock fields to ERR_CFG register
   } err_cfg;
   
   typedef struct packed{
     logic [30:8]      rsv2;       // why 30?
     logic [7:7]       svc;        // Indicate there is a subsequent violation caught in ERR_MFR. Implemented only for HWCFG0.mfr_en=1, otherwise, ZERO.
     error_type        etype;      // Indicated the type of violation // should be enum?
     logic [3:3]       rsv1;       // 
     transaction_type  ttype;      // Indicated the transaction type
     logic [0:0]       v;          // Write 1 clears the bit, the illegal recorder reactivates and the interrupt (if enabled). Write 0 causes no effect on the bit.
     // problem?????
   } err_reqinfo;
   
   typedef struct packed{
     logic [31:0] addr; // Indicate the errored address[33:2]
   } err_reqaddr;
   
   typedef struct packed{
     logic [31:0] addrh; // Indicate the errored address[65:34]
   } err_reqaddrh;
   
   typedef struct packed{
     logic [31:16] eid; // Indicates the index pointing to the entry that catches the violation. If no entry is hit, i.e., etype=0x05, the value of this field is invalid. If the field is not implemented, it should be wired to 0xffff.
     logic [15:0] rrid; // Indicate the errored RRID.
   } err_reqid;
   
   typedef struct packed{
     logic [31:31] svs;     // the status of this window’s content
     logic [30:28] rsv;     // Must be zero on write, reserved for future
     logic [27:16] svi;     // Window’s index to search subsequent violations. When read, svi moves forward until one subsequent violation is found or svi has been rounded back to the same value. After read, the window’s content, svw, should be clean.
     logic [15:0]  svw;     // Subsequent violations in the window indexed by svi. svw[j]=1 for the at lease one subsequent violation issued from RRID= svi*16 + j.
   } err_mfr;
   
//   typedef struct packed{
//     logic [31:0][N-1:0] user;   // (Optional) user-defined registers
//   } err_user;
   
   typedef struct packed{
     //err_user       ERR_USER;
     //err_mfr        ERR_MFR;
     err_reqid      ERR_REQID;
     err_reqaddrh   ERR_REQADDRH;
     err_reqaddr    ERR_REQADDR;  // ??
     err_reqinfo    ERR_REQINFO;
     err_cfg        ERR_CFG;
     struct packed{
        logic v_we;
        logic ttype_we;
        logic etype_we;
        logic reqaddr_we;
        logic reqaddrh_we;
        logic rrid_we;
        logic eid_we; 
     } error_wr_en;
   } error_registers_t;
   
   typedef struct packed{
     err_reqid                          ERR_REQID;
     err_reqaddrh                       ERR_REQADDRH;
     err_reqaddr                        ERR_REQADDR; 
     transaction_type                   ttype;
     error_type                         etype;
     logic                              iopmp_fail;
   } error_report_t;
   
   
   // MDCFG Register
   typedef struct packed {
        logic [31:16] rsv;
        logic [15:0] t;
   } mdcfg;
   
   // SRCMD_EN Register
   typedef struct packed {
        logic [31:1] md;
        logic [0:0] l;
   } srcmd_en;
   
   typedef struct packed {
        logic [31:0] mdh;
   } srcmd_enh;
   
   // ENTRY Register
   typedef enum logic [1:0] {
      IOPMP_MODE_OFF   = 2'b00,  // Null region (disabled)
      IOPMP_MODE_TOR   = 2'b01,  // Top of range
      IOPMP_MODE_NA4   = 2'b10,  // Naturally aligned four-byte region
      IOPMP_MODE_NAPOT = 2'b11   // Naturally aligned power-of-two region, ≥8 bytes
    } iopmp_cfg_mode_addr;

    typedef enum logic [1:0] {
      IOPMP_ACC_EXEC    = 2'b00,
      IOPMP_ACC_WRITE   = 2'b01,
      IOPMP_ACC_READ    = 2'b10,
      IOPMP_NO_REQ      = 2'b11
    } iopmp_req_e;
    
    typedef enum logic [1:0] {
      Ack       = 2'b00,
      AckData   = 2'b01,
      NoOp      = 2'b10
    } slv_opcode_type;
    
    typedef struct packed {
        logic [31:11] rsv;           // reserved, must be ZERO
        logic sexe;                 // Supress the (bus) error on an illegal instruction fetch caught by the entry
        logic sewe;                 // Supress the (bus) error on an illegal write access caught by the entry
        logic sere;                 // Supress the (bus) error on an illegal read access caught by the entry
        logic sixe;                 // Suppress interrupt on an illegal instruction fetch caught by the entry
        logic siwe;                 // Suppress interrupt for write violations caught by the entry
        logic sire;                 // To suppress interrupt for an illegal read access caught by the entry
        iopmp_cfg_mode_addr a;      // The address mode of the IOPMP entry
        logic x;                    // The instruction fetch permission to the protected memory region
        logic w;                    // The write permission to the protected memory region
        logic r;                    // The read permission to protected memory region
    } entry_cfg;
    
    typedef struct packed {
        logic [31:0] addr;
    } entry_addr;

endpackage