`include "define.vh"
module CU (
    input wire clk,
    input wire reset,
    input wire[31:0]Instr_I,
    input wire Busy,
    input wire ClrInstr,        //新增
    output wire[4:0] A1,
    output wire[4:0] A2,
    output wire[4:0] A3_Out,
    output wire[3:0] NPCOp,
    output wire EXTOp,
    output wire[4:0] ALUOp,
    output wire[2:0] MDOp,
    output wire Start,
    output wire SRCBM_Sel,
    output wire MDM_Sel,
    output wire[1:0] BEOp,
    output wire[2:0] DMEXTOp,
    output wire RegWrite,
    output wire [2:0] GRFWDM_Sel,
    output wire Stall,
    output wire [2:0]RD1MFD_Sel,
    output wire [2:0]RD2MFD_Sel,
    output wire [2:0]RD1MFE_Sel,
    output wire [2:0]RD2MFE_Sel,
    output wire RD2MFM_Sel,
    output wire [63:0] InstrCode_D,     //新增
    output wire [63:0] InstrCode_E,     //新增
    output wire CP0Write,                //新增
    output wire [4:0] CP0A,              //新增
    output wire EXLClr,                     //new
    output wire BD,                         //new
    output wire PCM_Sel                 //new
);
    //定义指令总线，未定义的总线位接地
    wire [63:0] InstrCode;
    assign InstrCode[63:53] = 0;

    wire [31:0] Instr = (ClrInstr==1'b1)?0:Instr_I;
    wire [5:0] op = Instr[31:26];
    wire [4:0] rs = Instr[25:21];
    wire [4:0] rt = Instr[20:16];
    wire [4:0] rd = Instr[15:11];
    wire [5:0] funct = Instr[5:0];
    assign A1 = Instr[25:21];
    assign A2 = Instr[20:16];
    wire [4:0]A3;

    wire [4:0]w_ALUOp;
    wire [2:0] w_MDOp,w_DMEXTOp,w_GRFWDM_Sel;
    wire w_RegWrite,w_SRCBM_Sel,w_Start,w_MDM_Sel,w_CP0Write;
    wire [1:0]w_BEOp,GRFA3M_Sel;
    //指令译码--------------------------------------------------
    wire rtype = ~(|op);
    assign `ADDI = (op==6'b001000);
    assign `ADDIU = (op==6'b001001);
    assign `SLTI = (op==6'b001010);
    assign `SLTIU = (op==6'b001011);
    assign `ANDI = (op==6'b001100);
    assign `ORI = (op==6'b001101);
    assign `XORI = (op==6'b001110);
    assign `SLL = rtype&(funct==6'b000000);
    assign `SRL = rtype&(funct==6'b000010);
    assign `SRA = rtype&(funct==6'b000011);
    assign `ADD = rtype&(funct==6'b100000);
    assign `ADDU = rtype&(funct==6'b100001);
    assign `SUB = rtype&(funct==6'b100010);
    assign `SUBU = rtype&(funct==6'b100011);
    assign `SLT = rtype&(funct==6'b101010);
    assign `SLTU = rtype&(funct==6'b101011);
    assign `AND = rtype&(funct==6'b100100);
    assign `OR = rtype&(funct==6'b100101);
    assign `NOR = rtype&(funct==6'b100111);
    assign `XOR = rtype&(funct==6'b100110);
    assign `SLLV = rtype&(funct==6'b000100);
    assign `SRLV = rtype&(funct==6'b000110);
    assign `SRAV = rtype&(funct==6'b000111);
    assign `BEQ = (op==6'b000100);
    assign `BNE = (op==6'b000101);
    assign `BGEZ = (op==6'b000001)&(rt==5'b00001);
    assign `BGTZ = (op==6'b000111);
    assign `BLEZ = (op==6'b000110);
    assign `BLTZ = (op==6'b000001)&(rt==5'b00000);
    assign `SW = (op==6'b101011);
    assign `SH = (op==6'b101001);
    assign `SB = (op==6'b101000);
    assign `LW = (op==6'b100011);
    assign `LH = (op==6'b100001);
    assign `LHU = (op==6'b100101);
    assign `LB = (op==6'b100000);
    assign `LBU = (op==6'b100100);
    assign `MFHI = rtype&(funct==6'b010000);
    assign `MFLO = rtype&(funct==6'b010010);
    assign `MTHI = rtype&(funct==6'b010001);
    assign `MTLO = rtype&(funct==6'b010011);
    assign `MULT = rtype&(funct==6'b011000);
    assign `MULTU = rtype&(funct==6'b011001);
    assign `DIV = rtype&(funct==6'b011010);
    assign `DIVU = rtype&(funct==6'b011011);
    assign `JAL = (op==6'b000011);
    assign `JR = rtype&(funct==6'b001000);
    assign `JALR = rtype&(funct==6'b001001);
    assign `J = (op==6'b000010);
    assign `LUI = (op==6'b001111);
    assign `MFC0 = (op==6'b010000)&(rs==5'b00000);
    assign `MTC0 = (op==6'b010000)&(rs==5'b00100);
    assign `ERET = (op==6'b010000)&(funct==6'b011000);

    assign NPCOp[3] = `BLTZ;
    assign NPCOp[2] = `BNE|`BGEZ|`BGTZ|`BLEZ;
    assign NPCOp[1] = `BGTZ|`BLEZ|`JAL|`JR|`JALR|`J; 
    assign NPCOp[0] = `BEQ|`BGEZ|`BLEZ|`JR|`JALR;
    assign w_RegWrite = `ADDI|`ADDIU|`SLTI|`SLTIU|`ANDI|`ORI|`XORI|`SLL|`SRL|`SRA|`ADD|`ADDU|`SUB|`SUBU|`SLT|`SLTU|`AND|`OR|`NOR|`XOR|`SLLV|`SRLV|`SRAV|`LW|`LH|`LHU|`LB|`LBU|`MFHI|`MFLO|`JAL|`JALR|`LUI|`MFC0;
    assign EXTOp = `ADDI|`ADDIU|`SLTI|`SLTIU|`SW|`SH|`SB|`LW|`LH|`LHU|`LB|`LBU;
    assign w_ALUOp[4] = 0;
    assign w_ALUOp[3] = `SLTI|`SLTIU|`SRL|`SRA|`SLT|`SLTU|`SLLV|`SRLV|`SRAV;
    assign w_ALUOp[2] = `SLTI|`SLTIU|`ANDI|`XORI|`SLL|`SLT|`SLTU|`AND|`XOR|`SRAV|`LUI;
    assign w_ALUOp[1] = `SLTIU|`ORI|`SLL|`SLTU|`OR|`NOR|`SLLV|`SRLV|`LUI;
    assign w_ALUOp[0] = `SLTI|`ANDI|`SLL|`SRA|`SUB|`SUBU|`SLT|`AND|`NOR|`SRLV;
    assign w_MDOp[2] = `MTHI|`MTLO;
    assign w_MDOp[1] = `DIV|`DIVU;
    assign w_MDOp[0] = `MTLO|`MULTU|`DIVU;
    assign w_Start = `MULT|`MULTU|`DIV|`DIVU;
    assign w_BEOp[1] = `SH|`SB;
    assign w_BEOp[0] = `SW|`SB;
    assign w_DMEXTOp[2] = `LH;
    assign w_DMEXTOp[1] = `LHU|`LB;
    assign w_DMEXTOp[0] = `LHU|`LBU;
    assign w_GRFWDM_Sel[2] = `MFC0;
    assign w_GRFWDM_Sel[1] = `LW|`LH|`LHU|`LB|`LBU|`JAL|`JALR;
    assign w_GRFWDM_Sel[0] = `MFHI|`MFLO|`JAL|`JALR;
    assign GRFA3M_Sel[1] = `JAL;
    assign GRFA3M_Sel[0] = `ADDI|`ADDIU|`SLTI|`SLTIU|`ANDI|`ORI|`XORI|`LW|`LH|`LHU|`LB|`LBU|`LUI|`MFC0;
    assign w_SRCBM_Sel = `ADDI|`ADDIU|`SLTI|`SLTIU|`ANDI|`ORI|`XORI|`SW|`SH|`SB|`LW|`LH|`LHU|`LB|`LBU|`LUI;
    assign w_MDM_Sel = `MFLO;
    assign w_CP0Write = `MTC0;
   //--------------------------------------------------
    //选择A3
    reg [4:0] r_A3;
    always @(*) begin
        case (GRFA3M_Sel)
            2'b00: r_A3 = Instr[15:11];
            2'b01: r_A3 = Instr[20:16];
            2'b10: r_A3 = 5'h1f;
            default: r_A3 = 0;
        endcase
    end
    assign A3 = r_A3;
    //流水控制信号与A1,A2,A3--------------------------------------------------
    reg [4:0] ALUOp_E,CP0A_E,CP0A_M;
    reg [2:0] MDOp_E,DMEXTOp_E,DMEXTOp_M,GRFWDM_Sel_E,GRFWDM_Sel_M,GRFWDM_Sel_W;
    reg Start_E,SRCBM_Sel_E,RegWrite_E,RegWrite_M,RegWrite_W,MDM_Sel_E,CP0Write_E,CP0Write_M,ERET_E,ERET_M;
    reg [1:0] BEOp_E,BEOp_M;
    reg [4:0] A3_E,A3_M,A3_W,A1_E,A1_M,A1_W,A2_E,A2_M,A2_W;
    reg [63:0] r_InstrCode_E,r_InstrCode_M;
    reg MTC0_E,MTC0_M;
    
    //输出BD
    assign BD = `JAL|`JR|`JALR|`J|`BEQ|`BNE|`BGEZ|`BGTZ|`BLEZ|`BLTZ;

    //E级控制信号更新---------------------------------------------
    always @(posedge clk) begin
        if(reset==1'b1||Stall==1'b1)begin
            ALUOp_E <= 0;
            MDOp_E <= 0;
            Start_E <= 0;
            SRCBM_Sel_E <= 0;
            MDM_Sel_E <= 0;
            BEOp_E <= 0;
            DMEXTOp_E <= 0;
            GRFWDM_Sel_E <= 0;
            RegWrite_E <= 0;
            A1_E <= 0;
            A2_E <= 0;
            A3_E <= 0;
            r_InstrCode_E <= 0;
            CP0Write_E <= 0;
            CP0A_E <= 0;
            ERET_E <= 0;
            MTC0_E <= 0;
        end else begin
            ALUOp_E <= w_ALUOp;
            MDOp_E <= w_MDOp;
            Start_E <= w_Start;
            SRCBM_Sel_E <= w_SRCBM_Sel;
            MDM_Sel_E <= w_MDM_Sel;
            BEOp_E <= w_BEOp;
            DMEXTOp_E <= w_DMEXTOp;
            GRFWDM_Sel_E <= w_GRFWDM_Sel;
            RegWrite_E <= w_RegWrite;
            A1_E <= A1;
            A2_E <= A2;
            A3_E <= A3;
            r_InstrCode_E <= InstrCode;
            CP0Write_E <= w_CP0Write;
            CP0A_E <= rd;
            ERET_E <= `ERET;
            MTC0_E <= `MTC0;
        end
    end
    //M级控制信号更新----------------------------------------
    always @(posedge clk) begin
        if(reset==1'b1)begin
            BEOp_M <= 0;
            DMEXTOp_M <= 0;
            GRFWDM_Sel_M <= 0;
            RegWrite_M <= 0;
            A1_M <= 0;
            A2_M <= 0;
            A3_M <= 0;
            r_InstrCode_M <= 0;
            CP0Write_M <= 0;
            CP0A_M <= 0;
            ERET_M <= 0;
            MTC0_M <= 0;
        end else begin
            BEOp_M <= BEOp_E;
            DMEXTOp_M <= DMEXTOp_E;
            GRFWDM_Sel_M <= GRFWDM_Sel_E;
            RegWrite_M <= RegWrite_E;
            A1_M <= A1_E; 
            A2_M <= A2_E;
            A3_M <= A3_E;
            r_InstrCode_M <= r_InstrCode_E;
            CP0Write_M <= CP0Write_E;
            CP0A_M <= CP0A_E;
            ERET_M <= ERET_E;
            MTC0_M <= MTC0_E;
        end
    end
    //W级控制信号更新------------------------------------------
    always @(posedge clk) begin
        if(reset==1'b1) begin
            GRFWDM_Sel_W <= 0;
            RegWrite_W <= 0;
            A1_W <= 0;
            A2_W <= 0;
            A3_W <= 0;
        end else begin
            GRFWDM_Sel_W <= GRFWDM_Sel_M;
            RegWrite_W <= RegWrite_M;
            A1_W <= A1_M;
            A2_W <= A2_M;
            A3_W <= A3_M;
        end
    end

    assign ALUOp = ALUOp_E;
    assign MDOp = MDOp_E;
    assign Start = Start_E;
    assign SRCBM_Sel = SRCBM_Sel_E;
    assign MDM_Sel = MDM_Sel_E;
    assign BEOp = BEOp_M;
    assign DMEXTOp = DMEXTOp_M;
    assign GRFWDM_Sel = GRFWDM_Sel_W;
    assign RegWrite = RegWrite_W;
    assign A3_Out = A3_W;
    assign InstrCode_D = InstrCode;
    assign InstrCode_E = r_InstrCode_E;
    assign CP0Write = CP0Write_M;
    assign CP0A = CP0A_M;
    assign EXLClr = ERET_M;
    assign PCM_Sel = `ERET;
    //----------------------------------------
  
  //暂停控制--------------------------------------------------  
    wire Tuse_RS0,Tuse_RS1,Tuse_RT0,Tuse_RT1,Tuse_RT2,Tuse_MD,Tuse_CP0;
    wire ALUType,DMType,PCType;
    //Tnew流水线寄存器
    reg [1:0] Tnew_E,Tnew_M;
    
    //Tuse信号
    assign Tuse_RS0 = `BEQ|`BNE|`BGEZ|`BGTZ|`BLEZ|`BLTZ|`JR|`JALR;
    assign Tuse_RS1 = `ADDI|`ADDIU|`SLTI|`SLTIU|`ANDI|`ORI|`XORI|`ADD|`ADDU|`SUB|`SUBU|`SLT|`SLTU|`AND|`OR|`NOR|`XOR|`SLLV|`SRLV|`SRAV|`SW|`SH|`SB|`LW|`LH|`LHU|`LB|`LBU|`MTHI|`MTLO|`MULT|`MULTU|`DIV|`DIVU;
    assign Tuse_RT0 = `BEQ|`BNE;
    assign Tuse_RT1 = `SLL|`SRL|`SRA|`ADD|`ADDU|`SUB|`SUBU|`SLT|`SLTU|`AND|`OR|`NOR|`XOR|`SLLV|`SRLV|`SRAV|`MULT|`MULTU|`DIV|`DIVU;
    assign Tuse_RT2 = `SW|`SH|`SB|`MTC0;
    assign Tuse_MD = `MFHI|`MFLO|`MTHI|`MTLO|`MULT|`MULTU|`DIV|`DIVU;
    //标志从哪一级开始产生将要写入GRF的结果
    assign ALUType = `ADDI|`ADDIU|`SLTI|`SLTIU|`ANDI|`ORI|`XORI|`SLL|`SRL|`SRA|`ADD|`ADDU|`SUB|`SUBU|`SLT|`SLTU|`AND|`OR|`NOR|`XOR|`SLLV|`SRLV|`SRAV|`MFHI|`MFLO|`LUI;
    assign DMType = `LW|`LH|`LB|`LHU|`LBU|`MFC0;
    assign PCType = `JAL|`JALR;
    //Tnew流水 E级
    always @(posedge clk) begin
        if(reset==1'b1||Stall==1'b1)begin
            Tnew_E <= 0;
        end else if(ALUType) Tnew_E <= 2'b01;
        else if(DMType) Tnew_E <= 2'b10;
        else if(PCType) Tnew_E <= 2'b00;
        else Tnew_E <= 2'b00;
    end

    //Tnew流水 M级
    always @(posedge clk) begin
        if(reset==1'b1) Tnew_M <= 0;
        else if(Tnew_E>0) Tnew_M <= Tnew_E - 1;
        else Tnew_M <= Tnew_E;
    end

    //暂停条件
    wire Stall_RS0_E1 = Tuse_RS0&(Tnew_E==2'b01)&(A1==A3_E)&RegWrite_E&(A1!=0);
    wire Stall_RS0_E2 = Tuse_RS0&(Tnew_E==2'b10)&(A1==A3_E)&RegWrite_E&(A1!=0);
    wire Stall_RS0_M1 = Tuse_RS0&(Tnew_M==2'b01)&(A1==A3_M)&RegWrite_M&(A1!=0);
    wire Stall_RS1_E2 = Tuse_RS1&(Tnew_E==2'b10)&(A1==A3_E)&RegWrite_E&(A1!=0);
    wire Stall_RT0_E1 = Tuse_RT0&(Tnew_E==2'b01)&(A2==A3_E)&RegWrite_E&(A2!=0);
    wire Stall_RT0_E2 = Tuse_RT0&(Tnew_E==2'b10)&(A2==A3_E)&RegWrite_E&(A2!=0);
    wire Stall_RT0_M1 = Tuse_RT0&(Tnew_M==2'b01)&(A2==A3_M)&RegWrite_M&(A2!=0);
    wire Stall_RT1_E2 = Tuse_RT1&(Tnew_E==2'b10)&(A2==A3_E)&RegWrite_E&(A2!=0);
    wire Stall_MD = Tuse_MD&(Busy==1'b1||Start_E==1'b1);
    wire Stall_ERET = `ERET&((MTC0_E&(CP0A_E==5'd14))|(MTC0_M&(CP0A_M==5'd14)));

    assign Stall = Stall_ERET | Stall_RS0_E1 | Stall_RS0_E2 | Stall_RS0_M1 | Stall_RS1_E2 | Stall_RT0_E1 | Stall_RT0_E2 | Stall_RT0_M1 | Stall_RT1_E2 | Stall_MD;
    //--------------------------------------------------
    //转发控制----------------------------------------------
    reg [2:0] r_RD1MFD_Sel,r_RD2MFD_Sel,r_RD1MFE_Sel,r_RD2MFE_Sel;
    reg r_RD2MFM_Sel;
    always @(*) begin//RD1MFD_Sel
        if(A1!=5'b0&&A1==A3_E&&Tnew_E==2'b0&&RegWrite_E==1'b1) r_RD1MFD_Sel = 3'b100;
        else if(A1!=5'b0&&A1==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b011) r_RD1MFD_Sel = 3'b011;
        else if(A1!=5'b0&&A1==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b001) r_RD1MFD_Sel = 3'b010;
        else if(A1!=5'b0&&A1==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b000) r_RD1MFD_Sel = 3'b001;//可以简化
        else r_RD1MFD_Sel = 3'b000;
    end
    always @(*) begin//RD2MFD_Sel
        if(A2!=5'b0&&A2==A3_E&&Tnew_E==2'b0&&RegWrite_E==1'b1) r_RD2MFD_Sel = 3'b100;
        else if(A2!=5'b0&&A2==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b011) r_RD2MFD_Sel = 3'b011;
        else if(A2!=5'b0&&A2==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b001) r_RD2MFD_Sel = 3'b010;
        else if(A2!=5'b0&&A2==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b000) r_RD2MFD_Sel = 3'b001;
        else r_RD2MFD_Sel = 3'b000;
    end
    always @(*) begin//RD1MFE_Sel
        if(A1_E!=5'b0&&A1_E==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b011)  r_RD1MFE_Sel = 3'b100;
        else if(A1_E!=5'b0&&A1_E==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b001) r_RD1MFE_Sel = 3'b011;
        else if(A1_E!=5'b0&&A1_E==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b000) r_RD1MFE_Sel = 3'b010;
        else if(A1_E!=5'b0&&A1_E==A3_W&&RegWrite_W==1'b1) r_RD1MFE_Sel = 3'b001;
        else r_RD1MFE_Sel = 3'b000;
    end
    always @(*) begin//RD2MFE_Sel
        if(A2_E!=5'b0&&A2_E==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b011)  r_RD2MFE_Sel = 3'b100;
        else if(A2_E!=5'b0&&A2_E==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b001) r_RD2MFE_Sel = 3'b011;
        else if(A2_E!=5'b0&&A2_E==A3_M&&Tnew_M==2'b0&&RegWrite_M==1'b1&&GRFWDM_Sel_M==3'b000) r_RD2MFE_Sel = 3'b010;
        else if(A2_E!=5'b0&&A2_E==A3_W&&RegWrite_W==1'b1) r_RD2MFE_Sel = 3'b001;
        else r_RD2MFE_Sel = 3'b000;
    end
    always @(*) begin//RD2MFM_Sel
        if(A2_M!=5'b0&&A2_M==A3_W&&RegWrite_W==1'b1) r_RD2MFM_Sel = 1'b1;
        else r_RD2MFM_Sel = 1'b0;
    end
    assign RD1MFD_Sel = r_RD1MFD_Sel;
    assign RD2MFD_Sel = r_RD2MFD_Sel;
    assign RD1MFE_Sel = r_RD1MFE_Sel;
    assign RD2MFE_Sel = r_RD2MFE_Sel;
    assign RD2MFM_Sel = r_RD2MFM_Sel;
    //----------------------------------------

endmodule