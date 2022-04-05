module cmp(
    input wire [31:0] data1,
    input wire [31:0] data2,
    output wire equal
);
    reg r_equal;
    
    always @(*) begin
        if(data1==data2) r_equal = 1;
        else r_equal = 0;
    end

    assign equal = r_equal;

endmodule