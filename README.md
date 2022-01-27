# MIPS_CPU

一个基于MIPS指令集的CPU仓库，现在只有P7的版本，后续在做龙芯杯的过程中会不断完善

## BUAA_CO_P7_CPU

做北航计组课设P7时完成的CPU，课下与同学对拍一致，可以通过2020级P7课上测试。

### 支持的指令集

MIPS-C3：LB、LBU、LH、LHU、LW、SB、SH、SW、ADD、ADDU、 SUB、 SUBU、 MULT、 MULTU、 DIV、 DIVU、 SLL、 SRL、 SRA、 SLLV、 SRLV、SRAV、AND、OR、XOR、NOR、ADDI、ADDIU、ANDI、ORI、 XORI、LUI、SLT、SLTI、SLTIU、SLTU、BEQ、BNE、BLEZ、BGTZ、 BLTZ、BGEZ、J、JAL、JALR、JR、MFHI、MFLO、MTHI、MTLO,MFC0,,MTC0,ERET

### 其它

- 支持简单的异常与中断及重入
- 指令存储器与数据存储器外置
- 包含系统桥与两个计时器模块

具体请参见设计文档



## CPU_v0.1

单发射五级流水线CPU，仅支持SRAM访存接口，无Cache，可以通过龙芯杯SRAM接口下的功能测试。

### 相对于`BUAA_CO_P7_CPU`的改动

- 支持SRAM单周期访存。SRAM的读写时序见`CPU_v0.1/各类总线接口(不完善).pdf`
- 将控制器拆分为主控制器，暂停控制器与转发控制器。
- 将大部分信号重新命名。
- 重写了CP0模块。
- 重写了pipreg模块。
