`include "cpu_def.vh"
module ep (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire req,
    input wire eret,
    input wire[31:0] pc_F,
    input wire[`INSTR_CODE_WIDTH-1:0] instr_code_D,
    input wire[`INSTR_CODE_WIDTH-1:0] instr_code_E,
    input wire[31:0] alu_result_E,
    input wire overflow_E,
    output wire[4:0] ExcCode,
    output wire ClrInstr,
    output wire has_ext_E
);

    wire AdEL_F,AdEL_E,AdES,Ov,RI,Sys,Bp;
    wire [`INSTR_CODE_WIDTH-1:0] instr_code = instr_code_E;

    //地址错例外：取指
    assign AdEL_F = (pc_F[1:0]!=2'b0);
    //保留指令例外
    assign RI = ~(|instr_code_D);
    //整型溢出例外
    assign Ov = ((`ADD|`ADDI|`SUB)&overflow_E);
    //陷阱例外
    assign Bp = `BREAK;
    //系统调用例外
    assign Sys = `SYSCALL;
    //地址错例外-数据访问
    assign AdEL_E = (`LW&(alu_result_E[1:0]!=2'b0))|((`LH|`LHU)&alu_result_E[0]);
    assign AdES = (`SW&(alu_result_E[1:0]!=2'b0))|(`SH&alu_result_E[0]);

    reg [4:0] ExcCode_D,ExcCode_E,ExcCode_M;
    //流水线
    //D级流水
    always @(posedge clk) begin
        if(reset|req)           ExcCode_D <= 0;
        else if(stall)          ExcCode_D <= ExcCode_D;
        else if(eret)           ExcCode_D <= 0;
        else if(AdEL_F)         ExcCode_D <= `AdEL;
        else                    ExcCode_D <= 0;
    end

    //E级流水
    always @(posedge clk) begin
        if(reset|req|stall)     ExcCode_E <= 0;
        else if(ExcCode_D!=0)   ExcCode_E <= ExcCode_D;
        else if(RI)             ExcCode_E <= `RI;
        else                    ExcCode_E <= 0;
    end

    //M级流水
    always @(posedge clk) begin
        if(reset|req)           ExcCode_M <= 0;
        else if(ExcCode_E!=0)   ExcCode_M <= ExcCode_E;
        else if(Bp)             ExcCode_M <= `Bp;
        else if(Sys)            ExcCode_M <= `Sys;
        else if(Ov)             ExcCode_M <= `Ov;
        else if(AdEL_E)         ExcCode_M <= `AdEL;
        else if(AdES)           ExcCode_M <= `AdES;
        else                    ExcCode_M <= 0;
    end

    assign ExcCode = ExcCode_M;
    assign ClrInstr = |ExcCode_D;
    assign has_ext_E = (|ExcCode_E);
endmodule