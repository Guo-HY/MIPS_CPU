# MIPS_CPU

一个基于MIPS指令集的CPU仓库，现在只有P7的版本后续在做龙芯杯的过程中会不断完善

## BUAA_CO_P7_CPU

做北航计组课设P7时完成的CPU，课下与同学对拍一致，可以通过2020级P7课上测试。

### 支持的指令集

MIPS-C3：LB、LBU、LH、LHU、LW、SB、SH、SW、ADD、ADDU、 SUB、 SUBU、 MULT、 MULTU、 DIV、 DIVU、 SLL、 SRL、 SRA、 SLLV、 SRLV、SRAV、AND、OR、XOR、NOR、ADDI、ADDIU、ANDI、ORI、 XORI、LUI、SLT、SLTI、SLTIU、SLTU、BEQ、BNE、BLEZ、BGTZ、 BLTZ、BGEZ、J、JAL、JALR、JR、MFHI、MFLO、MTHI、MTLO,MFC0,,MTC0,ERET

### 其它

- 支持简单的异常与中断及重入
- 指令存储器与数据存储器外置
- 包含系统桥与两个计时器模块

具体请参见设计文档
