module EXT(
    input wire EXTOp,
    input wire [15:0] EXTIn,
    output wire [31:0] EXTOut
    );

    reg [31:0] r_EXTOut;
    always @(*) begin
        if(EXTOp==1'b0)begin
            r_EXTOut = {16'b0,EXTIn};
        end else begin
            r_EXTOut = {{16{EXTIn[15]}},EXTIn};
        end
    end

    assign EXTOut = r_EXTOut;
endmodule
