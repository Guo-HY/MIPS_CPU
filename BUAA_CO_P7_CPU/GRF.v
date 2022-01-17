module GRF(
    input wire reset,
    input wire clk,
    input wire RegWrite,
    input wire [4:0] A1,
    input wire [4:0] A2,
    input wire [4:0] A3,
    input wire [31:0] WD,
    input wire [31:0] NowPC,
    output wire [31:0] RD1,
    output wire [31:0] RD2
    );

    reg [31:0] grf [31:0];
    reg [31:0]r_RD1;
    reg [31:0]r_RD2;

    integer i;
    always @(posedge clk) begin
        if(reset==1'b1)begin
            for(i=0;i<32;i=i+1)begin
                grf[i] <= 32'b0;
            end
        end else if(RegWrite==1'b1&&A3!=5'b0)begin
            grf[A3] <= WD;
        end
    end

    always @(*) begin               //内部转发，A3为0时不转发
        if(A1==A3&&RegWrite==1'b1&&A3!=0) r_RD1 = WD;
        else r_RD1 = grf[A1];
        if(A2==A3&&RegWrite==1'b1&&A3!=0) r_RD2 = WD;
        else r_RD2 = grf[A2];
    end

    assign RD1 = r_RD1;
    assign RD2 = r_RD2;
endmodule
