`timescale 1ns/1ps
`default_nettype none
module cpu(
    input wire clk,
    input wire reset,
    input wire [5:0] HWInt,                   //外部中断信号
    input wire[31:0] i_inst_rdata,          //i_inst_addr 对应的 32 位指令
    input wire[31:0] m_data_rdata,          //m_data_addr 对应的 32 位数据
    output wire[31:0] i_inst_addr,          //需要进行取指操作的流水级 PC（一般为 F 级）
    output wire[31:0] m_data_addr,          //数据存储器待写入地址
    output wire[31:0] m_data_wdata,         //数据存储器待写入数据
    output wire[3:0] m_data_byteen,         //字节使能信号
    output wire[31:0] m_inst_addr,          //M 级 PC
    output wire w_grf_we,                   //grf 写使能信号
    output wire[4:0] w_grf_addr,            // grf 中待写入寄存器编号
    output wire[31:0] w_grf_wdata,          //grf中待写入数据
    output wire[31:0] w_inst_addr,           //W 级 PC
    output wire Req                         //当前是否响应中断
    );

    //F-----------------
    wire [31:0] NPC,PC8;
    //D--------------------
    wire [31:0] Instr_D_O,PC8_D_O,PC_D_O,RD1,RD2,EXTOut,RD1MFD_O,RD2MFD_O,PCM_O,PC_O;
    wire [3:0] NPCOp;
    wire EXTOp,Start,SRCBM_Sel,MDM_Sel,Stall,RD2MFM_Sel,Equal,RegWrite,PCM_Sel;
    wire [4:0] ALUOp,A3_Out,A1,A2;
    wire [2:0] MDOp,DMEXTOp,GRFWDM_Sel,RD1MFD_Sel,RD2MFD_Sel,RD1MFE_Sel,RD2MFE_Sel;
    wire [1:0] BEOp;
    wire [63:0] InstrCode_D,InstrCode_E;
    wire CP0Write,EXLClr,BD,BD_D_O,BD_E_O,BD_M_O;
    wire [4:0] CP0A;
    //E---------------------
    wire [31:0] RD1_E_O,RD2_E_O,EXT32_E_O,PC8_E_O,PC_E_O,RD1MFE_O,RD2MFE_O,SRCBM_O,AO,HI,LO,MDM_O;
    wire [4:0] Shamt_E_O;
    wire Busy,OverFlow;
    //M-------------------------
    wire [31:0] AO_M_O,MD_M_O,RD2_M_O,PC8_M_O,PC_M_O,MemO,GRFWDM_O,RD2MFM_O;
    wire [4:0] ExcCode;
    wire ClrInstr;
    wire [31:0] EPC,DOut;
    //W--------------------------
    wire [31:0] MemO_W_O,AO_W_O,MD_W_O,PC8_W_O,PC_W_O,CP0_W_O;
    //F级-----------------------------------

    PC PC_ (
    .clk(clk), 
    .reset(reset), 
    .en((~Stall)|Req), 
    .PC_I(NPC), 
    .PC_O(PC_O)
    );

    defparam PCM.WIDTH_DATA = 32;
    MUX2 PCM (
    .sel(PCM_Sel), 
    .in0(PC_O), 
    .in1(EPC), 
    .out(i_inst_addr)
    );

    NPC NPC_ (
    .PC(i_inst_addr), 
    .Imm26(Instr_D_O[25:0]), 
    .RA(RD1MFD_O), 
    .NPCOp(NPCOp), 
    .Equal(Equal), 
    .IntReq(Req),
    .NPC(NPC), 
    .PC8(PC8)
    );

    

    //D级-----------------------------------

    D_REG D_REG_ (
    .clk(clk), 
    .en(~Stall), 
    .reset(reset|Req), 
    .Req(Req),
    .Instr_D_I(i_inst_rdata), 
    .PC8_D_I(PC8), 
    .PC_D_I(i_inst_addr), 
    .Instr_D_O(Instr_D_O), 
    .PC8_D_O(PC8_D_O), 
    .PC_D_O(PC_D_O),
    .BD_D_I(BD),
    .BD_D_O(BD_D_O)
    );



    CU CU_ (
    .clk(clk), 
    .reset(reset|Req), 
    .Instr_I(Instr_D_O), 
    .Busy(Busy), 
    .ClrInstr(ClrInstr),
    .A1(A1),
    .A2(A2),
    .A3_Out(A3_Out),
    .NPCOp(NPCOp), 
    .EXTOp(EXTOp), 
    .ALUOp(ALUOp), 
    .MDOp(MDOp), 
    .Start(Start), 
    .SRCBM_Sel(SRCBM_Sel), 
    .MDM_Sel(MDM_Sel), 
    .BEOp(BEOp), 
    .DMEXTOp(DMEXTOp), 
    .RegWrite(RegWrite), 
    .GRFWDM_Sel(GRFWDM_Sel), 
    .Stall(Stall), 
    .RD1MFD_Sel(RD1MFD_Sel), 
    .RD2MFD_Sel(RD2MFD_Sel), 
    .RD1MFE_Sel(RD1MFE_Sel), 
    .RD2MFE_Sel(RD2MFE_Sel), 
    .RD2MFM_Sel(RD2MFM_Sel),
    .InstrCode_D(InstrCode_D),
    .InstrCode_E(InstrCode_E),
    .CP0Write(CP0Write),
    .CP0A(CP0A),
    .EXLClr(EXLClr),
    .BD(BD),
    .PCM_Sel(PCM_Sel)
    );

    GRF GRF_ (
    .reset(reset), 
    .clk(clk), 
    .RegWrite(RegWrite), 
    .A1(A1), 
    .A2(A2), 
    .A3(A3_Out), 
    .WD(GRFWDM_O), 
    .NowPC(), 
    .RD1(RD1), 
    .RD2(RD2)
    );
    assign w_grf_we = RegWrite;
    assign w_grf_addr = A3_Out;
    assign w_grf_wdata = GRFWDM_O;
    assign w_inst_addr = PC_W_O;

    defparam RD1MFD.WIDTH_DATA = 32;
    MUX8 RD1MFD (
    .sel(RD1MFD_Sel), 
    .in0(RD1), 
    .in1(AO_M_O), 
    .in2(MD_M_O), 
    .in3(PC8_M_O), 
    .in4(PC8_E_O), 
    .out(RD1MFD_O)
    );

    defparam RD2MFD.WIDTH_DATA = 32;
    MUX8 RD2MFD (
    .sel(RD2MFD_Sel), 
    .in0(RD2), 
    .in1(AO_M_O), 
    .in2(MD_M_O), 
    .in3(PC8_M_O), 
    .in4(PC8_E_O), 
    .out(RD2MFD_O)
    );

    EXT EXT_ (
    .EXTOp(EXTOp), 
    .EXTIn(Instr_D_O[15:0]), 
    .EXTOut(EXTOut)
    );

    CMP CMP_ (
    .D1(RD1MFD_O), 
    .D2(RD2MFD_O), 
    .Equal(Equal)
    );

    //E级---------------------------------    

    E_REG E_REG_ (
    .clk(clk), 
    .reset(reset|Stall|Req), 
    .resetPC(reset|Req),
    .Req(Req),
    .RD1_E_I(RD1MFD_O), 
    .RD1_E_O(RD1_E_O), 
    .RD2_E_I(RD2MFD_O), 
    .RD2_E_O(RD2_E_O), 
    .EXT32_E_I(EXTOut), 
    .EXT32_E_O(EXT32_E_O), 
    .Shamt_E_I(Instr_D_O[10:6]), 
    .Shamt_E_O(Shamt_E_O), 
    .PC8_E_I(PC8_D_O), 
    .PC8_E_O(PC8_E_O), 
    .PC_E_I(PC_D_O), 
    .PC_E_O(PC_E_O),
    .BD_E_I(BD_D_O),
    .BD_E_O(BD_E_O)
    );

    defparam RD1MFE.WIDTH_DATA = 32;
    MUX8 RD1MFE (
    .sel(RD1MFE_Sel), 
    .in0(RD1_E_O), 
    .in1(GRFWDM_O), 
    .in2(AO_M_O), 
    .in3(MD_M_O), 
    .in4(PC8_M_O), 
    .out(RD1MFE_O)
    );
    defparam RD2MFE.WIDTH_DATA = 32;
    MUX8 RD2MFE (
    .sel(RD2MFE_Sel), 
    .in0(RD2_E_O), 
    .in1(GRFWDM_O), 
    .in2(AO_M_O), 
    .in3(MD_M_O), 
    .in4(PC8_M_O), 
    .out(RD2MFE_O)
    );
    defparam SRCBM.WIDTH_DATA = 32;
    MUX2 SRCBM (
    .sel(SRCBM_Sel), 
    .in0(RD2MFE_O), 
    .in1(EXT32_E_O), 
    .out(SRCBM_O)
    );

    ALU ALU_ (
    .SrcA(RD1MFE_O), 
    .SrcB(SRCBM_O), 
    .shamt(Shamt_E_O), 
    .ALUOp(ALUOp), 
    .AO(AO),
    .OverFlow(OverFlow)
    );

    MD MD_ (
    .clk(clk), 
    .reset(reset), 
    .Start(Start), 
    .MDOp(MDOp), 
    .SrcA(RD1MFE_O), 
    .SrcB(RD2MFE_O), 
    .Busy(Busy), 
    .HI(HI), 
    .LO(LO)
    );

    defparam MDM.WIDTH_DATA = 32;
    MUX2 MDM (
    .sel(MDM_Sel), 
    .in0(HI), 
    .in1(LO), 
    .out(MDM_O)
    );

    //M级-------------------------------------
    M_REG M_REG_ (
    .clk(clk), 
    .reset(reset|Req),
    .Req(Req), 
    .AO_M_I(AO), 
    .AO_M_O(AO_M_O), 
    .MD_M_I(MDM_O), 
    .MD_M_O(MD_M_O), 
    .RD2_M_I(RD2MFE_O), 
    .RD2_M_O(RD2_M_O), 
    .PC8_M_I(PC8_E_O), 
    .PC8_M_O(PC8_M_O), 
    .PC_M_I(PC_E_O), 
    .PC_M_O(PC_M_O),
    .BD_M_I(BD_E_O),
    .BD_M_O(BD_M_O)
    );

    defparam RD2MFM.WIDTH_DATA = 32;
    MUX2 RD2MFM (
    .sel(RD2MFM_Sel), 
    .in0(RD2_M_O), 
    .in1(GRFWDM_O), 
    .out(RD2MFM_O)
    );

    BE BE_ (
    .BEOp(BEOp), 
    .MemA(AO_M_O), 
    .MemD(RD2MFM_O), 
    .IntReq(Req),
    .m_data_byteen(m_data_byteen), 
    .m_data_addr(m_data_addr), 
    .m_data_wdata(m_data_wdata)
    );

    assign m_inst_addr = PC_M_O;

    DMEXT DMEXT_ (
    .DMEXTOp(DMEXTOp), 
    .MemA(AO_M_O), 
    .Din(m_data_rdata), 
    .MemO(MemO)
    );

    EP EP_ (
    .clk(clk), 
    .D_clr(reset|Req), 
    .D_en(~Stall),
    .E_clr(reset|Req|Stall), 
    .M_clr(reset|Req), 
    .PC_F(i_inst_addr), 
    .InstrCode_D(InstrCode_D), 
    .InstrCode_E(InstrCode_E), 
    .AO_E(AO), 
    .OverFlow_E(OverFlow), 
    .ExcCode(ExcCode), 
    .ClrInstr(ClrInstr)
    );

    
    CP0 CP0_ (
    .clk(clk), 
    .reset(reset), 
    .A(CP0A), 
    .Din(RD2MFM_O), 
    .en(CP0Write), 
    .PC(PC_M_O), 
    .ExcCode(ExcCode), 
    .HWInt(HWInt), 
    .EXLSet(), 
    .EXLClr(EXLClr), 
    .BD(BD_M_O), 
    .Req(Req), 
    .EPC(EPC), 
    .DOut(DOut)
    );

    //W级-------------------------    

    W_REG W_REG_ (
    .clk(clk), 
    .reset(reset|Req), 
    .MemO_W_I(MemO), 
    .MemO_W_O(MemO_W_O), 
    .AO_W_I(AO_M_O), 
    .AO_W_O(AO_W_O), 
    .MD_W_I(MD_M_O), 
    .MD_W_O(MD_W_O), 
    .PC8_W_I(PC8_M_O), 
    .PC8_W_O(PC8_W_O), 
    .PC_W_I(PC_M_O), 
    .PC_W_O(PC_W_O),
    .CP0_W_I(DOut),
    .CP0_W_O(CP0_W_O)
    );

    defparam GRFWDM.WIDTH_DATA = 32;
    MUX8 GRFWDM (
    .sel(GRFWDM_Sel), 
    .in0(AO_W_O), 
    .in1(MD_W_O), 
    .in2(MemO_W_O), 
    .in3(PC8_W_O),
    .in4(CP0_W_O),  
    .out(GRFWDM_O)
    );

endmodule
