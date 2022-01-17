module CP0 (
    input wire clk,
    input wire reset,
    input wire [4:0] A,
    input wire [31:0] Din,
    input wire en,
    input wire [31:0] PC,
    input wire [4:0] ExcCode,   //异常编码，流水线中发生的异常
    input wire [5:0] HWInt,     //外部中断请求
    input wire EXLSet,
    input wire EXLClr,          //解除中断
    input wire BD,
    output wire Req,            //CP0中断请求
    output wire [31:0] EPC,
    output wire [31:0] DOut
);
    reg [31:0] SR,Cause,r_EPC,PRId,r_DOut;

    wire IntReq = (|(HWInt&SR[15:10]))&SR[0]&~SR[1]; //响应外部中断：存在外部中断且允许中断&全局中断使能为1&异常级为0
    wire ExtReq = (|ExcCode)&~IntReq&~SR[1];         //响应内部异常：存在内部异常&不响应外部中断&异常级为0
    assign Req = IntReq | ExtReq;
    //更新SR寄存器
    always @(posedge clk) begin
        if(reset==1'b1) SR <= 0;
        else if(en==1'b1&&A==5'd12&&Req!=1'b1) SR <= Din;
        else if(Req==1'b1) SR <= {SR[31:2],1'B1,SR[0]};     //SR[1]=1
        else if(EXLClr==1'b1) SR <= {SR[31:2],1'B0,SR[0]};  //SR[1]=0
        else SR <= SR;
    end
    //更新Cause寄存器
    always @(posedge clk) begin
        if(reset==1'b1) Cause <= 0;
        else if(en==1'b1&&A==5'd13&&Req!=1'b1) Cause <= Din;
        else begin
            Cause[15:10] <= HWInt;

            if(Req) Cause[31] <= BD;
            else Cause[31] <= Cause[31];
            
            if(ExtReq) Cause[6:2] <= ExcCode;
            else if(IntReq) Cause[6:2] <= 0;
            else Cause[6:2] <= Cause[6:2];
            
            Cause[30:16] <= Cause[30:16];
            Cause[9:7] <= Cause[9:7];
            Cause[1:0] <= Cause[1:0];
        end
    end

    //更新r_EPC寄存器
    always @(posedge clk) begin
        if(reset==1'b1) r_EPC <= 0;
        else if(en==1'b1&&A==5'd14&&Req!=1'b1) r_EPC <= Din;
        else if(Req) begin
                 if(BD==1'b1) r_EPC <= PC - 4;
                 else r_EPC <= PC; 
        end else r_EPC <= r_EPC;
    end

    always @(*) begin
        if(A==5'd12) r_DOut = SR;
        else if(A==5'd13) r_DOut = Cause;
        else if(A==5'd14) r_DOut = r_EPC;
        else if(A==5'd15) r_DOut = PRId;
        else r_DOut = 0;
    end
    assign DOut = r_DOut;
    assign EPC = {r_EPC[31:2],2'b0};
    
endmodule