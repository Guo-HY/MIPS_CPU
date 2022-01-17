module PC (
    input wire clk,
    input wire reset,
    input wire en,
    input wire[31:0] PC_I,
    output wire[31:0] PC_O
);
    reg [31:0]PC;

    always @(posedge clk) begin
        if(reset==1'b1) PC <= 32'h00003000;
        else if(en==1'b1) PC <= PC_I;
        else PC <= PC;
    end
    
    assign PC_O = PC;
endmodule