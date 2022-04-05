`include "cpu_def.vh"
module cp0 (
    input wire          clk,
    input wire          reset,
    input wire          en,
    input wire [4:0]    addr,
    input wire [2:0]    cp0_sel,
    input wire [31:0]   wdata,
    input wire [31:0]   pc_M,
    input wire [31:0]   alu_result_M,
    input wire [4:0]    ExcCode,            //exception in pipline
    input wire [5:0]    HWInt,              //interrupt signal
    input wire          EXLClr,             //cancel interrupt
    input wire          bd,              
    output wire         req,                //interrupt request to pipline
    output wire [31:0]  epc,
    output wire [31:0]  rdata
);  
    //define the registers---------------------
    reg [31:0]  cp0_badvaddr;
    reg [31:0]  cp0_count;
    reg [31:0]  cp0_compare;
    
    reg         cp0_status_bev;
    reg [7:0]   cp0_status_im;
    reg         cp0_status_erl;
    reg         cp0_status_exl;
    reg         cp0_status_ie;
    wire [31:0] cp0_status = {9'b0,cp0_status_bev,6'b0,cp0_status_im,5'b0,cp0_status_erl,cp0_status_exl,cp0_status_ie};

    reg         cp0_cause_bd;
    reg         cp0_cause_ti;
    reg [7:0]   cp0_cause_ip;
    reg [4:0]   cp0_cause_exccode;
    wire [31:0] cp0_cause = {cp0_cause_bd,cp0_cause_ti,14'b0,cp0_cause_ip,1'b0,cp0_cause_exccode,2'b0};

    reg [31:0]  cp0_epc;

    reg         cp0_config_m;
    reg [2:0]   cp0_config_k23;
    reg [2:0]   cp0_config_ku;
    reg [8:0]   cp0_config_impl;
    reg         cp0_config_be;
    reg [1:0]   cp0_config_at;
    reg [2:0]   cp0_config_ar;
    reg [2:0]   cp0_config_mt;
    reg         cp0_config_vi;
    reg [2:0]   cp0_config_k0;
    wire [31:0] cp0_config = {cp0_config_m,cp0_config_k23,cp0_config_ku,cp0_config_impl,cp0_config_be,cp0_config_at,cp0_config_ar,cp0_config_mt,3'b0,cp0_config_vi,cp0_config_k0};
    
    reg cp0_config1_m;
    reg [5:0] cp0_config1_mmusize;
    reg [2:0] cp0_config1_is;
    reg [2:0] cp0_config1_il;
    reg [2:0] cp0_config1_ia;
    reg [2:0] cp0_config1_ds;
    reg [2:0] cp0_config1_dl;
    reg [2:0] cp0_config1_da;
    wire [31:0] cp0_config1 = {cp0_config1_m,cp0_config1_mmusize,cp0_config1_is,cp0_config1_il,cp0_config1_ia,cp0_config1_ds,cp0_config1_dl,cp0_config1_da,7'b0};
  
    reg [31:0] cp0_error_epc;
  
    //end define--------------------------

    //detect the interrupt and exception
    wire int_req = (|(cp0_cause_ip&cp0_status_im))&cp0_status_ie&~cp0_status_exl&~cp0_status_erl;   //interrupt detect
    wire ext_req = (|ExcCode)&~int_req&~cp0_status_exl&~cp0_status_erl;                             //exception detect
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
            cp0_status_erl <= 1'b1;
        else if(EXLClr)
            cp0_status_erl <= 1'b0;
        else if(mtc0_en==1'b1&&addr==`CP0_STATUS_ADDR)
            cp0_status_erl <= wdata[2];
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

    //update cp0_config
    always @(posedge clk) begin
        if(reset)begin
            cp0_config_m    <= 1'b1;
            cp0_config_k23  <= 3'd3;        //cached
            cp0_config_ku   <= 3'd3;        //cached
            cp0_config_impl <= 0;
            cp0_config_be   <= 1'b0;
            cp0_config_at   <= 0;
            cp0_config_ar   <= 0;
            cp0_config_mt   <= 3'd3;        //fixed mapped MMU      
            cp0_config_vi   <= 0;
            cp0_config_k0   <= 3'd3;        //cached
        end
    end

    //update cp0_config1
    always @(posedge clk) begin
        if(reset)begin
            cp0_config1_m <= 1'b0;
            cp0_config1_mmusize <= 1'b0;
            cp0_config1_is <= 3'd1;
            cp0_config1_il <= 3'd4;
            cp0_config1_ia <= 3'd1;
            cp0_config1_ds <= 3'd1;
            cp0_config1_dl <= 3'd4;
            cp0_config1_da <= 3'd1;
        end
    end

    //update cp0_error_epc
    always @(posedge clk) begin
        if(reset) 
            cp0_error_epc <= 0;
        else if(mtc0_en==1'b1&&addr==`CP0_ERROR_EPC_ADDR)
            cp0_error_epc <= wdata;
        else if(req) begin
            if(bd)  cp0_error_epc <= pc_M - 32'd4;
            else    cp0_error_epc <= pc_M;
        end
    end

    assign epc = cp0_status_erl ? cp0_error_epc : cp0_epc;
    
    assign rdata =  ({32{addr == `CP0_BADVADDR_ADDR    }} & cp0_badvaddr) |
                    ({32{addr == `CP0_COUNT_ADDR       }} & cp0_count   ) |
                    ({32{addr == `CP0_COMPARE_ADDR     }} & cp0_compare ) |
                    ({32{addr == `CP0_STATUS_ADDR      }} & cp0_status  ) |
                    ({32{addr == `CP0_CAUSE_ADDR       }} & cp0_cause   ) |
                    ({32{addr == `CP0_EPC_ADDR         }} & cp0_epc     ) |
                    ({32{addr == `CP0_CONFIG_ADDR && cp0_sel==3'b0}} & cp0_config) |
                    ({32{addr == `CP0_CONFIG_ADDR && cp0_sel==3'b001}} & cp0_config1)|
                    ({32{addr == `CP0_ERROR_EPC_ADDR         }} & cp0_error_epc     );   

endmodule