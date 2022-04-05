`include "cpu_def.vh"
module npc (
    input wire[31:0]    pc,     //D级pc值
    input wire[25:0]    imm26,  
    input wire[31:0]    rs_reg, //跳转的寄存器中值，在转发后
    input wire[3:0]     npc_op,
    input wire          equal,  
    input wire          int_req,
    input wire          eret,
    input wire [31:0]   epc,
    output wire[31:0]   npc,
    output wire         branch
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
    reg r_branch;

    assign npc = r_npc;
    assign pc4 = pc + 32'd4;
    assign imm26ext = {pc4[31:28],imm26,2'b00};
    assign imm16ext = pc4 + {{14{imm26[15]}},imm26[15:0],2'b00};
    assign branch = r_branch;

    always @(*) begin
        if(int_req) begin
            r_npc = `INT_ADDR;
            r_branch = 1'b1;
        end else if(eret) begin
            r_npc = epc;
            r_branch = 1'b1;
        end else begin
            case (npc_op)
                4'b0001:
                        if(equal)begin
                            r_npc = imm16ext;
                            r_branch = 1'b1;
                        end else begin 
                            r_npc = 0;
                            r_branch = 1'b0;
                        end
                4'b0010:begin
                            r_npc = imm26ext;
                            r_branch = 1'b1;
                        end
                4'b0011:begin 
                            r_npc = rs_reg;
                            r_branch = 1'b1;
                        end
                4'b0100:
                        if(~equal)begin
                            r_npc = imm16ext;
                            r_branch = 1'b1;
                        end 
                        else begin
                            r_npc = 0;
                            r_branch = 1'b0;
                        end      
                4'b0101:if(~rs_reg[31])begin
                            r_npc = imm16ext;
                            r_branch = 1'b1;
                        end 
                        else begin
                            r_npc = 0;
                            r_branch = 1'b0;
                        end
                4'b0110:if((~rs_reg[31])&(|rs_reg))begin
                            r_npc = imm16ext;
                            r_branch = 1'b1;
                        end 
                        else begin
                            r_npc = 0;
                            r_branch = 1'b0;
                        end
                4'b0111:if(~((~rs_reg[31])&(|rs_reg)))begin
                            r_npc = imm16ext;
                            r_branch = 1'b1;
                        end 
                        else begin
                            r_npc = 0;
                            r_branch = 1'b0;
                        end    
                4'b1000:if(rs_reg[31])begin
                            r_npc = imm16ext;
                            r_branch = 1'b1;
                        end 
                        else begin
                            r_npc = 0;
                            r_branch = 1'b0;
                        end    
                default:begin
                            r_npc = 32'h0;
                            r_branch = 1'b0;
                        end
            endcase

        end

    end
    
endmodule