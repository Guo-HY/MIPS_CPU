module grf(
    input wire reset,
    input wire clk,
    input wire en,
    input wire [4:0] raddr1,
    input wire [4:0] raddr2,
    input wire [4:0] waddr,
    input wire [31:0] wdata,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2
    );

    reg [31:0] grf [31:0];
    reg [31:0]r_rdata1;
    reg [31:0]r_rdata2;

    integer i;
    always @(posedge clk) begin
        if(reset)begin
            for(i=0;i<32;i=i+1)begin
                grf[i] <= 32'b0;
            end
        end else if(en==1'b1&&waddr!=5'b0)begin
            grf[waddr] <= wdata;
        end
    end

    always @(*) begin               //内部转发，waddr为0时不转发
        if(raddr1==waddr&&en==1'b1&&waddr!=0) r_rdata1 = wdata;
        else r_rdata1 = grf[raddr1];
        if(raddr2==waddr&&en==1'b1&&waddr!=0) r_rdata2 = wdata;
        else r_rdata2 = grf[raddr2];
    end

    assign rdata1 = r_rdata1;
    assign rdata2 = r_rdata2;
endmodule
