module md (
    input wire clk,
    input wire reset,
    input wire start,
    input wire[2:0] md_op,
    input wire[31:0] srca,
    input wire[31:0] srcb,
    input wire int_req,
    output wire busy,
    output reg[31:0] hi,
    output reg[31:0] lo
);
    //md_op:--------
    // 3'b000:mult
    // 3'b001:multu
    // 3'b010:div
    // 3'b011:divu
    //3'b100: MTHI
    //3'b101: MTLO
    //---------------

    //state:---------
    //3'b000:reset
    //3'b001:mult(u)
    //3'b010:div(u)
    //---------------

    reg [31:0] temp_hi,temp_lo;
    reg [3:0] ret;
    reg [2:0] state;
    reg r_busy;

    assign busy = r_busy;

    always @(posedge clk) begin
        if(reset) begin
            temp_hi <= 0;
            temp_lo <= 0;
            hi <= 0;
            lo <= 0;
            ret <= 0;
            state <= 0;
        end else if(md_op==3'b100&&int_req==0)begin
            hi <= srca;
        end else if(md_op==3'b101&&int_req==0)begin
            lo <= srca;
        end else begin
           case (state)
                3'b000:if(int_req) state <= 3'b000;
                       else if(start==1'b1&&md_op==3'b000) begin
                            {temp_hi,temp_lo} <= $signed(srca) * $signed(srcb);
                            state <= 3'b001;
                       end else if(start==1'b1&&md_op==3'b001) begin 
                            {temp_hi,temp_lo} <= srca * srcb;
                            state <= 3'b001;
                       end else if(start==1'b1&&md_op==3'b010) begin
                           temp_hi <= $signed(srca) % $signed(srcb);
                           temp_lo <= $signed(srca) / $signed(srcb);
                           state <= 3'b010;
                       end else if(start==1'b1&&md_op==3'b011) begin
                           temp_hi <= srca % srcb;
                           temp_lo <= srca / srcb;
                           state <= 3'b010;
                       end else state <= 3'b0;
                3'b001: if(ret<4) begin
                            ret <= ret + 1;
                       end else begin 
                            ret <= 0;
                            state <= 3'b0;
                            hi <= temp_hi;
                            lo <= temp_lo;
                       end
                3'b010: if(ret<9) begin
                            ret <= ret + 1;
                       end else begin
                            ret <= 0;
                            state <= 3'b0;
                            hi <= temp_hi;
                            lo <= temp_lo;
                       end
                default: state <= 3'b0;
           endcase 
        end
    end
    

    always @(*) begin
        if(state==3'b001||state==3'b010) r_busy = 1'b1;
        else r_busy = 1'b0;
    end
    
endmodule