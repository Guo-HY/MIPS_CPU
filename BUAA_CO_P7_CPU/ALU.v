module ALU(
    input wire [31:0] SrcA,
    input wire [31:0] SrcB,
    input wire [4:0] shamt,
    input wire [4:0] ALUOp,
    output wire [31:0] AO,
    output wire OverFlow
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

    reg [31:0] r_AO;
    reg r_Overflow;
    always @(*) begin
        case (ALUOp)
            5'b00000: r_AO = SrcA + SrcB;
            5'b00001: r_AO = SrcA + ~SrcB + 1;
            5'b00010: r_AO = SrcA | SrcB;
            5'b00011: r_AO = ~(SrcA|SrcB);
            5'b00100: r_AO = SrcA^SrcB;
            5'b00101: r_AO = SrcA&SrcB;
            5'b00110: r_AO = {SrcB[15:0],16'b0};
            5'b00111: r_AO = SrcB << shamt;
            5'b01000: r_AO = SrcB >> shamt;
            5'b01001: r_AO = $signed(SrcB) >>> shamt;
            5'b01010: r_AO = SrcB << SrcA[4:0];
            5'b01011: r_AO = SrcB >> SrcA[4:0];
            5'b01100: r_AO = $signed(SrcB) >>> SrcA[4:0];
            5'b01101: if($signed(SrcA)<$signed(SrcB)) r_AO = 32'b1;
                      else r_AO = 32'b0;
            5'b01110: if(SrcA<SrcB) r_AO = 32'b1;
                      else r_AO = 32'b0;
            default: r_AO = 32'habcd_dcba;
        endcase
    end

    always @(*) begin
        if(ALUOp==5'b00000&&(~SrcA[31]&~SrcB[31]&AO[31]|SrcA[31]&SrcB[31]&~AO[31])) r_Overflow = 1;
        else if(ALUOp==5'b00001&&(~SrcA[31]&SrcB[31]&AO[31]|SrcA[31]&~SrcB[31]&~AO[31])) r_Overflow = 1;
        else r_Overflow = 0;
    end

    assign AO = r_AO;
    assign OverFlow = r_Overflow;
endmodule
