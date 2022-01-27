//`default_nettype none
`include "cpu_def.vh"
module mycpu_top (
    input wire          clk,
    input wire          resetn,  //低电平复位
    input wire  [5:0]   ext_int,
    //inst_RAM
    output wire         inst_sram_en,
    output wire [3:0]   inst_sram_wen,
    output wire [31:0]  inst_sram_addr,
    output wire [31:0]  inst_sram_wdata,
    input wire  [31:0]   inst_sram_rdata,
    //data_SRAM
    output wire         data_sram_en,
    output wire [3:0]   data_sram_wen,
    output wire [31:0]  data_sram_addr,
    output wire [31:0]  data_sram_wdata,
    input wire  [31:0]  data_sram_rdata,
    //debug signal
    output wire [31:0]  debug_wb_pc,
    output wire [3:0]   debug_wb_rf_wen,
    output wire [4:0]   debug_wb_rf_wnum,
    output wire [31:0]  debug_wb_rf_wdata
);
    //-------------------------net declaration--------------------------------
    reg reset;
    always @(posedge clk) begin
        reset <= ~resetn;
    end
    wire pc_reset = ~resetn;
    //-----F stage-----
    wire [31:0] pc_o;


    wire [31:0] npc,pc8;
    //-----D stage-----
    wire bd_D_o;
    wire [31:0] instr_D_o,pc8_D_o,pc_D_o;

    wire [4:0] a1,a2,a3,alu_op,cp0_addr;
    wire [3:0] npc_op;
    wire ext_op,start,srcbm_sel,mdm_sel,regwrite,cp0_write,eret,mtc0,bd;
    wire [2:0] md_op,dmext_op,grfwdm_sel;
    wire [1:0] be_op;
    wire [`INSTR_CODE_WIDTH-1:0] instr_code;

    wire [2:0] rd1mfd_sel,rd2mfd_sel,rd1mfe_sel,rd2mfe_sel;
    wire rd2mfm_sel;

    wire [1:0] tnew;
    wire stall;

    wire [31:0] rdata1,rdata2;

    wire [31:0] rd1mfd_o;

    wire [31:0] rd2mfd_o;

    wire equal;

    wire [31:0] ext_out;
    //------E stage--------
    wire [4:0] alu_op_E_o,a1_E_o,a2_E_o,a3_E_o,cp0_addr_E_o,shamt_E_o;
    wire [2:0] md_op_E_o,dmext_op_E_o,grfwdm_sel_E_o;
    wire start_E_o,srcbm_sel_E_o,mdm_sel_E_o,regwrite_E_o,cp0_write_E_o,eret_E_o,mtc0_E_o,bd_E_o;
    wire [1:0] be_op_E_o,tnew_E_o;
    wire [`INSTR_CODE_WIDTH-1:0] instr_code_E_o;
    wire [31:0] pc8_E_o,pc_E_o,rd1_E_o,rd2_E_o,ext32_E_o;

    wire [31:0] rd1mfe_o;

    wire [31:0] rd2mfe_o;

    wire [31:0] srcbm_o;

    wire [31:0] alu_result;
    wire overflow;

    wire busy;
    wire [31:0] hi,lo;

    wire [31:0] mdm_o;
    //--------M stage----------
    wire [1:0] be_op_M_o,tnew_M_o;
    wire [2:0] dmext_op_M_o,grfwdm_sel_M_o;
    wire regwrite_M_o,cp0_write_M_o,eret_M_o,mtc0_M_o,bd_M_o;
    wire [4:0] a1_M_o,a2_M_o,a3_M_o,cp0_addr_M_o;
    wire [31:0] pc8_M_o,pc_M_o,rd2_M_o,alu_result_M_o,md_result_M_o;

    wire [31:0] rd2mfm_o;

    wire [3:0] m_data_byteen;
    wire [31:0] m_data_addr,m_data_wdata;

    wire [31:0] p_data_rdata,m_data_rdata;

    wire [4:0] ExcCode;
    wire clr_instr;
    wire has_ext_E;

    wire req;
    wire [31:0] epc,cp0rdata;

    wire [2:0] grfwdm_sel_W_o;
    wire regwrite_W_o;
    wire [4:0] a1_W_o,a2_W_o,a3_W_o;
    wire [31:0] pc8_W_o,pc_W_o,alu_result_W_o,md_result_W_o,m_data_rdata_W_o,cp0_out_W_o;
    
     wire [31:0] grfwdm_o;


    //link
    assign inst_sram_en     = ~stall|req;   //暂停时inst_sram保持读出值不变,注意发生异常时应当将使能置为1
    assign inst_sram_wen    = 4'b0;
    assign inst_sram_addr   = npc;
    assign inst_sram_wdata  = 32'b0;

    assign data_sram_en     = 1'b1;
    assign data_sram_wen    = m_data_byteen;
    assign data_sram_addr   = {3'b0,m_data_addr[28:0]}; //固定地址转换
    assign data_sram_wdata  = m_data_wdata;
    assign p_data_rdata     = data_sram_rdata;

    assign debug_wb_pc          = pc_W_o;
    assign debug_wb_rf_wen      = {4{regwrite_W_o}};
    assign debug_wb_rf_wnum     = a3_W_o;
    assign debug_wb_rf_wdata    = grfwdm_o;


    //---------------------------pipline-----------------------------
    //-------------F stage---------------

    
    pc pc_ (
        .clk    (clk            ), 
        .reset  (pc_reset       ), 
        .stall  (stall          ),
        .req    (req            ), 
        .pc_i   (npc            ), 
        .pc_o   (pc_o           )
    ); 

    
    npc npc_ (
        .pc     (pc_o               ), 
        .imm26  (instr_D_o[25:0]    ), 
        .rs_reg (rd1mfd_o           ), 
        .npc_op (npc_op             ), 
        .equal  (equal              ), 
        .int_req(req                ), 
        .eret   (eret               ),
        .epc    (epc                ),
        .npc    (npc                ), 
        .pc8    (pc8                )
    );



    //---------------D stage------------------------

    wire [31:0] pc_D_i = eret ? npc : pc_o;
    
    D_reg D_reg_ (
        .clk        (clk        ), 
        .reset      (reset      ), 
        .req        (req        ), 
        .stall      (stall      ), 
        .eret       (eret       ),
        .bd_D_i     (bd         ), 
        .bd_D_o     (bd_D_o     ), 
        .instr_D_i  (inst_sram_rdata), 
        .instr_D_o  (instr_D_o  ), 
        .pc8_D_i    (pc8        ), 
        .pc8_D_o    (pc8_D_o    ), 
        .pc_D_i     (pc_D_i     ), 
        .pc_D_o     (pc_D_o     )
    );

    
    main_controller main_controller_ (
        .instr_i    (instr_D_o  ), 
        .clr_instr  (clr_instr  ), 
        .a1         (a1         ), 
        .a2         (a2         ), 
        .a3         (a3         ), 
        .npc_op     (npc_op     ),  //4 
        .ext_op     (ext_op     ),  //1
        .alu_op     (alu_op     ),  //5
        .md_op      (md_op      ),  //3
        .start      (start      ),  //1
        .srcbm_sel  (srcbm_sel  ),  //1
        .mdm_sel    (mdm_sel    ),  //1
        .be_op      (be_op      ),  //2
        .dmext_op   (dmext_op   ),  //3
        .regwrite   (regwrite   ),  //1
        .grfwdm_sel (grfwdm_sel ),  //3
        .instr_code (instr_code ),  //INSTR_CODE_WIDTH
        .cp0_write  (cp0_write  ),  //1
        .cp0_addr   (cp0_addr   ),  //5 
        .eret       (eret       ),  //1
        .mtc0       (mtc0       ),  //1 
        .bd         (bd         )   //1
    );


    

    forward_controller forward_controller_ (
        .a1             (a1             ), 
        .a1_E           (a1_E_o         ), 
        .a2             (a2             ), 
        .a2_E           (a2_E_o       ), 
        .a2_M           (a2_M_o       ), 
        .a3_E           (a3_E_o       ), 
        .a3_M           (a3_M_o       ), 
        .a3_W           (a3_W_o       ), 
        .tnew_E         (tnew_E_o     ), 
        .tnew_M         (tnew_M_o     ), 
        .regwrite_E     (regwrite_E_o ), 
        .regwrite_M     (regwrite_M_o ), 
        .regwrite_W     (regwrite_W_o ), 
        .grfwdm_sel_M   (grfwdm_sel_M_o), 
        .rd1mfd_sel     (rd1mfd_sel ),  //3
        .rd2mfd_sel     (rd2mfd_sel ),  //3
        .rd1mfe_sel     (rd1mfe_sel ),  //3
        .rd2mfe_sel     (rd2mfe_sel ),  //3
        .rd2mfm_sel     (rd2mfm_sel )   //1
    );


    
    stall_controller stall_controller_ (
        .instr_code     (instr_code       ), 
        .tnew           (tnew             ),  //2
        .tnew_E         (tnew_E_o         ), 
        .tnew_M         (tnew_M_o         ), 
        .a1             (a1               ), 
        .a2             (a2               ), 
        .a3_E           (a3_E_o           ), 
        .a3_M           (a3_M_o           ), 
        .regwrite_E     (regwrite_E_o     ), 
        .regwrite_M     (regwrite_M_o     ), 
        .busy           (busy             ), 
        .start_E        (start_E_o        ), 
        .mtc0_E         (mtc0_E_o         ), 
        .mtc0_M         (mtc0_M_o         ), 
        .cp0_addr_E     (cp0_addr_E_o     ), 
        .cp0_addr_M     (cp0_addr_M_o     ), 
        .stall          (stall            )
    );

    
    grf grf_ (
        .reset      (reset      ), 
        .clk        (clk        ), 
        .en         (regwrite_W_o), 
        .raddr1     (a1         ), 
        .raddr2     (a2         ), 
        .waddr      (a3_W_o     ), 
        .wdata      (grfwdm_o   ), 
        .rdata1     (rdata1     ), 
        .rdata2     (rdata2     )
    );

    
    MUX8 rd1mfd_ (
        .sel    (rd1mfd_sel     ), 
        .in0    (rdata1         ), 
        .in1    (alu_result_M_o ), 
        .in2    (md_result_M_o  ), 
        .in3    (pc8_M_o        ), 
        .in4    (pc8_E_o        ), 
        .in5(), 
        .in6(), 
        .in7(), 
        .out    (rd1mfd_o       )
    );

    
    MUX8 rd2mfd_ (
        .sel    (rd2mfd_sel     ), 
        .in0    (rdata2         ), 
        .in1    (alu_result_M_o ), 
        .in2    (md_result_M_o  ), 
        .in3    (pc8_M_o        ), 
        .in4    (pc8_E_o        ), 
        .in5(), 
        .in6(), 
        .in7(), 
        .out    (rd2mfd_o       )
    );

    
    cmp cmp_ (
        .data1  (rd1mfd_o   ), 
        .data2  (rd2mfd_o   ), 
        .equal  (equal      )
    );

    
    ext ext_ (
        .ext_op (ext_op         ), 
        .ext_in (instr_D_o[15:0]), 
        .ext_out(ext_out        )
    ); 


    //-------------------E stage---------------------
    
    E_reg E_reg_ (
        .clk            (clk            ), 
        .reset          (reset          ), 
        .req            (req            ), 
        .stall          (stall          ), 
        .alu_op_E_i     (alu_op         ), 
        .alu_op_E_o     (alu_op_E_o     ), 
        .md_op_E_i      (md_op          ), 
        .md_op_E_o      (md_op_E_o      ), 
        .start_E_i      (start          ), 
        .start_E_o      (start_E_o      ), 
        .srcbm_sel_E_i  (srcbm_sel      ), 
        .srcbm_sel_E_o  (srcbm_sel_E_o  ), 
        .mdm_sel_E_i    (mdm_sel        ), 
        .mdm_sel_E_o    (mdm_sel_E_o    ), 
        .be_op_E_i      (be_op          ), 
        .be_op_E_o      (be_op_E_o      ), 
        .dmext_op_E_i   (dmext_op       ), 
        .dmext_op_E_o   (dmext_op_E_o   ), 
        .grfwdm_sel_E_i (grfwdm_sel     ), 
        .grfwdm_sel_E_o (grfwdm_sel_E_o ), 
        .regwrite_E_i   (regwrite       ), 
        .regwrite_E_o   (regwrite_E_o   ), 
        .a1_E_i         (a1             ), 
        .a1_E_o         (a1_E_o         ), 
        .a2_E_i         (a2             ), 
        .a2_E_o         (a2_E_o         ), 
        .a3_E_i         (a3             ), 
        .a3_E_o         (a3_E_o         ), 
        .tnew_E_i       (tnew           ), 
        .tnew_E_o       (tnew_E_o       ), 
        .instr_code_E_i (instr_code     ), 
        .instr_code_E_o (instr_code_E_o ), 
        .cp0_write_E_i  (cp0_write      ), 
        .cp0_write_E_o  (cp0_write_E_o  ), 
        .cp0_addr_E_i   (cp0_addr       ), 
        .cp0_addr_E_o   (cp0_addr_E_o   ), 
        .eret_E_i       (eret           ), 
        .eret_E_o       (eret_E_o       ), 
        .mtc0_E_i       (mtc0           ), 
        .mtc0_E_o       (mtc0_E_o       ), 
        .bd_E_i         (bd_D_o         ), 
        .bd_E_o         (bd_E_o         ), 
        .pc8_E_i        (pc8_D_o        ), 
        .pc8_E_o        (pc8_E_o        ), 
        .pc_E_i         (pc_D_o         ), 
        .pc_E_o         (pc_E_o         ), 
        .rd1_E_i        (rd1mfd_o       ), 
        .rd1_E_o        (rd1_E_o        ), 
        .rd2_E_i        (rd2mfd_o       ), 
        .rd2_E_o        (rd2_E_o        ), 
        .ext32_E_i      (ext_out        ), 
        .ext32_E_o      (ext32_E_o      ), 
        .shamt_E_i      (instr_D_o[10:6]), 
        .shamt_E_o      (shamt_E_o      )
    );

    
    MUX8 rd1mfe_ (
        .sel(rd1mfe_sel      ), 
        .in0(rd1_E_o        ), 
        .in1(grfwdm_o       ), 
        .in2(alu_result_M_o ), 
        .in3(md_result_M_o  ), 
        .in4(pc8_M_o        ), 
        .in5(), 
        .in6(), 
        .in7(), 
        .out(rd1mfe_o       )
    );

    
    MUX8 rd2mfe_ (
    .sel(rd2mfe_sel     ), 
    .in0(rd2_E_o        ), 
    .in1(grfwdm_o       ), 
    .in2(alu_result_M_o ), 
    .in3(md_result_M_o  ), 
    .in4(pc8_M_o        ), 
    .in5(), 
    .in6(), 
    .in7(), 
    .out(rd2mfe_o       )
    );

    
    MUX2 srcbm_ (
    .sel(srcbm_sel_E_o  ), 
    .in0(rd2mfe_o       ), 
    .in1(ext32_E_o      ), 
    .out(srcbm_o        )
    );


    
    alu alu_ (
        .srca       (rd1mfe_o       ), 
        .srcb       (srcbm_o        ), 
        .shamt      (shamt_E_o      ), 
        .alu_op     (alu_op_E_o     ), 
        .alu_result (alu_result     ), 
        .overflow   (overflow       )
    );


    
    md md_ (
    .clk        (clk        ), 
    .reset      (reset      ), 
    .start      (start_E_o  ), 
    .md_op      (md_op_E_o  ), 
    .srca       (rd1mfe_o   ), 
    .srcb       (srcbm_o    ), 
    .int_req    (req|has_ext_E),
    .busy       (busy       ), 
    .hi         (hi         ), 
    .lo         (lo         )
    );

    
    MUX2 mdm_ (
    .sel(mdm_sel_E_o    ), 
    .in0(hi             ), 
    .in1(lo             ), 
    .out(mdm_o          )
    );

    be be_ (
    .be_op          (be_op_E_o      ), 
    .p_data_addr    (alu_result     ), 
    .p_data_wdata   (rd2mfe_o       ), 
    .int_req        (req|has_ext_E  ),
    .m_data_byteen  (m_data_byteen  ), 
    .m_data_addr    (m_data_addr    ), 
    .m_data_wdata   (m_data_wdata   )
    );


    //------------------M stage----------------------
    
    M_reg M_reg_ (
    .clk            (clk            ), 
    .reset          (reset          ), 
    .req            (req            ), 
    .stall          (stall          ), 
    .dmext_op_M_i   (dmext_op_E_o   ), 
    .dmext_op_M_o   (dmext_op_M_o   ), 
    .grfwdm_sel_M_i (grfwdm_sel_E_o ), 
    .grfwdm_sel_M_o (grfwdm_sel_M_o ), 
    .regwrite_M_i   (regwrite_E_o   ), 
    .regwrite_M_o   (regwrite_M_o   ), 
    .a1_M_i         (a1_E_o         ), 
    .a1_M_o         (a1_M_o         ), 
    .a2_M_i         (a2_E_o         ), 
    .a2_M_o         (a2_M_o         ), 
    .a3_M_i         (a3_E_o         ), 
    .a3_M_o         (a3_M_o         ), 
    .tnew_M_i       (tnew_E_o       ), 
    .tnew_M_o       (tnew_M_o       ), 
    .cp0_write_M_i  (cp0_write_E_o  ), 
    .cp0_write_M_o  (cp0_write_M_o  ), 
    .cp0_addr_M_i   (cp0_addr_E_o   ), 
    .cp0_addr_M_o   (cp0_addr_M_o   ), 
    .eret_M_i       (eret_E_o       ), 
    .eret_M_o       (eret_M_o       ), 
    .mtc0_M_i       (mtc0_E_o       ), 
    .mtc0_M_o       (mtc0_M_o       ), 
    .bd_M_i         (bd_E_o         ), 
    .bd_M_o         (bd_M_o         ), 
    .pc8_M_i        (pc8_E_o        ), 
    .pc8_M_o        (pc8_M_o        ), 
    .pc_M_i         (pc_E_o         ), 
    .pc_M_o         (pc_M_o         ), 
    .rd2_M_i        (rd2mfe_o       ), 
    .rd2_M_o        (rd2_M_o        ), 
    .alu_result_M_i (alu_result     ), 
    .alu_result_M_o (alu_result_M_o ), 
    .md_result_M_i  (mdm_o          ), 
    .md_result_M_o  (md_result_M_o  )
    );

    
    MUX2 rd2mfm_ (
        .sel(rd2mfm_sel ), 
        .in0(rd2_M_o    ), 
        .in1(grfwdm_o   ), 
        .out(rd2mfm_o   )
    );

    
    dmext dmext_ (
    .dmext_op       (dmext_op_M_o   ), 
    .m_data_addr    (alu_result_M_o ), 
    .p_data_rdata   (p_data_rdata   ), 
    .m_data_rdata   (m_data_rdata   )
    );

    
    ep ep_ (
    .clk            (clk            ), 
    .reset          (reset          ), 
    .stall          (stall          ), 
    .req            (req            ), 
    .eret           (eret           ),
    .pc_F           (pc_o           ), 
    .instr_code_D   (instr_code     ), 
    .instr_code_E   (instr_code_E_o ), 
    .alu_result_E   (alu_result     ), 
    .overflow_E     (overflow       ), 
    .ExcCode        (ExcCode        ), 
    .ClrInstr       (clr_instr      ),
    .has_ext_E      (has_ext_E      )
    );

    
    cp0 cp0_ (
    .clk            (clk            ), 
    .reset          (reset          ), 
    .en             (cp0_write_M_o  ), 
    .addr           (cp0_addr_M_o   ), 
    .wdata          (rd2mfm_o       ), 
    .pc_M           (pc_M_o         ), 
    .alu_result_M   (alu_result_M_o ), 
    .ExcCode        (ExcCode        ), 
    .HWInt          (ext_int        ), 
    .EXLClr         (eret_M_o       ), 
    .bd             (bd_M_o         ), 
    .req            (req            ), 
    .epc            (epc            ), 
    .rdata          (cp0rdata       )
    );


    //----------------------W stage-----------------------
    W_reg W_reg_ (
    .clk            (clk            ), 
    .reset          (reset          ), 
    .req            (req            ), 
    .stall          (stall          ), 
    .grfwdm_sel_W_i (grfwdm_sel_M_o ), 
    .grfwdm_sel_W_o (grfwdm_sel_W_o ), 
    .regwrite_W_i   (regwrite_M_o   ), 
    .regwrite_W_o   (regwrite_W_o   ), 
    .a1_W_i         (a1_M_o         ), 
    .a1_W_o         (a1_W_o         ), 
    .a2_W_i         (a2_M_o         ), 
    .a2_W_o         (a2_W_o         ), 
    .a3_W_i         (a3_M_o         ), 
    .a3_W_o         (a3_W_o         ), 
    .pc8_W_i        (pc8_M_o        ), 
    .pc8_W_o        (pc8_W_o        ), 
    .pc_W_i         (pc_M_o         ), 
    .pc_W_o         (pc_W_o         ), 
    .alu_result_W_i (alu_result_M_o ), 
    .alu_result_W_o (alu_result_W_o ), 
    .md_result_W_i  (md_result_M_o  ), 
    .md_result_W_o  (md_result_W_o  ), 
    .m_data_rdata_W_i(m_data_rdata  ), 
    .m_data_rdata_W_o(m_data_rdata_W_o), 
    .cp0_out_W_i        (cp0rdata   ), 
    .cp0_out_W_o        (cp0_out_W_o)
    );

   
    MUX8 grfwdm_ (
    .sel(grfwdm_sel_W_o), 
    .in0(alu_result_W_o), 
    .in1(md_result_W_o), 
    .in2(m_data_rdata_W_o), 
    .in3(pc8_W_o), 
    .in4(cp0_out_W_o), 
    .in5(), 
    .in6(), 
    .in7(), 
    .out(grfwdm_o)
    );


    
    
endmodule