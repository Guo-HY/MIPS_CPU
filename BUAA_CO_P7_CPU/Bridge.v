module Bridge (
    input wire [31:0] PrAddr,   //CPU输出地址
    input wire [3:0] PrWE,      //CPU输出字节写使能
    input wire [31:0] PrWD,     //CPU输出写数据
    output wire [31:0] PrRD,    //CPU读数据

    output wire [31:0] DEVAddr, //设备读写地址
    output wire [31:0] DEVWD,   //设备写数据
    output wire [3:0] DMWE,     //DM写使能
    output wire Timer0WE,       //Timer0写使能
    output wire Timer1WE,       //Timer1写使能
    input wire [31:0] DMData,   //DM输出数据
    input wire [31:0] Timer0Data,//Timer0输出数据
    input wire [31:0] Timer1Data    //Timer1输出数据
);
    reg [3:0] r_DMWE;
    reg r_Timer0WE,r_Timer1WE;
    reg [31:0] r_PrRD;

    always @(*) begin
        if(PrAddr>=0&&PrAddr<=32'h0000_2fff) r_DMWE = PrWE;
        else r_DMWE = 0;

        if(PrAddr>=32'h0000_7f00&&PrAddr<=32'h0000_7f0b) r_Timer0WE = |PrWE;
        else r_Timer0WE = 0;

        if(PrAddr>=32'h0000_7f10&&PrAddr<=32'h0000_7f1b) r_Timer1WE = |PrWE;
        else r_Timer1WE = 0;
    end


    assign DEVAddr = PrAddr;
    assign DEVWD = PrWD;
    assign DMWE = r_DMWE;
    assign Timer0WE = r_Timer0WE;
    assign Timer1WE = r_Timer1WE;

    always @(*) begin
        if(PrAddr>=0&&PrAddr<=32'h0000_2fff) r_PrRD = DMData;
        else if(PrAddr>=32'h0000_7f00&&PrAddr<=32'h0000_7f0b) r_PrRD = Timer0Data;
        else if(PrAddr>=32'h0000_7f10&&PrAddr<=32'h0000_7f1b) r_PrRD = Timer1Data;
        else r_PrRD = 0;
    end

    assign PrRD = r_PrRD;

    
endmodule