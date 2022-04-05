module ext(
    input wire ext_op,
    input wire [15:0] ext_in,
    output wire [31:0] ext_out
    );

    reg [31:0] r_ext_out;
    always @(*) begin
        if(ext_op==1'b0)begin
            r_ext_out = {16'b0,ext_in};
        end else begin
            r_ext_out = {{16{ext_in[15]}},ext_in};
        end
    end

    assign ext_out = r_ext_out;
endmodule
