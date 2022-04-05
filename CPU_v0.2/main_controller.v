`include "cpu_def.vh"
module main_controller (
    input wire[31:0] instr_i,
    input wire clr_instr,        
    output wire[4:0] a1,
    output wire[4:0] a2,
    output wire[4:0] a3,
    output wire[3:0] npc_op,
    output wire ext_op,
    output wire[4:0] alu_op,
    output wire[2:0] md_op,
    output wire start,
    output wire srcbm_sel,
    output wire mdm_sel,
    output wire[1:0] be_op,
    output wire[2:0] dmext_op,
    output wire regwrite,
    output wire [2:0] grfwdm_sel,
    output wire [`INSTR_CODE_WIDTH-1:0] instr_code,    
    output wire cp0_write,                
    output wire [4:0] cp0_addr,  
    output wire [2:0] cp0_sel,  
    output wire cache_req,
    output wire [4:0] cache_op,          
    output wire eret,   
    output wire mtc0,                    
    output wire bd
);
    wire [1:0] grfa3m_sel;
    //是否清空D级指令，ClrInstr为1即D级异常码有效，即F级产生了取指异常
    wire [31:0] instr = (clr_instr==1'b1)?0:instr_i;
    //初步译码
    wire [5:0] op = instr[31:26];
    wire [4:0] rs = instr[25:21];
    wire [4:0] rt = instr[20:16];
    wire [4:0] rd = instr[15:11];
    wire [5:0] funct = instr[5:0];
    //定义A1A2
    assign a1 = instr[25:21];
    assign a2 = instr[20:16];


    //指令译码--------------------------------------------------
    wire rtype = ~(|op);
    assign `ADDI    =   (op==6'b001000);
    assign `ADDIU   =   (op==6'b001001);
    assign `SLTI    =   (op==6'b001010);
    assign `SLTIU   =   (op==6'b001011);
    assign `ANDI    =   (op==6'b001100);
    assign `ORI     =   (op==6'b001101);
    assign `XORI    =   (op==6'b001110);
    assign `SLL     =   rtype&(funct==6'b000000);
    assign `SRL     =   rtype&(funct==6'b000010);
    assign `SRA     =   rtype&(funct==6'b000011);
    assign `ADD     =   rtype&(funct==6'b100000);
    assign `ADDU    =   rtype&(funct==6'b100001);
    assign `SUB     =   rtype&(funct==6'b100010);
    assign `SUBU    =   rtype&(funct==6'b100011);
    assign `SLT     =   rtype&(funct==6'b101010);
    assign `SLTU    =   rtype&(funct==6'b101011);
    assign `AND     =   rtype&(funct==6'b100100);
    assign `OR      =   rtype&(funct==6'b100101);
    assign `NOR     =   rtype&(funct==6'b100111);
    assign `XOR     =   rtype&(funct==6'b100110);
    assign `SLLV    =   rtype&(funct==6'b000100);
    assign `SRLV    =   rtype&(funct==6'b000110);
    assign `SRAV    =   rtype&(funct==6'b000111);
    assign `BEQ     =   (op==6'b000100);
    assign `BNE     =   (op==6'b000101);
    assign `BGEZ    =   (op==6'b000001)&(rt==5'b00001);
    assign `BGTZ    =   (op==6'b000111);
    assign `BLEZ    =   (op==6'b000110);
    assign `BLTZ    =   (op==6'b000001)&(rt==5'b00000);
    assign `SW      =   (op==6'b101011);
    assign `SH      =   (op==6'b101001);
    assign `SB      =   (op==6'b101000);
    assign `LW      =   (op==6'b100011);
    assign `LH      =   (op==6'b100001);
    assign `LHU     =   (op==6'b100101);
    assign `LB      =   (op==6'b100000);
    assign `LBU     =   (op==6'b100100);
    assign `MFHI    =   rtype&(funct==6'b010000);
    assign `MFLO    =   rtype&(funct==6'b010010);
    assign `MTHI    =   rtype&(funct==6'b010001);
    assign `MTLO    =   rtype&(funct==6'b010011);
    assign `MULT    =   rtype&(funct==6'b011000);
    assign `MULTU   =   rtype&(funct==6'b011001);
    assign `DIV     =   rtype&(funct==6'b011010);
    assign `DIVU    =   rtype&(funct==6'b011011);
    assign `JAL     =   (op==6'b000011);
    assign `JR      =   rtype&(funct==6'b001000);
    assign `JALR    =   rtype&(funct==6'b001001);
    assign `J       =   (op==6'b000010);
    assign `LUI     =   (op==6'b001111);
    assign `MFC0    =   (op==6'b010000)&(rs==5'b00000);
    assign `MTC0    =   (op==6'b010000)&(rs==5'b00100);
    assign `ERET    =   (op==6'b010000)&(funct==6'b011000);
    assign `BGEZAL  =   (op==6'b000001)&(rt==5'b10001);
    assign `BLTZAL  =   (op==6'b000001)&(rt==5'b10000);
    assign `BREAK   =   rtype&(funct==6'b001101);
    assign `SYSCALL =   rtype&(funct==6'b001100);
    assign `CACHE   =   (op==6'b101111);

    assign npc_op[3]    =    `BLTZ|`BLTZAL;
    assign npc_op[2]    =    `BNE|`BGEZ|`BGTZ|`BLEZ|`BGEZAL;
    assign npc_op[1]    =    `BGTZ|`BLEZ|`JAL|`JR|`JALR|`J; 
    assign npc_op[0]    =    `BEQ|`BGEZ|`BLEZ|`JR|`JALR|`BGEZAL;
    assign regwrite     =    `ADDI|`ADDIU|`SLTI|`SLTIU|`ANDI|`ORI|`XORI|`SLL|`SRL|`SRA|`ADD|`ADDU|`SUB|`SUBU|`SLT|`SLTU|`AND|`OR|`NOR|`XOR|`SLLV|`SRLV|`SRAV|`LW|`LH|`LHU|`LB|`LBU|`MFHI|`MFLO|`JAL|`JALR|`LUI|`MFC0|`BGEZAL|`BLTZAL;
    assign ext_op       =    `ADDI|`ADDIU|`SLTI|`SLTIU|`SW|`SH|`SB|`LW|`LH|`LHU|`LB|`LBU;
    assign alu_op[4]    =    0;
    assign alu_op[3]    =    `SLTI|`SLTIU|`SRL|`SRA|`SLT|`SLTU|`SLLV|`SRLV|`SRAV;
    assign alu_op[2]    =    `SLTI|`SLTIU|`ANDI|`XORI|`SLL|`SLT|`SLTU|`AND|`XOR|`SRAV|`LUI;
    assign alu_op[1]    =    `SLTIU|`ORI|`SLL|`SLTU|`OR|`NOR|`SLLV|`SRLV|`LUI;
    assign alu_op[0]    =    `SLTI|`ANDI|`SLL|`SRA|`SUB|`SUBU|`SLT|`AND|`NOR|`SRLV;
    assign md_op[2]     =    `MTHI|`MTLO;
    assign md_op[1]     =    `DIV|`DIVU;
    assign md_op[0]     =    `MTLO|`MULTU|`DIVU;
    assign start        =    `MULT|`MULTU|`DIV|`DIVU;
    assign be_op[1]     =    `SH|`SB;
    assign be_op[0]     =    `SW|`SB;
    assign dmext_op[2]  =    `LH;
    assign dmext_op[1]  =    `LHU|`LB;
    assign dmext_op[0]  =    `LHU|`LBU;
    assign grfwdm_sel[2] =   `MFC0;
    assign grfwdm_sel[1] =   `LW|`LH|`LHU|`LB|`LBU|`JAL|`JALR|`BGEZAL|`BLTZAL;
    assign grfwdm_sel[0] =   `MFHI|`MFLO|`JAL|`JALR|`BGEZAL|`BLTZAL;
    assign grfa3m_sel[1] =   `JAL|`BGEZAL|`BLTZAL;
    assign grfa3m_sel[0] =   `ADDI|`ADDIU|`SLTI|`SLTIU|`ANDI|`ORI|`XORI|`LW|`LH|`LHU|`LB|`LBU|`LUI|`MFC0;
    assign srcbm_sel    =    `ADDI|`ADDIU|`SLTI|`SLTIU|`ANDI|`ORI|`XORI|`SW|`SH|`SB|`LW|`LH|`LHU|`LB|`LBU|`LUI;
    assign mdm_sel      =    `MFLO;
    assign cp0_write    =    `MTC0;
   //--------------------------------------------------
    //选择A3
    reg [4:0] r_a3;
    always @(*) begin
        case (grfa3m_sel)
            2'b00: r_a3 = instr[15:11];
            2'b01: r_a3 = instr[20:16];
            2'b10: r_a3 = 5'h1f;
            default: r_a3 = 0;
        endcase
    end
    
    assign a3       =   r_a3;
    assign cp0_addr =   rd;
    assign cp0_sel  =   instr[2:0];
    assign eret     =   `ERET;
    assign mtc0     =   `MTC0;
    assign bd       =   `JAL|`JR|`JALR|`J|`BEQ|`BNE|`BGEZ|`BGTZ|`BLEZ|`BLTZ|`BGEZAL|`BLTZAL;
    assign cache_req =  `CACHE;
    assign cache_op =   rt;

endmodule