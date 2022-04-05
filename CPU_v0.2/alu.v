module alu(
    input wire [31:0] srca,
    input wire [31:0] srcb,
    input wire [4:0] shamt,
    input wire [4:0] alu_op,
    output wire [31:0] alu_result,
    output wire overflow
    );

    // 5'b00000:a+b
    // 5'b00001:a-b
    // 5'b00010:a OR b
    // 5'b00011:a NOR b
    // 5'b00100:a XOR b
    // 5'b00101:a AND b
    // 5'b00110:b << 16 (ORI)
    // 5'b00111:b << shamt
    // 5'b01000:逻辑右移：b>>shamt
    // 5'b01001:算术右移：b>>shamt
    // 5'b01010:SLLV
    // 5'b01011:SRLV
    // 5'b01100:SRAV
    // 5'b01101:a<b?1:0(有符号)
    // 5'b01110:a<b?1:0(无符号)

    reg [31:0] r_alu_result;
    reg r_overflow;

    assign alu_result = r_alu_result;
    assign overflow = r_overflow;
    
    always @(*) begin
        case (alu_op)
            5'b00000: r_alu_result = srca + srcb;
            5'b00001: r_alu_result = srca + ~srcb + 1;
            5'b00010: r_alu_result = srca | srcb;
            5'b00011: r_alu_result = ~(srca|srcb);
            5'b00100: r_alu_result = srca^srcb;
            5'b00101: r_alu_result = srca&srcb;
            5'b00110: r_alu_result = {srcb[15:0],16'b0};
            5'b00111: r_alu_result = srcb << shamt;
            5'b01000: r_alu_result = srcb >> shamt;
            5'b01001: r_alu_result = $signed(srcb) >>> shamt;
            5'b01010: r_alu_result = srcb << srca[4:0];
            5'b01011: r_alu_result = srcb >> srca[4:0];
            5'b01100: r_alu_result = $signed(srcb) >>> srca[4:0];
            5'b01101: if($signed(srca)<$signed(srcb)) r_alu_result = 32'b1;
                      else r_alu_result = 32'b0;
            5'b01110: if(srca<srcb) r_alu_result = 32'b1;
                      else r_alu_result = 32'b0;
            default: r_alu_result = 32'habcd_dcba;
        endcase
    end

    always @(*) begin
        if(alu_op==5'b00000&&(~srca[31]&~srcb[31]&alu_result[31]|srca[31]&srcb[31]&~alu_result[31])) r_overflow = 1;
        else if(alu_op==5'b00001&&(~srca[31]&srcb[31]&alu_result[31]|srca[31]&~srcb[31]&~alu_result[31])) r_overflow = 1;
        else r_overflow = 0;
    end


endmodule
