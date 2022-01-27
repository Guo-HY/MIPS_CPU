`include "cpu_def.vh"
module npc (
    input wire[31:0]    pc,     //当前F级PC值
    input wire[25:0]    imm26,  
    input wire[31:0]    rs_reg, //要跳转的寄存器中正确值,在转发后
    input wire[3:0]     npc_op,
    input wire          equal,  
    input wire          int_req,
    input wire          eret,
    input wire [31:0]   epc,
    output wire[31:0]   npc,
    output wire[31:0]   pc8
);
    //4'b0000: PC <= PC + 4
    //4'b0001:equal为真则进行16位立即数跳转(beq)
    //4‘b0010:26位立即数跳转(J,JAL)
    //4’b0011:rs_reg寄存器跳转(jr,jalr)
    //4'b0100:equal为假则进行16位立即数跳转（bne）
    //4'b0101:rs寄存器>=0则进行16位立即数跳转(bgez)
    //4'b0110:rs寄存器>0则进行16位立即数跳转(bgtz)
    //4'b0111:rs寄存器<=0则进行16位立即数跳转(blez)
    //4'b1000:rs寄存器<0则进行16位立即数跳转(bltz)
    //优先级：IntReq>eret>NPCOp

    wire [31:0]pc4,imm26ext,imm16ext;
    reg [31:0] r_npc;

    assign npc = r_npc;
    assign pc4 = pc + 32'd4;
    assign imm26ext = {pc[31:28],imm26,2'b00};
    assign imm16ext = pc + {{14{imm26[15]}},imm26[15:0],2'b00};
    assign pc8 = pc + 32'd8;

    always @(*) begin
        if(int_req) r_npc = `INT_ADDR;
        else if(eret) r_npc = epc;
        else begin
            case (npc_op)
                4'b0000:r_npc = pc4;
                4'b0001:
                        if(equal) r_npc = imm16ext;
                        else r_npc = pc4;
                4'b0010:r_npc = imm26ext;
                4'b0011:r_npc = rs_reg;
                4'b0100:
                        if(~equal) r_npc = imm16ext;
                        else r_npc = pc4;      
                4'b0101:if(~rs_reg[31]) r_npc = imm16ext;
                        else r_npc = pc4;
                4'b0110:if((~rs_reg[31])&(|rs_reg)) r_npc = imm16ext;
                        else r_npc = pc4;
                4'b0111:if(~((~rs_reg[31])&(|rs_reg))) r_npc = imm16ext;
                        else r_npc = pc4;
                4'b1000:if(rs_reg[31]) r_npc = imm16ext;
                        else r_npc = pc4;
                default: r_npc = 32'h0;
            endcase

        end

    end
    
endmodule