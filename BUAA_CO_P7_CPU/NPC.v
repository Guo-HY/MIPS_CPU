module NPC(
    input wire [31:0] PC,//PC传入的当前PC值(相对于D级指令为PC+4)
    input wire [25:0] Imm26,
    input wire [31:0] RA,
    input wire [3:0] NPCOp,
    input wire Equal,
    input wire IntReq,
    output wire [31:0] NPC,
    output wire [31:0] PC8
    );

    //4'b0000: PC <= PC + 4
    //4'b0001:beq：NPC = (Equal==1)?PC+4+(signext(Imm26[15:0])||00):PC+4
    //4‘b0010:计算jal,J地址
    //4’b0011:计算jr地址
    //4'b0100:bne
    //4'b0101:BGEZ
    //4'b0110:BGTZ
    //4'b0111:BLEZ
    //4'b1000:BLTZ
    //优先级：IntReq>NPCOp
    wire [31:0] W_PC4;
    wire [31:0] Imm26ext;
    wire [31:0] Imm16ext;
    reg [31:0] r_NPC;

    assign W_PC4 = PC + 32'd4;
    assign Imm26ext = {PC[31:28],Imm26,2'b00};
    assign Imm16ext = PC + {{14{Imm26[15]}},Imm26[15:0],2'b00};

    always @(*) begin
        if(IntReq) r_NPC = 32'h0000_4180;   //Exception handler
        else begin
            case (NPCOp)
                4'b0000: r_NPC = W_PC4;
                4'b0001: begin
                            if(Equal==1'b1) r_NPC = Imm16ext;
                            else r_NPC = W_PC4;
                        end 
                4'b0010: r_NPC = Imm26ext;
                4'b0011: r_NPC = RA;
                4'b0100: begin
                            if(Equal==1'b0) r_NPC = Imm16ext;
                            else r_NPC = W_PC4;
                        end 
                4'b0101: if($signed(RA)>=0) r_NPC = Imm16ext;
                        else r_NPC = W_PC4;
                4'b0110: if($signed(RA)>0) r_NPC = Imm16ext;
                        else r_NPC = W_PC4;
                4'b0111: if($signed(RA)<=0) r_NPC = Imm16ext;
                        else r_NPC = W_PC4;
                4'b1000: if($signed(RA)<0) r_NPC = Imm16ext;
                        else r_NPC = W_PC4;
                default: r_NPC = 32'h0;
            endcase
        end
    end

    assign NPC = r_NPC;
    assign PC8 = W_PC4+32'd4;
endmodule
