`define RESET_ADDR  32'hBFC0_0000   
`define INT_ADDR    32'hBFC0_0380   

`define INSTR_CODE_WIDTH 57
`define ADDI    instr_code[0]
`define ADDIU   instr_code[1]
`define SLTI    instr_code[2]
`define SLTIU   instr_code[3]
`define ANDI    instr_code[4]
`define ORI     instr_code[5]
`define XORI    instr_code[6]
`define SLL     instr_code[7]
`define SRL     instr_code[8]
`define SRA     instr_code[9]
`define ADD     instr_code[10]
`define ADDU    instr_code[11]
`define SUB     instr_code[12]
`define SUBU    instr_code[13]
`define SLT     instr_code[14]
`define SLTU    instr_code[15]
`define AND     instr_code[16]
`define OR      instr_code[17]
`define NOR     instr_code[18]
`define XOR     instr_code[19]
`define SLLV    instr_code[20]
`define SRLV    instr_code[21]
`define SRAV    instr_code[22] 
`define BEQ     instr_code[23]
`define BNE     instr_code[24]
`define BGEZ    instr_code[25]
`define BGTZ    instr_code[26]
`define BLEZ    instr_code[27]
`define BLTZ    instr_code[28] 
`define SW      instr_code[29]
`define SH      instr_code[30]
`define SB      instr_code[31]
`define LW      instr_code[32]
`define LH      instr_code[33]
`define LHU     instr_code[34]
`define LB      instr_code[35]
`define LBU     instr_code[36]
`define MFHI    instr_code[37]
`define MFLO    instr_code[38]
`define MTHI    instr_code[39] 
`define MTLO    instr_code[40]
`define MULT    instr_code[41]
`define MULTU   instr_code[42]
`define DIV     instr_code[43]
`define DIVU    instr_code[44]
`define JAL     instr_code[45]
`define JR      instr_code[46]
`define JALR    instr_code[47]
`define J       instr_code[48]
`define LUI     instr_code[49]
`define MFC0    instr_code[50]
`define MTC0    instr_code[51]
`define ERET    instr_code[52]
`define BGEZAL  instr_code[53]
`define BLTZAL  instr_code[54]
`define BREAK   instr_code[55]
`define SYSCALL instr_code[56]

`define Int     5'h0
`define AdEL    5'h4
`define AdES    5'h5
`define Sys     5'h8
`define Bp      5'h9
`define RI      5'ha
`define Ov      5'hc

`define CP0_BADVADDR_ADDR   5'd8
`define CP0_COUNT_ADDR      5'd9
`define CP0_COMPARE_ADDR    5'd11
`define CP0_STATUS_ADDR     5'd12
`define CP0_CAUSE_ADDR      5'd13
`define CP0_EPC_ADDR        5'd14