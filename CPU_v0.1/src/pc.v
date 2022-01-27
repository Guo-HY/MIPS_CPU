`include "cpu_def.vh"
module pc (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire req,
    input wire[31:0] pc_i,
    output wire[31:0] pc_o
);
    reg [31:0] pc;

    always @( posedge clk ) begin
        if(reset) pc <= `RESET_ADDR - 32'd4;
        else if((~stall)|req) pc <= pc_i;
        else pc <= pc;
    end

    assign pc_o = pc;
    
endmodule