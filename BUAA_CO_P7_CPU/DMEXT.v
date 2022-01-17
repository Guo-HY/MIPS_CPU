module DMEXT (
    input wire[2:0] DMEXTOp,
    input wire[31:0] MemA,
    input wire[31:0] Din,
    output wire[31:0] MemO
);
    // 000：无扩展
    // 001：无符号字节数据扩展
    // 010：符号字节数据扩展
    // 011：无符号半字数据扩展
    // 100：符号半字数据扩展
    reg [31:0] r_MemO;

    always @(*) begin
        case (DMEXTOp)
            3'b000: r_MemO = Din;
            3'b001: begin
                if(MemA[1:0]==2'b00) r_MemO = {24'b0,Din[7:0]};
                else if(MemA[1:0]==2'b01) r_MemO = {24'b0,Din[15:8]};
                else if(MemA[1:0]==2'b10) r_MemO = {24'b0,Din[23:16]};
                else r_MemO = {24'b0,Din[31:24]};
            end
            3'b010: begin
                if(MemA[1:0]==2'b00) r_MemO = {{24{Din[7]}},Din[7:0]};
                else if(MemA[1:0]==2'b01) r_MemO = {{24{Din[15]}},Din[15:8]};
                else if(MemA[1:0]==2'b10) r_MemO = {{24{Din[23]}},Din[23:16]};
                else r_MemO = {{24{Din[31]}},Din[31:24]};
            end
            3'b011: begin
                if(MemA[1]==1'b0) r_MemO = {16'b0,Din[15:0]};
                else r_MemO = {16'b0,Din[31:16]};
            end
            3'b100: begin
                if(MemA[1]==1'b0) r_MemO = {{16{Din[15]}},Din[15:0]};
                else r_MemO = {{16{Din[31]}},Din[31:16]};
            end
            default: r_MemO = 32'h1234abcd;
        endcase
    end

    assign MemO = r_MemO;
endmodule