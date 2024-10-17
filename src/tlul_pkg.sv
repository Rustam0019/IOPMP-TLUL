package tlul_pkg;

//    localparam int TL_AW=32;
//    localparam int TL_DW=32;    // = TL_DBW * 8; TL_DBW must be a power-of-two
//    localparam int TL_AIW=8;    // a_source, d_source
//    localparam int TL_DIW=1;    // d_sink
//    localparam int TL_AUW=21;   // a_user
//    localparam int TL_DUW=14;   // d_user
//    localparam int TL_DBW=(TL_DW>>3);
//    localparam int TL_SZW=$clog2($clog2(TL_DBW)+1);



    typedef enum logic [2:0] {
        PutFullData    = 3'h0,
        PutPartialData = 3'h1,
        Get            = 3'h4
    }   tl_a_op_e;
    
    typedef enum logic [2:0] {
        AccessAck     = 3'h0,
        AccessAckData = 3'h1
    }   tl_d_op_e;


    typedef struct packed {
        logic                         a_valid;
        tl_a_op_e                     a_opcode;
        logic                  [2:0]  a_param;
        logic  [top_pkg::TL_SZW-1:0]  a_size;
        logic  [top_pkg::TL_AIW-1:0]  a_source;
        logic  [top_pkg::TL_AW-1:0]   a_address;
        logic  [top_pkg::TL_DBW-1:0]  a_mask;
        logic   [top_pkg::TL_DW-1:0]  a_data;
        //tl_a_user_t                   a_user;

        logic                         d_ready;
        } tl_h2d_t;


//    localparam tl_h2d_t TL_H2D_DEFAULT = '{
//        d_ready:  1'b1,
//        a_opcode: tl_a_op_e'('0),
//        //a_user:   TL_A_USER_DEFAULT,
//        a_data:   BlankedAData,
//        default:  '0
//        };

    typedef struct packed {
        logic                         d_valid;
        tl_d_op_e                     d_opcode;
        logic                  [2:0]  d_param;
        logic  [top_pkg::TL_SZW-1:0]  d_size;   // Bouncing back a_size
        logic  [top_pkg::TL_AIW-1:0]  d_source;
        logic  [top_pkg::TL_DIW-1:0]  d_sink;
        logic   [top_pkg::TL_DW-1:0]  d_data;
       // tl_d_user_t                   d_user;
        logic                         d_error;
    
        logic                         a_ready;
    
        } tl_d2h_t;
        
endpackage