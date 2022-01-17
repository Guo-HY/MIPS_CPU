module CMP (
    input wire [31:0] D1,
    input wire [31:0] D2,
    output wire Equal
);
    reg r_Equal;
    
    always @(*) begin
        if(D1==D2) r_Equal = 1;
        else r_Equal = 0;
    end

    assign Equal = r_Equal;

endmodule