module MUX2 (sel,in0,in1,out);//实例化时用defparameter定义位宽
    parameter WIDTH_DATA = 32;
    input sel;
    input [WIDTH_DATA-1:0] in0;
    input [WIDTH_DATA-1:0] in1;
    output [WIDTH_DATA-1:0] out;
    //-------------------------
    reg [WIDTH_DATA-1:0] r_out;

    always @(*) begin
        case (sel)
            1'b0:r_out = in0;
            1'b1:r_out = in1; 
        endcase
    end

    assign out = r_out;
endmodule

module MUX4 (sel,in0,in1,in2,in3,out);
    parameter WIDTH_DATA = 32;
    input [1:0]sel;
    input [WIDTH_DATA-1:0] in0;
    input [WIDTH_DATA-1:0] in1;
    input [WIDTH_DATA-1:0] in2;
    input [WIDTH_DATA-1:0] in3;
    output [WIDTH_DATA-1:0] out;
    //-------------------------
    reg [WIDTH_DATA-1:0] r_out;

    always @(*) begin
        case (sel)
            2'b0:r_out = in0;
            2'b1:r_out = in1;
            2'b10:r_out = in2;
            2'b11:r_out = in3; 
        endcase
    end

    assign out = r_out;
endmodule

module MUX8 (sel,in0,in1,in2,in3,in4,in5,in6,in7,out);
    parameter WIDTH_DATA = 32;
    input [2:0]sel;
    input [WIDTH_DATA-1:0] in0;
    input [WIDTH_DATA-1:0] in1;
    input [WIDTH_DATA-1:0] in2;
    input [WIDTH_DATA-1:0] in3;
    input [WIDTH_DATA-1:0] in4;
    input [WIDTH_DATA-1:0] in5;
    input [WIDTH_DATA-1:0] in6;
    input [WIDTH_DATA-1:0] in7;
    output [WIDTH_DATA-1:0] out;
    //-------------------------
    reg [WIDTH_DATA-1:0] r_out;

    always @(*) begin
        case (sel)
            3'b000:r_out = in0;
            3'b001:r_out = in1;
            3'b010:r_out = in2;
            3'b011:r_out = in3; 
            3'b100:r_out = in4; 
            3'b101:r_out = in5; 
            3'b110:r_out = in6; 
            3'b111:r_out = in7; 
        endcase
    end
    assign out = r_out;
endmodule