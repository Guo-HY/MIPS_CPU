`include "cpu_def.vh"
module cp0 (
    input wire          clk,
    input wire          reset,
    input wire          en,
    input wire [4:0]    addr,
    input wire [31:0]   wdata,
    input wire [31:0]   pc_M,
    input wire [31:0]   alu_result_M,
    input wire [4:0]    ExcCode,   //exception in pipline
    input wire [5:0]    HWInt,     //interrupt signal
    input wire          EXLClr,          //cancel interrupt
    input wire          bd,              
    output wire         req,            //interrupt request to pipline
    output wire [31:0]  epc,
    output wire [31:0]  rdata
);  
    //define the registers---------------------
    reg [31:0]  cp0_badvaddr;
    reg [31:0]  cp0_count;
    reg [31:0]  cp0_compare;
    
    reg         cp0_status_bev;
    reg [7:0]   cp0_status_im;
    reg         cp0_status_exl;
    reg         cp0_status_ie;
    wire [31:0] cp0_status = {9'b0,cp0_status_bev,6'b0,cp0_status_im,6'b0,cp0_status_exl,cp0_status_ie};

    reg         cp0_cause_bd;
    reg         cp0_cause_ti;
    reg [7:0]   cp0_cause_ip;
    reg [4:0]   cp0_cause_exccode;
    wire [31:0] cp0_cause = {cp0_cause_bd,cp0_cause_ti,14'b0,cp0_cause_ip,1'b0,cp0_cause_exccode,2'b0};

    reg [31:0]  cp0_epc;
    //end define--------------------------

    //detect the interrupt and exception
    wire int_req = (|(cp0_cause_ip&cp0_status_im))&cp0_status_ie&~cp0_status_exl;   //interrupt detect
    wire ext_req = (|ExcCode)&~int_req&~cp0_status_exl;                             //exception detect
    assign req  = int_req | ext_req;   

    //build write enable
    wire mtc0_en = en&~req;   

    wire count_eq_compare = (cp0_count==cp0_compare);                                            

    //update cp0_status
    always @(posedge clk) begin
        cp0_status_bev <= 1'b1;
    end

    always @(posedge clk) begin
        if(mtc0_en==1'b1&&addr==`CP0_STATUS_ADDR) cp0_status_im <= wdata[15:8];
    end

    always @(posedge clk) begin
        if(reset)
            cp0_status_exl <= 0;
        else if(req) 
            cp0_status_exl <= 1'b1;
        else if(EXLClr) 
            cp0_status_exl <= 1'b0;
        else if(mtc0_en==1'b1&&addr==`CP0_STATUS_ADDR) 
            cp0_status_exl <= wdata[1];
    end

    always @(posedge clk) begin
        if(reset)
            cp0_status_ie <= 1'b0;
        else if(mtc0_en==1'b1&&addr==`CP0_STATUS_ADDR)
            cp0_status_ie <= wdata[0];
    end
   
   //update cp0_cause
   always @(posedge clk) begin
        if(reset) 
            cp0_cause_bd <= 0;
        else if(req)
            cp0_cause_bd <= bd;
   end

   always @(posedge clk) begin
        if(reset)
            cp0_cause_ti <= 1'b0;
        else if(mtc0_en==1'b1&&addr==`CP0_COMPARE_ADDR)
            cp0_cause_ti <= 1'b0;
        else if(count_eq_compare)
            cp0_cause_ti <= 1'b1;
   end

   always @(posedge clk) begin
        if(reset) 
            cp0_cause_ip[7:2] <= 0;
        else begin
            cp0_cause_ip[7:2] <= {{HWInt[5]|cp0_cause_ti},HWInt[4:0]};
        end
   end

   always @(posedge clk) begin
        if(reset)
            cp0_cause_ip[1:0] <= 0;
        else if(mtc0_en==1'b1&&addr==`CP0_CAUSE_ADDR)
            cp0_cause_ip[1:0] <= wdata[9:8];
   end
    
    always @(posedge clk) begin
        if(reset) 
            cp0_cause_exccode <= 0;
        else if(ext_req) 
            cp0_cause_exccode <= ExcCode;
        else if(int_req)
            cp0_cause_exccode <= 0;
    end

    //update cp0_badvaddr
    always @(posedge clk) begin
        if(reset) 
            cp0_badvaddr <= 0;
        else if(ext_req)begin
            if(pc_M[1:0]!=0) 
                cp0_badvaddr <= pc_M;  //detect the wrong pc address
            else if(ExcCode==`AdEL||ExcCode==`AdES) 
                cp0_badvaddr <= alu_result_M;//otherwise the SRAM address must wrong
        end
    end

    //update cp0_epc
    always @(posedge clk) begin
        if(reset) 
            cp0_epc <= 0;
        else if(mtc0_en==1'b1&&addr==`CP0_EPC_ADDR)
            cp0_epc <= wdata;
        else if(req) begin
            if(bd)  cp0_epc <= pc_M - 32'd4;
            else    cp0_epc <= pc_M;
        end
    end

    //update cp0_count
    reg tick;
    always @(posedge clk) begin
        if(reset)   tick <= 1'b0;
        else        tick <= ~tick;

        if(mtc0_en==1'b1&&addr==`CP0_COUNT_ADDR)
            cp0_count <= wdata;
        else if(tick)
            cp0_count <= cp0_count + 1'b1;
    end

    //update cp0_compare
    always @(posedge clk) begin
        if(reset) cp0_compare <= 0;
        else if(mtc0_en==1'b1&&addr==`CP0_COMPARE_ADDR) cp0_compare <= wdata;
    end

    assign epc = cp0_epc;
    
    assign rdata =  ({32{addr == `CP0_BADVADDR_ADDR    }} & cp0_badvaddr) |
                    ({32{addr == `CP0_COUNT_ADDR       }} & cp0_count   ) |
                    ({32{addr == `CP0_COMPARE_ADDR     }} & cp0_compare ) |
                    ({32{addr == `CP0_STATUS_ADDR      }} & cp0_status  ) |
                    ({32{addr == `CP0_CAUSE_ADDR       }} & cp0_cause   ) |
                    ({32{addr == `CP0_EPC_ADDR         }} & cp0_epc     ) ;   

endmodule