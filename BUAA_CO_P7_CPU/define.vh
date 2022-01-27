`define ADDI    InstrCode[0]
`define ADDIU   InstrCode[1]
`define SLTI    InstrCode[2]
`define SLTIU   InstrCode[3]
`define ANDI    InstrCode[4]
`define ORI     InstrCode[5]
`define XORI    InstrCode[6]
`define SLL     InstrCode[7]
`define SRL     InstrCode[8]
`define SRA     InstrCode[9]
`define ADD     InstrCode[10]
`define ADDU    InstrCode[11]
`define SUB     InstrCode[12]
`define SUBU    InstrCode[13]
`define SLT     InstrCode[14]
`define SLTU    InstrCode[15]
`define AND     InstrCode[16]
`define OR      InstrCode[17]
`define NOR     InstrCode[18]
`define XOR     InstrCode[19]
`define SLLV    InstrCode[20]
`define SRLV    InstrCode[21]
`define SRAV    InstrCode[22] 
`define BEQ     InstrCode[23]
`define BNE     InstrCode[24]
`define BGEZ    InstrCode[25]
`define BGTZ    InstrCode[26]
`define BLEZ    InstrCode[27]
`define BLTZ    InstrCode[28] 
`define SW      InstrCode[29]
`define SH      InstrCode[30]
`define SB      InstrCode[31]
`define LW      InstrCode[32]
`define LH      InstrCode[33]
`define LHU     InstrCode[34]
`define LB      InstrCode[35]
`define LBU     InstrCode[36]
`define MFHI    InstrCode[37]
`define MFLO    InstrCode[38]
`define MTHI    InstrCode[39] 
`define MTLO    InstrCode[40]
`define MULT    InstrCode[41]
`define MULTU   InstrCode[42]
`define DIV     InstrCode[43]
`define DIVU    InstrCode[44]
`define JAL     InstrCode[45]
`define JR      InstrCode[46]
`define JALR    InstrCode[47]
`define J       InstrCode[48]
`define LUI     InstrCode[49]
`define MFC0    InstrCode[50]
`define MTC0    InstrCode[51]
`define ERET    InstrCode[52]

`define Int 5'd0
`define AdEL 5'd4
`define AdES 5'd5
`define RI 5'd10
`define Ov 5'd12