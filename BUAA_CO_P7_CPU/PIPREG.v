module D_REG (
    input wire clk,
    input wire en,
    input wire reset,
    input wire Req,
    input wire [31:0] Instr_D_I,
    input wire [31:0] PC8_D_I,
    input wire [31:0] PC_D_I,
    output wire [31:0] Instr_D_O,
    output wire [31:0] PC8_D_O,
    output wire [31:0] PC_D_O,
    input wire BD_D_I,
    output wire BD_D_O
);
    reg [31:0] Instr_D,PC8_D,PC_D;
    reg BD_D;
    always @(posedge clk) begin
        if(reset==1'b1)begin
            Instr_D <= 0;
            PC8_D <= 0;

            if(Req) PC_D <= 32'h0000_4180;
            else PC_D <= 0;

            BD_D <= 0;
        end else if(en==1'b1)begin
            Instr_D <= Instr_D_I;
            PC8_D <= PC8_D_I;
            PC_D <= PC_D_I;
            BD_D <= BD_D_I;
        end else begin
            Instr_D <= Instr_D;
            PC8_D <= PC8_D;
            PC_D <= PC_D;
            BD_D <= BD_D;
        end
    end


    assign Instr_D_O = Instr_D;
    assign PC8_D_O = PC8_D;
    assign PC_D_O = PC_D;
    assign BD_D_O = BD_D;

endmodule

module E_REG(
    input wire clk,
    input wire reset,
    input wire resetPC,
    input wire Req,
    input wire [31:0] RD1_E_I,
    output wire [31:0] RD1_E_O,
    input wire[31:0] RD2_E_I,
    output wire[31:0] RD2_E_O,
    input wire[31:0] EXT32_E_I,
    output wire[31:0] EXT32_E_O,
    input wire[4:0] Shamt_E_I,
    output wire[4:0] Shamt_E_O,
    input wire[31:0] PC8_E_I,
    output wire[31:0] PC8_E_O,
    input wire[31:0] PC_E_I,
    output wire[31:0] PC_E_O,
    input wire BD_E_I,
    output wire BD_E_O
    );
    reg [31:0] RD1_E,RD2_E,EXT32_E,PC8_E,PC_E;
    reg [4:0] Shamt_E;
    reg BD_E;

    always @(posedge clk) begin
        if(reset==1'b1)begin
            RD1_E <= 0;
            RD2_E <= 0;
            EXT32_E <= 0;
            PC8_E <= 0;
            Shamt_E <= 0;
        end else begin
            RD1_E <= RD1_E_I;
            RD2_E <= RD2_E_I;
            EXT32_E <= EXT32_E_I;
            PC8_E <= PC8_E_I;
            Shamt_E <= Shamt_E_I;
        end
    end

    always @(posedge clk) begin
        if(resetPC==1'b1) begin
            if(Req) begin
                PC_E <= 32'h0000_4180;
            end else begin
                PC_E <= 0;
            end
            BD_E <= 0;
        end else begin
            PC_E <= PC_E_I;
            BD_E <= BD_E_I;
        end
    end

    assign RD1_E_O = RD1_E;
    assign RD2_E_O = RD2_E;
    assign EXT32_E_O = EXT32_E;
    assign PC8_E_O = PC8_E;
    assign PC_E_O = PC_E;
    assign Shamt_E_O = Shamt_E;
    assign BD_E_O = BD_E;

endmodule

module M_REG(
    input wire clk,
    input wire reset,
    input wire Req,
    input wire[31:0] AO_M_I,
    output wire[31:0] AO_M_O,
    input wire[31:0] MD_M_I,
    output wire[31:0] MD_M_O,
    input wire[31:0] RD2_M_I,
    output wire[31:0] RD2_M_O,
    input wire[31:0] PC8_M_I,
    output wire[31:0] PC8_M_O,
    input wire[31:0] PC_M_I,
    output wire[31:0] PC_M_O,
    input wire BD_M_I,
    output wire BD_M_O
    );
    reg [31:0] AO_M,RD2_M,PC8_M,PC_M,MD_M;
    reg BD_M;

    always @(posedge clk) begin
        if(reset==1'b1)begin
            AO_M <= 0;
            RD2_M <= 0;
            PC8_M <= 0;

            if(Req) PC_M <= 32'h0000_4180;
            else PC_M <= 0;

            BD_M <= 0;
            MD_M <= 0;
        end else begin
            AO_M <= AO_M_I;
            RD2_M <= RD2_M_I;
            PC8_M <= PC8_M_I;
            PC_M <= PC_M_I;
            BD_M <= BD_M_I;
            MD_M <= MD_M_I;
        end
    end

    assign AO_M_O = AO_M;
    assign MD_M_O = MD_M;
    assign RD2_M_O = RD2_M;
    assign PC8_M_O = PC8_M;
    assign PC_M_O = PC_M;
    assign BD_M_O = BD_M;

endmodule

module W_REG(
    input wire clk,
    input wire reset,
    input wire[31:0] MemO_W_I,
    output wire[31:0] MemO_W_O,
    input wire[31:0] AO_W_I,
    output wire[31:0] AO_W_O,
    input wire[31:0] MD_W_I,
    output wire[31:0] MD_W_O,
    input wire[31:0] PC8_W_I,
    output wire[31:0] PC8_W_O,
    input wire[31:0] PC_W_I,
    output wire[31:0] PC_W_O,
    input wire[31:0] CP0_W_I,
    output wire[31:0] CP0_W_O
    );

    reg [31:0] MemO_W,AO_W,MD_W,PC8_W,PC_W,CP0_W;

    always @(posedge clk) begin
        if(reset==1'b1)begin
            MemO_W <= 0;
            AO_W <= 0;
            PC8_W <= 0;
            PC_W <= 0;
            MD_W <= 0;
            CP0_W <= 0;
        end else begin
            MemO_W <= MemO_W_I;
            AO_W <= AO_W_I;
            PC8_W <= PC8_W_I;
            PC_W <= PC_W_I;
            MD_W <= MD_W_I;
            CP0_W <= CP0_W_I;
        end
    end

    assign MemO_W_O = MemO_W;
    assign AO_W_O = AO_W;
    assign MD_W_O = MD_W;
    assign PC8_W_O = PC8_W;
    assign PC_W_O = PC_W;
    assign CP0_W_O = CP0_W;

endmodule
