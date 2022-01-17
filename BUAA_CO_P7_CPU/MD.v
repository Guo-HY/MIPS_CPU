module MD (
    input wire clk,
    input wire reset,
    input wire Start,
    input wire[2:0] MDOp,
    input wire[31:0] SrcA,
    input wire[31:0] SrcB,
    output wire Busy,
    output reg[31:0] HI,
    output reg[31:0] LO
);
    // 3'b000:mult
    // 3'b001:multu
    // 3'b010:div
    // 3'b011:divu
    //3'b100: MTHI
    //3'b101: MTLO

    reg [31:0] r_HI,r_LO;
    reg [31:0] ret; 
    reg [2:0] state;
    reg r_Busy;
    //3'b000:reset
    //3'b001:mult(u)
    //3'b010:div(u)

    always @(posedge clk) begin
        if(reset==1'b1) begin
            r_HI <= 0;
            r_LO <= 0;
            HI <= 0;
            LO <= 0;
            ret <= 0;
            state <= 0;
        end else if(MDOp==3'b100) begin
            HI <= SrcA;
        end else if(MDOp==3'b101) begin
            LO <= SrcA;
        end else begin
            case (state)
                3'b000: if(Start==1'b1&&MDOp==3'b000) begin
                            {r_HI,r_LO} <= $signed(SrcA) * $signed(SrcB);
                            state <= 3'b001;
                       end else if(Start==1'b1&&MDOp==3'b001) begin 
                            {r_HI,r_LO} <= SrcA * SrcB;
                            state <= 3'b001;
                       end else if(Start==1'b1&&MDOp==3'b010) begin
                           r_HI <= $signed(SrcA) % $signed(SrcB);
                           r_LO <= $signed(SrcA) / $signed(SrcB);
                           state <= 3'b010;
                       end else if(Start==1'b1&&MDOp==3'b011) begin
                           r_HI <= SrcA % SrcB;
                           r_LO <= SrcA / SrcB;
                           state <= 3'b010;
                       end else state <= 3'b0;
                3'b001: if(ret<4) begin
                            ret <= ret + 1;
                       end else begin 
                            ret <= 0;
                            state <= 3'b0;
                            HI <= r_HI;
                            LO <= r_LO;
                       end
                3'b010: if(ret<9) begin
                            ret <= ret + 1;
                       end else begin
                            ret <= 0;
                            state <= 3'b0;
                            HI <= r_HI;
                            LO <= r_LO;
                       end
                default: state <= 3'b0;
            endcase
        end
    end

    always @(*) begin
        if(state==3'b001||state==3'b010) r_Busy = 1'b1;
        else r_Busy = 1'b0;
    end

    assign Busy = r_Busy;
endmodule