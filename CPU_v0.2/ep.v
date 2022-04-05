`include "cpu_def.vh"
module ep (
    input wire[31:0] pc_F,
    input wire[`INSTR_CODE_WIDTH-1:0] instr_code_D,
    input wire[`INSTR_CODE_WIDTH-1:0] instr_code_E,
    input wire[31:0] alu_result_E,
    input wire overflow_E,
    output wire [4:0] exc_F,
    output wire [4:0] exc_D,
    output wire [4:0] exc_E
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

    reg [4:0] r_exc_F,r_exc_D,r_exc_E;

    always @(*) begin
        if(AdEL_F)      r_exc_F = `AdEL;
        else            r_exc_F = 0;

        if(RI)          r_exc_D = `RI;
        else            r_exc_D = 0;

        if(Bp)          r_exc_E = `Bp;
        else if(Sys)    r_exc_E = `Sys;
        else if(Ov)     r_exc_E = `Ov;
        else if(AdEL_E) r_exc_E = `AdEL;
        else if(AdES)   r_exc_E = `AdES;
        else            r_exc_E = 0;
    end
    
    assign exc_F = r_exc_F;
    assign exc_D = r_exc_D;
    assign exc_E = r_exc_E;

endmodule