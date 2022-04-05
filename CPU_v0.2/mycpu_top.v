//AXI测试用cpu封装
module mycpu_top (
    input wire[5:0] ext_int,

    input wire aclk,
    input wire aresetn,
    //读地址
    output wire [3:0] arid,
    output wire [31:0] araddr ,
    output wire [3 :0] arlen  ,
    output wire [2 :0] arsize ,
    output wire [1 :0] arburst,
    output wire [1 :0] arlock ,
    output wire [3 :0] arcache,
    output wire [2 :0] arprot ,
    output wire        arvalid,
    input wire         arready,
    //读数据
    input wire [3 :0] rid    ,
    input wire [31:0] rdata  ,
    input wire [1 :0] rresp  ,
    input wire        rlast  ,
    input wire        rvalid ,
    output wire       rready ,
    //写地址
    output wire [3 :0] awid   ,
    output wire [31:0] awaddr ,
    output wire [3 :0] awlen  ,
    output wire [2 :0] awsize ,
    output wire [1 :0] awburst,
    output wire [1 :0] awlock ,
    output wire [3 :0] awcache,
    output wire [2 :0] awprot ,
    output wire        awvalid,
    input wire        awready,
    //写数据
    output wire [3 :0] wid    ,
    output wire [31:0] wdata  ,
    output wire [3 :0] wstrb  ,
    output wire        wlast  ,
    output wire        wvalid ,
    input wire        wready ,
    //写反馈
    input wire [3 :0] bid    ,
    input wire [1 :0] bresp  ,
    input wire        bvalid ,
    output wire        bready,
    //debug 信号
    output wire [31:0] debug_wb_pc,
    output wire [3:0] debug_wb_rf_wen,
    output wire [4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);

    wire [31:0] inst_sram_addr;
    wire [31:0] inst_sram_rdata;
    wire inst_addr_valid;
    wire inst_addr_ready;
    wire inst_data_valid;
    wire inst_data_ready;
    wire [3:0] data_sram_wen;
    wire [31:0] data_sram_addr;
    wire [31:0] data_sram_wdata;
    wire [31:0] data_sram_rdata;
    wire data_addr_valid;
    wire data_addr_ready;
    wire data_rvalid;
    wire data_rready;
    wire data_bvalid;
    wire data_bready;

    wire data_arvalid;
    reg data_awvalid;
    wire data_awready;
    reg data_wvalid;
    wire data_wready;

    wire [3:0] inst_rid,data_rid;

    assign data_arvalid = data_addr_valid==1'b1&&data_sram_wen==4'b0;//访存端读地址有效
    reg fresh;
    always @(posedge aclk) begin
        if(aresetn==1'b0)begin
            data_awvalid <= 1'b0;
            data_wvalid <= 1'b0;
            fresh <= 1'b0;
        end else if(data_addr_valid==1'b1&&data_sram_wen!=4'b0&&fresh==1'b0)begin
            data_awvalid <= 1'b1;
            data_wvalid <= 1'b1;
            fresh <= 1'b1;
        end else begin
            if(data_awready)    data_awvalid <= 1'b0;
            if(data_wready)     data_wvalid <= 1'b0;
            if((data_awready==1||data_awvalid==1'b0)&&(data_wready==1'b1||data_wvalid==1'b0))begin
                fresh <= 1'b0;
            end   
        end
    end
  

    //访存请求优先于取指请求,ID号：访存为1，取指为0
    assign arid = data_arvalid ? 4'b0001 : 4'b0000;
    assign araddr = data_arvalid ? data_sram_addr : inst_sram_addr;
    assign arlen = 4'b0;
    assign arsize = 3'b010;
    assign arburst = 2'b01;
    assign arlock = 0;
    assign arcache = 0;
    assign arprot = 0;
    assign arvalid = data_arvalid ? data_arvalid : inst_addr_valid;

    assign rready = rvalid&(rid==4'b0) ? inst_data_ready : data_rready;

    assign awid = 4'b0001;
    assign awaddr = data_sram_addr;
    assign awlen = 0;
    assign awsize = 3'b010;
    assign awburst = 2'b01;
    assign awlock = 0;
    assign awcache = 0;
    assign awprot = 0;
    assign awvalid = data_awvalid;
    assign data_awready = awready;

    assign wid = 4'b0001;
    assign wdata = data_sram_wdata;
    assign wstrb = data_sram_wen;
    assign wlast = 1'b1;
    assign wvalid = data_wvalid;
    assign data_wready = wready;

    assign data_bvalid = bvalid;
    assign bready = data_bready;

    assign inst_addr_ready = arready & inst_addr_valid & ~data_arvalid;
    assign data_addr_ready = ((data_awready==1||data_awvalid==1'b0)&&(data_wready==1'b1||data_wvalid==1'b0)&&fresh==1'b1)||(data_arvalid==1'b1&&arready==1'b1);



mycpu mycpu_ (
   .clk                     (aclk),   
   .resetn                  (aresetn), 
   .ext_int                 (ext_int[5:0]),  

   .inst_sram_addr          (inst_sram_addr[31:0]), 
   .inst_sram_rdata         (rdata),
   .inst_addr_valid         (inst_addr_valid),
   .inst_addr_ready         (inst_addr_ready),   
   .inst_data_valid         (rvalid&(rid==4'b0)), 
   .inst_data_ready         (inst_data_ready),      

    .data_sram_wen          (data_sram_wen[3:0]),   
    .data_sram_addr         (data_sram_addr[31:0]), 
    .data_sram_wdata        (data_sram_wdata[31:0]),
    .data_sram_rdata        (rdata),
    .data_addr_valid         (data_addr_valid),    
    .data_addr_ready         (data_addr_ready),     
    .data_rvalid             (rvalid&(rid==4'b0001)),    
    .data_rready             (data_rready),         
    .data_bvalid             (data_bvalid),          
    .data_bready             (data_bready),            
   
   .debug_wb_pc             (debug_wb_pc[31:0]),    
   .debug_wb_rf_wdata       (debug_wb_rf_wdata[31:0]),
   .debug_wb_rf_wen         (debug_wb_rf_wen[3:0]), 
   .debug_wb_rf_wnum        (debug_wb_rf_wnum[4:0])
   

);


    
endmodule