`include "define.vh"
module EP (
    input wire clk,
    input wire D_clr,
    input wire D_en,
    input wire E_clr,
    input wire M_clr,
    input wire [31:0] PC_F,
    input wire [63:0] InstrCode_D,
    input wire [63:0] InstrCode_E,
    input wire [31:0] AO_E,
    input wire OverFlow_E,
    output wire [4:0] ExcCode,
    output wire ClrInstr
);
    // AdEL 4 取指异常 取数异常
    // AdES 5 存数异常
    // RI 10  未知指令
    // Ov 12  溢出异常
    wire AdEL_F,AdEL_E,AdES,Ov,RI;
    reg [4:0] ExcCode_D,ExcCode_E,ExcCode_M;
    reg r_AdEL_E,r_AdES,r_Ov;
    //取指异常
    assign AdEL_F = (PC_F[1:0]!=2'b00||PC_F<32'h0000_3000||PC_F>32'h00006ffc);
    
    //未知指令
    assign RI = ~(|InstrCode_D);
    //取数异常
    wire [63:0] InstrCode = InstrCode_E;
    always @(*) begin
        if(`LW==1'b1&&AO_E[1:0]!=2'b0) r_AdEL_E = 1'b1;
        else if((`LH==1'b1||`LHU==1'b1)&&AO_E[0]==1'b1) r_AdEL_E = 1'b1;
        else if((`LH|`LHU|`LB|`LBU)&&((AO_E>=32'h0000_7F00&&AO_E<=32'h0000_7F0B)||(AO_E>=32'h0000_7F10&&AO_E<=32'h0000_7F1B))) r_AdEL_E = 1'b1;
        else if((`LW|`LH|`LHU|`LB|`LBU)&OverFlow_E) r_AdEL_E = 1'b1;
        else if((`LW|`LH|`LHU|`LB|`LBU)&&!((AO_E>=0&&AO_E<=32'h0000_2fff)||(AO_E>=32'h0000_7F00&&AO_E<=32'h0000_7F0B)||(AO_E>=32'h0000_7F10&&AO_E<=32'h0000_7F1B))) r_AdEL_E = 1'b1;
        else r_AdEL_E = 1'b0;
    end
    assign AdEL_E = r_AdEL_E;

    //存数异常
    always @(*) begin
        if(`SW==1'b1&&AO_E[1:0]!=2'b00) r_AdES = 1'b1;
        else if(`SH==1'b1&&AO_E[0]==1'b1) r_AdES = 1'b1;
        else if((`SH|`SB)&&((AO_E>=32'h0000_7F00&&AO_E<=32'h0000_7F0B)||(AO_E>=32'h0000_7F10&&AO_E<=32'h0000_7F1B))) r_AdES = 1'b1;
        else if((`SW|`SH|`SB)&OverFlow_E) r_AdES = 1'b1;
        else if((`SW|`SH|`SB)&(AO_E==32'h0000_7F08||AO_E==32'h0000_7F18)) r_AdES = 1'b1;
        else if((`SW|`SH|`SB)&&!((AO_E>=0&&AO_E<=32'h0000_2fff)||(AO_E>=32'h0000_7F00&&AO_E<=32'h0000_7F0B)||(AO_E>=32'h0000_7F10&&AO_E<=32'h0000_7F1B))) r_AdES = 1'b1;
        else r_AdES = 1'b0;
    end
    assign AdES = r_AdES;
    //溢出异常
    always @(*) begin
        if((`ADD|`ADDI|`SUB)&OverFlow_E) r_Ov = 1'b1;
        else r_Ov = 1'b0;
    end
    assign Ov = r_Ov;


    //流水线
    always @(posedge clk) begin
        if(D_clr==1'b1) ExcCode_D <= 0;
        else if(D_en) begin  
            if(AdEL_F==1'b1) ExcCode_D <= 5'd4;
            else ExcCode_D <= 0;
        end else ExcCode_D <= ExcCode_D;
    end


    always @(posedge clk) begin
        if(E_clr==1'b1) ExcCode_E <= 0;
        else if(ExcCode_D!=0) ExcCode_E <= ExcCode_D;
        else if(RI==1'b1) ExcCode_E <= 5'd10;
        else ExcCode_E <= 0;
    end


    always @(posedge clk) begin
        if(M_clr==1'b1) ExcCode_M <= 0;
        else if(ExcCode_E!=0) ExcCode_M <= ExcCode_E;
        else if(AdEL_E) ExcCode_M <= 5'd4;
        else if(AdES) ExcCode_M <= 5'd5;
        else if(Ov) ExcCode_M <= 5'd12;
        else ExcCode_M <= 0;
    end

    assign ExcCode = ExcCode_M;
    assign ClrInstr = |ExcCode_D;
    
endmodule