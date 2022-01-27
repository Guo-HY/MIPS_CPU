`include "cpu_def.vh"
module stall_controller (
    input wire[`INSTR_CODE_WIDTH-1:0] instr_code,
    output wire[1:0] tnew,
    input wire[1:0] tnew_E,
    input wire[1:0] tnew_M,
    input wire[4:0] a1,
    input wire[4:0] a2,
    input wire[4:0] a3_E,
    input wire[4:0] a3_M,
    input wire regwrite_E,
    input wire regwrite_M,
    input wire busy,
    input wire start_E,
    input wire mtc0_E,
    input wire mtc0_M,
    input wire[4:0] cp0_addr_E,
    input wire[4:0] cp0_addr_M,
    output wire stall 
);

    //暂停控制--------------------------------------------------  
    wire Tuse_RS0,Tuse_RS1,Tuse_RT0,Tuse_RT1,Tuse_RT2,Tuse_MD,Tuse_CP0;
    wire ALUType,DMType,PCType;
    
    //Tuse信号
    assign Tuse_RS0 = `BEQ|`BNE|`BGEZ|`BGTZ|`BLEZ|`BLTZ|`JR|`JALR|`BGEZAL|`BLTZAL;
    assign Tuse_RS1 = `ADDI|`ADDIU|`SLTI|`SLTIU|`ANDI|`ORI|`XORI|`ADD|`ADDU|`SUB|`SUBU|`SLT|`SLTU|`AND|`OR|`NOR|`XOR|`SLLV|`SRLV|`SRAV|`SW|`SH|`SB|`LW|`LH|`LHU|`LB|`LBU|`MTHI|`MTLO|`MULT|`MULTU|`DIV|`DIVU;
    assign Tuse_RT0 = `BEQ|`BNE;
    assign Tuse_RT1 = `SLL|`SRL|`SRA|`ADD|`ADDU|`SUB|`SUBU|`SLT|`SLTU|`AND|`OR|`NOR|`XOR|`SLLV|`SRLV|`SRAV|`MULT|`MULTU|`DIV|`DIVU|`SW|`SH|`SB;
    assign Tuse_RT2 = `MTC0;
    assign Tuse_MD  = `MFHI|`MFLO|`MTHI|`MTLO|`MULT|`MULTU|`DIV|`DIVU;
    //标志从哪一级开始产生将要写入GRF的结果
    assign ALUType  = `ADDI|`ADDIU|`SLTI|`SLTIU|`ANDI|`ORI|`XORI|`SLL|`SRL|`SRA|`ADD|`ADDU|`SUB|`SUBU|`SLT|`SLTU|`AND|`OR|`NOR|`XOR|`SLLV|`SRLV|`SRAV|`MFHI|`MFLO|`LUI;
    assign DMType   = `LW|`LH|`LB|`LHU|`LBU|`MFC0;
    assign PCType   = `JAL|`JALR|`BGEZAL|`BLTZAL;

    //生成Tnew
    reg [1:0] r_tnew;
    always @(*) begin
        if(ALUType) r_tnew = 2'b01;
        else if(DMType) r_tnew = 2'b10;
        else if(PCType) r_tnew = 2'b00;
        else r_tnew <= 2'b00;
    end
    assign tnew = r_tnew;

    //暂停条件
    wire Stall_RS0_E1 = Tuse_RS0&(tnew_E==2'b01)&(a1==a3_E)&regwrite_E&(a1!=0);
    wire Stall_RS0_E2 = Tuse_RS0&(tnew_E==2'b10)&(a1==a3_E)&regwrite_E&(a1!=0);
    wire Stall_RS0_M1 = Tuse_RS0&(tnew_M==2'b01)&(a1==a3_M)&regwrite_M&(a1!=0);
    wire Stall_RS1_E2 = Tuse_RS1&(tnew_E==2'b10)&(a1==a3_E)&regwrite_E&(a1!=0);
    wire Stall_RT0_E1 = Tuse_RT0&(tnew_E==2'b01)&(a2==a3_E)&regwrite_E&(a2!=0);
    wire Stall_RT0_E2 = Tuse_RT0&(tnew_E==2'b10)&(a2==a3_E)&regwrite_E&(a2!=0);
    wire Stall_RT0_M1 = Tuse_RT0&(tnew_M==2'b01)&(a2==a3_M)&regwrite_M&(a2!=0);
    wire Stall_RT1_E2 = Tuse_RT1&(tnew_E==2'b10)&(a2==a3_E)&regwrite_E&(a2!=0);
    wire Stall_MD = Tuse_MD&(busy==1'b1||start_E==1'b1);
    wire Stall_ERET = `ERET&((mtc0_E&(cp0_addr_E==5'd14))|(mtc0_M&(cp0_addr_M==5'd14)));

    assign stall = Stall_ERET | Stall_RS0_E1 | Stall_RS0_E2 | Stall_RS0_M1 | Stall_RS1_E2 | Stall_RT0_E1 | Stall_RT0_E2 | Stall_RT0_M1 | Stall_RT1_E2 | Stall_MD;

    
endmodule