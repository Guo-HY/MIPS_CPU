`timescale 1ns/1ps
`default_nettype none
module mips (
    input wire clk,
    input wire reset,
    input wire interrupt,                   //系统外部中断信号
    output wire [31:0] macroscopic_pc,      //宏观PC
    
    output wire[31:0] i_inst_addr,          //需要进行取指操作的流水级 PC（一般为 F 级）
    input wire[31:0] i_inst_rdata,          //i_inst_addr 对应的 32 位指令
    
    output wire[31:0] m_data_addr,          //DM待写入地址
    input wire[31:0] m_data_rdata,          //m_data_addr 对应的 32 位数据
    output wire[31:0] m_data_wdata,         //DM待写入数据
    output wire[3:0] m_data_byteen,         //字节使能信号

    output wire[31:0] m_inst_addr,          //M 级 PC

    output wire w_grf_we,                   //grf 写使能信号
    output wire[4:0] w_grf_addr,            // grf 中待写入寄存器编号
    output wire[31:0] w_grf_wdata,          //grf中待写入数据

    output wire[31:0] w_inst_addr           //W 级 PC
);
    wire Req;
    reg r_Req;
    always @(posedge clk) begin
        r_Req <= Req;
    end
    wire [5:0] HWInt = {3'b0,interrupt,IRQ1,IRQ0};
    assign macroscopic_pc = m_inst_addr;

    wire [31:0] PrAddr,PrWD,PrRD,DEVAddr,DEVWD,Timer0Data,Timer1Data;
    wire [3:0] PrWE,DMWE;
    wire Timer0WE,Timer1WE,IRQ0,IRQ1;

    reg delay;

    // always @(posedge clk) begin
    //     if((interrupt==1'b1)&Req) delay <= 32'd5;
    //     else if(delay>0) delay <= delay - 1;
    //     else delay <= 0;
    // end

    // always @(posedge clk) begin
    //     if((interrupt==1'b1)&Req) delay <= 1'b1;
    //     else delay <= 1'b0;
    // end

    assign m_data_addr = (interrupt&r_Req)?32'h0000_7F20:DEVAddr;
    assign m_data_wdata = DEVWD;
    assign m_data_byteen = (interrupt&r_Req)?4'b1111:DMWE;

    cpu cpu_ (
    .clk(clk), 
    .reset(reset), 
    .HWInt(HWInt),                  //外部异常
    .i_inst_addr(i_inst_addr),      //指令
    .i_inst_rdata(i_inst_rdata), 

    .m_data_addr(PrAddr),      //数据
    .m_data_byteen(PrWE),
    .m_data_wdata(PrWD), 
    .m_data_rdata(PrRD), 
     
    .m_inst_addr(m_inst_addr), 
    .w_grf_we(w_grf_we), 
    .w_grf_addr(w_grf_addr), 
    .w_grf_wdata(w_grf_wdata), 
    .w_inst_addr(w_inst_addr),
    .Req(Req)
    );


    Bridge Bridge_ (
    .PrAddr(PrAddr), 
    .PrWE(PrWE), 
    .PrWD(PrWD), 
    .PrRD(PrRD), 
    .DEVAddr(DEVAddr), 
    .DEVWD(DEVWD), 
    .DMWE(DMWE), 
    .Timer0WE(Timer0WE), 
    .Timer1WE(Timer1WE), 
    .DMData(m_data_rdata), 
    .Timer0Data(Timer0Data), 
    .Timer1Data(Timer1Data)
    );


    TC Timer0 (
    .clk(clk), 
    .reset(reset), 
    .Addr(DEVAddr[31:2]), //30位地址
    .WE(Timer0WE), 
    .Din(DEVWD), 
    .Dout(Timer0Data), 
    .IRQ(IRQ0)
    );

    TC Timer1 (
    .clk(clk), 
    .reset(reset), 
    .Addr(DEVAddr[31:2]), //30位地址
    .WE(Timer1WE), 
    .Din(DEVWD), 
    .Dout(Timer1Data), 
    .IRQ(IRQ1)
    );
    
endmodule