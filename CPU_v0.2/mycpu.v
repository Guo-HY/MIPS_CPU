//`default_nettype none
`include "cpu_def.vh"
module mycpu (
    input wire          clk,
    input wire          resetn,  //低电平复位
    input wire  [5:0]   ext_int,
    //inst_RAM
    output wire [31:0]  inst_sram_addr,
    input wire  [31:0]  inst_sram_rdata,
    output wire         inst_addr_valid,
    input wire          inst_addr_ready,
    input wire          inst_data_valid,
    output wire         inst_data_ready,
    //data_SRAM
    output wire [3:0]   data_sram_wen,
    output wire [31:0]  data_sram_addr,
    output wire [31:0]  data_sram_wdata,
    input wire  [31:0]  data_sram_rdata,
    output wire         data_addr_valid,    //地址信号与控制信号在通道中有效（读请求，写请求，写数据共用一个）
    input wire          data_addr_ready,    //slave端接收到了地址信号（读请求，写请求，写数据共用一个）
    input wire          data_rvalid,        //读数据在通道中有效
    output wire         data_rready,        //master端接受读数据
    input wire          data_bvalid,        //写反馈信号
    output wire         data_bready,        //master端可以接收写反馈信号
    //debug signal
    output wire [31:0]  debug_wb_pc,
    output wire [3:0]   debug_wb_rf_wen,
    output wire [4:0]   debug_wb_rf_wnum,
    output wire [31:0]  debug_wb_rf_wdata
);
    //-------------------------net declaration--------------------------------

    wire reset = ~resetn;
    //-----F stage-----
    wire [31:0] pc_o;


    wire [31:0] npc,pc8;
    //-----D stage-----
    wire D_allow_in,D_to_E_valid,E_allow_in,F_to_D_valid;
    wire bd_D_o;
    wire [31:0] instr_D_o,pc8_D_o,pc_D_o;
    wire [4:0] exccode_D_o;

    wire [4:0] a1,a2,a3,alu_op,cp0_addr,cache_op;
    wire [3:0] npc_op;
    wire ext_op,start,srcbm_sel,mdm_sel,regwrite,cp0_write,eret,mtc0,bd,cache_req;
    wire [2:0] md_op,dmext_op,grfwdm_sel,cp0_sel;
    wire [1:0] be_op;
    wire [`INSTR_CODE_WIDTH-1:0] instr_code;

    wire [2:0] rd1mfd_sel,rd2mfd_sel,rd1mfe_sel,rd2mfe_sel;
    wire rd2mfm_sel;

    wire [1:0] tnew;
    wire stall;

    wire [31:0] rdata1,rdata2;

    wire [31:0] rd1mfd_o;

    wire [31:0] rd2mfd_o;

    wire equal;

    wire [31:0] ext_out;
    //------E stage--------
    wire E_to_M_valid,M_allow_in;
    wire [4:0] alu_op_E_o,a1_E_o,a2_E_o,a3_E_o,cp0_addr_E_o,shamt_E_o,exccode_E_o,exccode_E_i,cache_op_E_o;
    wire [2:0] md_op_E_o,dmext_op_E_o,grfwdm_sel_E_o,cp0_sel_E_o;
    wire start_E_o,srcbm_sel_E_o,mdm_sel_E_o,regwrite_E_o,cp0_write_E_o,eret_E_o,mtc0_E_o,bd_E_o,cache_req_E_o;
    wire [1:0] be_op_E_o,tnew_E_o;
    wire [`INSTR_CODE_WIDTH-1:0] instr_code_E_o;
    wire [31:0] pc8_E_o,pc_E_o,rd1_E_o,rd2_E_o,ext32_E_o;

    wire [31:0] rd1mfe_o;

    wire [31:0] rd2mfe_o;

    wire [31:0] srcbm_o;

    wire [31:0] alu_result;
    wire overflow;

    wire busy;
    wire [31:0] hi,lo;

    wire [31:0] mdm_o;
    //--------M stage----------
    wire M_to_W_valid,W_allow_in;
    wire [1:0] be_op_M_o,tnew_M_o;
    wire [2:0] dmext_op_M_o,grfwdm_sel_M_o,cp0_sel_M_o;
    wire regwrite_M_o,cp0_write_M_o,eret_M_o,mtc0_M_o,bd_M_o,cache_req_M_o;
    wire [4:0] a1_M_o,a2_M_o,a3_M_o,cp0_addr_M_o,exccode_M_o,exccode_M_i,cache_op_M_o;
    wire [31:0] pc8_M_o,pc_M_o,rd2_M_o,alu_result_M_o,md_result_M_o;

    wire [31:0] rd2mfm_o;

    wire [3:0] m_data_byteen;
    wire [31:0] m_data_addr,m_data_wdata;

    wire [31:0] p_data_rdata,m_data_rdata;

    wire [4:0] exc_F,exc_D,exc_E;
    wire clr_instr;
    wire has_ext_E;

    wire req;
    wire [31:0] epc,cp0rdata;
    //--------W stage----------
    wire W_to_R_valid,R_allow_in;
    wire [2:0] grfwdm_sel_W_o;
    wire regwrite_W_o;
    wire [4:0] a1_W_o,a2_W_o,a3_W_o;
    wire [31:0] pc8_W_o,pc_W_o,alu_result_W_o,md_result_W_o,m_data_rdata_W_o,cp0_out_W_o;
    
    wire [31:0] grfwdm_o;


    //load and store signal--------------------------------------------
    wire load_req,store_req;
    

    assign data_sram_wen    = m_data_byteen;
    assign data_sram_addr   = {3'b0,m_data_addr[28:0]}; //固定地址转换
    assign data_sram_wdata  = m_data_wdata;
    assign p_data_rdata     = data_sram_rdata;

    assign data_addr_valid  = (store_req | load_req) & M_allow_in & ~req;//当前E级有有效的访存请求并且M级允许进入
    assign data_rready      = 1'b1;
    assign data_bready      = 1'b1;

    //load and store signal--------------------------------------------
    //debug signal----------------------------------------
    assign debug_wb_pc          = pc_W_o;
    assign debug_wb_rf_wen      = {4{regwrite_W_o}};
    assign debug_wb_rf_wnum     = a3_W_o;
    assign debug_wb_rf_wdata    = grfwdm_o;
    //debug signal----------------------------------------

    assign clr_instr = |exccode_D_o;
    assign has_ext_E = |exccode_E_o;



    //---------------------------pipline-----------------------------
    //pre-IF stage--------------------------------------
    reg [2:0] fetch_state;
    parameter IDLE          = 3'b000;
    parameter ADDR_REQ      = 3'b001;
    parameter WAIT          = 3'b010;
    parameter ADDR_REQ_TEMP = 3'b011;
    parameter EXT_REQ       = 3'b100;

    wire branch;
    reg r_branch;
    reg [31:0] r_npc;
    reg [31:0] inst_sram_addr_buffer;
    reg [31:0] wait_addr_buffer;
    reg [31:0] r_inst_sram_addr;
    wire pc_en;
    wire IF_allow_in;

    reg r_req;
    reg [31:0] ext_req_addr_buffer;
    wire req_block;

    //fetch FSM----------------------------------------------------
    always @(posedge clk) begin
        if(reset)begin
            fetch_state <= IDLE;
            r_branch <= 1'b0;
            r_req <= 1'b0;
        end else begin
            case (fetch_state)
                IDLE:   if(reset==1'b0)begin
                            fetch_state <= ADDR_REQ;
                        end 

                ADDR_REQ:   if(req==1'b1)begin      //可以直接处理异常请求
                                fetch_state <= EXT_REQ;
                                r_req <= 1'b1;
                                ext_req_addr_buffer <= npc;
                            end else if(inst_addr_valid==1'b1&&inst_addr_ready==1'b1)begin
                                if(IF_allow_in==1'b1)begin
                                    fetch_state <= ADDR_REQ;
                                end else if(IF_allow_in==1'b0)begin
                                    fetch_state <= WAIT;
                                    inst_sram_addr_buffer <= inst_sram_addr;
                                end
                            end else if(inst_addr_valid==1'b1&&inst_addr_ready==1'b0)begin
                                fetch_state <= ADDR_REQ_TEMP;
                                inst_sram_addr_buffer <= inst_sram_addr;
                            end else if(inst_addr_valid==1'b0)begin
                                fetch_state <= ADDR_REQ;
                            end

                ADDR_REQ_TEMP:  if(inst_addr_ready==1'b0)begin
                                    fetch_state <= ADDR_REQ_TEMP;
                                    if(req==1'b1)begin                  //当inst_addr_ready为0时不能直接处理异常请求
                                        r_req <= 1'b1;
                                        ext_req_addr_buffer <= npc;
                                    end else if(bd==1'b1)begin           //延迟槽阻塞在pre_IF级而D级为跳转指令的情况
                                        r_branch <= branch;
                                        r_npc <= npc;
                                    end   
                                end else if(inst_addr_ready==1'b1)begin
                                    if(req==1'b1)begin
                                        fetch_state <= EXT_REQ;
                                        r_req <= 1'b1;
                                        ext_req_addr_buffer <= npc;
                                    end else if(r_req==1'b1)begin
                                        fetch_state <= EXT_REQ;
                                    end else if(IF_allow_in==1'b1)begin
                                        if(bd==1'b1&&stall==1'b1)begin  //转移计算未完成，此时下一拍进入IF级的是延迟槽指令
                                            fetch_state <= ADDR_REQ;
                                        end else if(branch==1'b0&&r_branch==1'b0)begin//这个时候就真的没有转移指令了
                                            fetch_state <= ADDR_REQ;
                                        end else if(branch==1'b1)begin
                                            fetch_state <= ADDR_REQ_TEMP;
                                            inst_sram_addr_buffer <= npc;
                                            r_branch <= 1'b0;
                                        end else if(r_branch==1'b1)begin    //此时因为D级没有转移指令，所以r_npc中的值是最新的
                                            fetch_state <= ADDR_REQ_TEMP;
                                            inst_sram_addr_buffer <= r_npc;
                                            r_branch <= 1'b0;
                                        end 
                                    end else if(IF_allow_in==1'b0)begin
                                        fetch_state <= WAIT;
                                        inst_sram_addr_buffer <= inst_sram_addr;
                                        if(bd==1'b1)begin
                                            r_branch <= branch;
                                            r_npc <= npc;
                                        end
                                    end
                                end

                WAIT:       if(req==1'b1)begin                  //可以直接处理异常请求
                                fetch_state <= EXT_REQ;
                                r_req <= 1'b1;
                                ext_req_addr_buffer <= npc;
                            end else if(IF_allow_in==1'b0)begin  //WAIT状态：当前pre_IF级地址已经接收，但是还不能进入IF级
                                fetch_state <= WAIT;
                                if(bd==1'b1)begin
                                    r_branch <= branch;
                                    r_npc <= npc;
                                end
                            end else if(IF_allow_in==1'b1)begin
                                if(branch==1'b0&&r_branch==1'b0)begin
                                    fetch_state <= ADDR_REQ;
                                end else if(branch==1'b1)begin
                                    fetch_state <= ADDR_REQ_TEMP;
                                    inst_sram_addr_buffer <= npc;
                                    r_branch <= 1'b0;
                                end else if(r_branch==1'b1)begin
                                    fetch_state <= ADDR_REQ_TEMP;
                                    inst_sram_addr_buffer <= r_npc;
                                    r_branch <= 1'b0;
                                end 
                            end        

                EXT_REQ:    if(req_block==1'b0)begin
                                r_req <= 1'b0;
                                fetch_state <= ADDR_REQ_TEMP;
                                inst_sram_addr_buffer <= ext_req_addr_buffer;
                            end                 

                default: fetch_state <= 3'b111;
            endcase
        end
    end
    //fetch FSM----------------------------------------------------
    assign inst_sram_addr = r_inst_sram_addr;
    always@(*)begin
        if(fetch_state==ADDR_REQ_TEMP||fetch_state==WAIT)   r_inst_sram_addr = inst_sram_addr_buffer;
        else if(branch==1'b1)                               r_inst_sram_addr = npc;
        else                                                r_inst_sram_addr = pc_o + 32'd4;
    end
    assign inst_addr_valid = (((fetch_state==ADDR_REQ) || (fetch_state==ADDR_REQ_TEMP)) && !(bd==1'b1&&stall==1'b1&&IF_allow_in==1'b0)) && !(req==1'b1&&fetch_state==ADDR_REQ);//D级转移计算未完成并且IF级是延迟槽指令
    
    assign pc_en = (inst_addr_valid & inst_addr_ready & IF_allow_in) | (fetch_state==WAIT & IF_allow_in);

    wire pre_IF_to_IF_valid = (inst_addr_valid & inst_addr_ready) | (fetch_state==WAIT) & ~req & ~r_req;

   

    //-------------IF stage---------------

    
    pc pc_ (
        .clk    (clk            ), 
        .reset  (reset          ), 
        .en     (pc_en          ), 
        .pc_i   (inst_sram_addr ), 
        .pc_o   (pc_o           )
    ); 

    assign inst_data_ready = 1'b1;

    wire inst_buffer_empty;
    reg IF_valid;
    wire IF_ready_go = inst_data_valid|~inst_buffer_empty;
    assign IF_allow_in = (!IF_valid || (IF_ready_go && D_allow_in)) && !req_block;
    assign F_to_D_valid = IF_valid && IF_ready_go;

    always @(posedge clk) begin
        if(reset|req)
            IF_valid <= 1'b0;
        else if(IF_allow_in==1'b1)
            IF_valid <= pre_IF_to_IF_valid;
    end


    // inst_data_FIFO-------------------------------------------------------------
    reg [31:0] inst_data_buffer[1:0];    //当D级不允许进入的时候缓存传回的指令,最多缓存两条
    reg [1:0] inst_data_buffer_wp,inst_data_buffer_rp;
    assign inst_buffer_empty = (inst_data_buffer_wp==inst_data_buffer_rp);

    always @(posedge clk) begin
        if(reset|req)begin
            inst_data_buffer_wp <= 0;
            inst_data_buffer_rp <= 0;
        end else if((inst_data_valid&~D_allow_in)|(inst_data_valid&~inst_buffer_empty))begin
            inst_data_buffer[inst_data_buffer_wp[0]] <= inst_sram_rdata;
            inst_data_buffer_wp <= inst_data_buffer_wp + 1;
        end
        if(D_allow_in&~inst_buffer_empty)begin
            inst_data_buffer_rp <= inst_data_buffer_rp + 1;
        end
            
    end
    // inst_data_FIFO-------------------------------------------------------------

    // inst_data_ret--------------------------------------------------------------//单纯的未返回指令计数器
    reg [2:0] inst_data_ret;
    always @(posedge clk) begin
        if(reset)   inst_data_ret <= 0;
        else if(inst_addr_valid & inst_addr_ready & ~inst_data_valid) inst_data_ret <= inst_data_ret + 1;//需要保证ADDR_REQ状态下产生异常时异常不会发出请求
        else if(inst_addr_valid & inst_addr_ready & inst_data_valid)  inst_data_ret <= inst_data_ret;
        else if(inst_data_valid) inst_data_ret <= inst_data_ret - 1;
    end
    // inst_data_ret--------------------------------------------------------------
    reg [1:0] req_block_state;
    always @(posedge clk) begin
        if(reset)   req_block_state <= 2'b00;
        else begin
            case (req_block_state)
                2'b00:  if(req)                     req_block_state <= 2'b01;
                2'b01:  if(fetch_state==EXT_REQ)    req_block_state <= 2'b10;
                2'b10:  if(inst_data_ret==0)        req_block_state <= 2'b00; 
                default: req_block_state <= 2'b11;
            endcase
        end
    end
    assign req_block = (req_block_state==2'b01)||(req_block_state==2'b10);  //req_block为1时IF_allow_in为0，代表当前有未返回的脏数据
    
    wire [31:0] instr_D_i = inst_buffer_empty ? inst_sram_rdata : inst_data_buffer[inst_data_buffer_rp[0]];

    //---------------D stage------------------------

    // wire [31:0] pc_D_i = eret ? npc : pc_o;
    
   
    D_reg D_reg_ (
        .clk            (clk            ), 
        .reset          (reset          ), 
        .D_allow_in     (D_allow_in     ),
        .D_to_E_valid   (D_to_E_valid   ),
        .E_allow_in     (E_allow_in     ),
        .F_to_D_valid   (F_to_D_valid   ),
        .req            (req            ), 
        .stall          (stall          ), 
        .eret           (eret           ),
        .bd_D_i         (bd             ), 
        .bd_D_o         (bd_D_o         ), 
        .instr_D_i      (instr_D_i      ), 
        .instr_D_o      (instr_D_o      ), 
        .pc8_D_i        (pc_o + 8       ), 
        .pc8_D_o        (pc8_D_o        ), 
        .pc_D_i         (pc_o           ), 
        .pc_D_o         (pc_D_o         ),
        .exccode_D_i    (exc_F          ),
        .exccode_D_o    (exccode_D_o    )
    );

    npc npc_ (
        .pc     (pc_D_o             ), 
        .imm26  (instr_D_o[25:0]    ), 
        .rs_reg (rd1mfd_o           ), 
        .npc_op (npc_op             ), 
        .equal  (equal              ), 
        .int_req(req                ), 
        .eret   (eret               ),
        .epc    (epc                ),
        .npc    (npc                ), 
        .branch (branch             )
    );

    main_controller main_controller_ (
        .instr_i    (instr_D_o  ), 
        .clr_instr  (clr_instr  ), 
        .a1         (a1         ), 
        .a2         (a2         ), 
        .a3         (a3         ), 
        .npc_op     (npc_op     ),  //4 
        .ext_op     (ext_op     ),  //1
        .alu_op     (alu_op     ),  //5
        .md_op      (md_op      ),  //3
        .start      (start      ),  //1
        .srcbm_sel  (srcbm_sel  ),  //1
        .mdm_sel    (mdm_sel    ),  //1
        .be_op      (be_op      ),  //2
        .dmext_op   (dmext_op   ),  //3
        .regwrite   (regwrite   ),  //1
        .grfwdm_sel (grfwdm_sel ),  //3
        .instr_code (instr_code ),  //INSTR_CODE_WIDTH
        .cp0_write  (cp0_write  ),  //1
        .cp0_addr   (cp0_addr   ),  //5
        .cp0_sel    (cp0_sel    ),  //3
        .cache_req  (cache_req  ),  //1
        .cache_op   (cache_op   ),  //5
        .eret       (eret       ),  //1
        .mtc0       (mtc0       ),  //1 
        .bd         (bd         )   //1
    );


    

    forward_controller forward_controller_ (
        .a1             (a1             ), 
        .a1_E           (a1_E_o         ), 
        .a2             (a2             ), 
        .a2_E           (a2_E_o       ), 
        .a2_M           (a2_M_o       ), 
        .a3_E           (a3_E_o       ), 
        .a3_M           (a3_M_o       ), 
        .a3_W           (a3_W_o       ), 
        .tnew_E         (tnew_E_o     ), 
        .tnew_M         (tnew_M_o     ), 
        .regwrite_E     (regwrite_E_o ), 
        .regwrite_M     (regwrite_M_o ), 
        .regwrite_W     (regwrite_W_o ), 
        .grfwdm_sel_M   (grfwdm_sel_M_o), 
        .rd1mfd_sel     (rd1mfd_sel ),  //3
        .rd2mfd_sel     (rd2mfd_sel ),  //3
        .rd1mfe_sel     (rd1mfe_sel ),  //3
        .rd2mfe_sel     (rd2mfe_sel ),  //3
        .rd2mfm_sel     (rd2mfm_sel )   //1
    );


    
    stall_controller stall_controller_ (
        .instr_code     (instr_code       ), 
        .tnew           (tnew             ),  //2
        .tnew_E         (tnew_E_o         ), 
        .tnew_M         (tnew_M_o         ), 
        .a1             (a1               ), 
        .a2             (a2               ), 
        .a3_E           (a3_E_o           ), 
        .a3_M           (a3_M_o           ), 
        .regwrite_E     (regwrite_E_o     ), 
        .regwrite_M     (regwrite_M_o     ), 
        .M_ready_go     (M_allow_in       ),
        .busy           (busy             ), 
        .start_E        (start_E_o        ), 
        .mtc0_E         (mtc0_E_o         ), 
        .mtc0_M         (mtc0_M_o         ), 
        .cp0_addr_E     (cp0_addr_E_o     ), 
        .cp0_addr_M     (cp0_addr_M_o     ), 
        .stall          (stall            )
    );

    
    grf grf_ (
        .reset      (reset      ), 
        .clk        (clk        ), 
        .en         (regwrite_W_o), 
        .raddr1     (a1         ), 
        .raddr2     (a2         ), 
        .waddr      (a3_W_o     ), 
        .wdata      (grfwdm_o   ), 
        .rdata1     (rdata1     ), 
        .rdata2     (rdata2     )
    );

    
    MUX8 rd1mfd_ (
        .sel    (rd1mfd_sel     ), 
        .in0    (rdata1         ), 
        .in1    (alu_result_M_o ), 
        .in2    (md_result_M_o  ), 
        .in3    (pc8_M_o        ), 
        .in4    (pc8_E_o        ), 
        .in5(), 
        .in6(), 
        .in7(), 
        .out    (rd1mfd_o       )
    );

    
    MUX8 rd2mfd_ (
        .sel    (rd2mfd_sel     ), 
        .in0    (rdata2         ), 
        .in1    (alu_result_M_o ), 
        .in2    (md_result_M_o  ), 
        .in3    (pc8_M_o        ), 
        .in4    (pc8_E_o        ), 
        .in5(), 
        .in6(), 
        .in7(), 
        .out    (rd2mfd_o       )
    );

    
    cmp cmp_ (
        .data1  (rd1mfd_o   ), 
        .data2  (rd2mfd_o   ), 
        .equal  (equal      )
    );

    
    ext ext_ (
        .ext_op (ext_op         ), 
        .ext_in (instr_D_o[15:0]), 
        .ext_out(ext_out        )
    ); 


    //-------------------E stage---------------------
    
    assign exccode_E_i = (exccode_D_o==0) ? exc_D : exccode_D_o;
    
    E_reg E_reg_ (
        .clk            (clk            ), 
        .reset          (reset          ), 
        .E_allow_in     (E_allow_in     ),
        .E_to_M_valid   (E_to_M_valid   ),
        .M_allow_in     (M_allow_in     ),
        .D_to_E_valid   (D_to_E_valid   ),
        .req            (req            ), 
        .stall          (stall          ), 
        .alu_op_E_i     (alu_op         ), 
        .alu_op_E_o     (alu_op_E_o     ), 
        .md_op_E_i      (md_op          ), 
        .md_op_E_o      (md_op_E_o      ), 
        .start_E_i      (start          ), 
        .start_E_o      (start_E_o      ), 
        .srcbm_sel_E_i  (srcbm_sel      ), 
        .srcbm_sel_E_o  (srcbm_sel_E_o  ), 
        .mdm_sel_E_i    (mdm_sel        ), 
        .mdm_sel_E_o    (mdm_sel_E_o    ), 
        .be_op_E_i      (be_op          ), 
        .be_op_E_o      (be_op_E_o      ), 
        .data_addr_valid(data_addr_valid),
        .data_addr_ready(data_addr_ready),
        .store_req      (store_req      ),
        .load_req       (load_req       ),
        .dmext_op_E_i   (dmext_op       ), 
        .dmext_op_E_o   (dmext_op_E_o   ), 
        .grfwdm_sel_E_i (grfwdm_sel     ), 
        .grfwdm_sel_E_o (grfwdm_sel_E_o ), 
        .regwrite_E_i   (regwrite       ), 
        .regwrite_E_o   (regwrite_E_o   ), 
        .a1_E_i         (a1             ), 
        .a1_E_o         (a1_E_o         ), 
        .a2_E_i         (a2             ), 
        .a2_E_o         (a2_E_o         ), 
        .a3_E_i         (a3             ), 
        .a3_E_o         (a3_E_o         ), 
        .tnew_E_i       (tnew           ), 
        .tnew_E_o       (tnew_E_o       ), 
        .instr_code_E_i (instr_code     ), 
        .instr_code_E_o (instr_code_E_o ), 
        .cp0_write_E_i  (cp0_write      ), 
        .cp0_write_E_o  (cp0_write_E_o  ), 
        .cp0_addr_E_i   (cp0_addr       ), 
        .cp0_addr_E_o   (cp0_addr_E_o   ), 
        .cp0_sel_E_i    (cp0_sel        ),
        .cp0_sel_E_o    (cp0_sel_E_o    ),
        .cache_req_E_i  (cache_req      ),
        .cache_req_E_o  (cache_req_E_o  ),
        .cache_op_E_i   (cache_op       ),
        .cache_op_E_o   (cache_op_E_o   ),
        .eret_E_i       (eret           ), 
        .eret_E_o       (eret_E_o       ), 
        .mtc0_E_i       (mtc0           ), 
        .mtc0_E_o       (mtc0_E_o       ), 
        .bd_E_i         (bd_D_o         ), 
        .bd_E_o         (bd_E_o         ), 
        .pc8_E_i        (pc8_D_o        ), 
        .pc8_E_o        (pc8_E_o        ), 
        .pc_E_i         (pc_D_o         ), 
        .pc_E_o         (pc_E_o         ), 
        .rd1_E_i        (rd1mfd_o       ), 
        .rd1_E_o        (rd1_E_o        ), 
        .rd2_E_i        (rd2mfd_o       ), 
        .rd2_E_o        (rd2_E_o        ), 
        .ext32_E_i      (ext_out        ), 
        .ext32_E_o      (ext32_E_o      ), 
        .shamt_E_i      (instr_D_o[10:6]), 
        .shamt_E_o      (shamt_E_o      ),
        .exccode_E_i    (exccode_E_i    ),
        .exccode_E_o    (exccode_E_o    )
    );

    
    MUX8 rd1mfe_ (
        .sel(rd1mfe_sel      ), 
        .in0(rd1_E_o        ), 
        .in1(grfwdm_o       ), 
        .in2(alu_result_M_o ), 
        .in3(md_result_M_o  ), 
        .in4(pc8_M_o        ), 
        .in5(), 
        .in6(), 
        .in7(), 
        .out(rd1mfe_o       )
    );

    
    MUX8 rd2mfe_ (
    .sel(rd2mfe_sel     ), 
    .in0(rd2_E_o        ), 
    .in1(grfwdm_o       ), 
    .in2(alu_result_M_o ), 
    .in3(md_result_M_o  ), 
    .in4(pc8_M_o        ), 
    .in5(), 
    .in6(), 
    .in7(), 
    .out(rd2mfe_o       )
    );

    
    MUX2 srcbm_ (
    .sel(srcbm_sel_E_o  ), 
    .in0(rd2mfe_o       ), 
    .in1(ext32_E_o      ), 
    .out(srcbm_o        )
    );


    
    alu alu_ (
        .srca       (rd1mfe_o       ), 
        .srcb       (srcbm_o        ), 
        .shamt      (shamt_E_o      ), 
        .alu_op     (alu_op_E_o     ), 
        .alu_result (alu_result     ), 
        .overflow   (overflow       )
    );


    
    md md_ (
    .clk        (clk        ), 
    .reset      (reset      ), 
    .start      (start_E_o  ), 
    .md_op      (md_op_E_o  ), 
    .srca       (rd1mfe_o   ), 
    .srcb       (srcbm_o    ), 
    .int_req    (req|has_ext_E),
    .busy       (busy       ), 
    .hi         (hi         ), 
    .lo         (lo         )
    );

    
    MUX2 mdm_ (
    .sel(mdm_sel_E_o    ), 
    .in0(hi             ), 
    .in1(lo             ), 
    .out(mdm_o          )
    );

    assign load_req = instr_code_E_o[32] | instr_code_E_o[33] | instr_code_E_o[34] |
                    instr_code_E_o[35] | instr_code_E_o[36];

    assign store_req = instr_code_E_o[29] | instr_code_E_o[30] | instr_code_E_o[31];

    reg [1:0] ls_state;                 //当前M级访存属性，2'b00:无访存请求 2'b01:读请求 2'b10:写请求
    always @(posedge clk) begin //2
        if(reset|req)begin
            ls_state <= 2'b00;
        end else if(M_allow_in==1'b1&&E_to_M_valid==1'b1)begin
            if(load_req==1'b1)
                ls_state <= 2'b01;
            else if(store_req==1'b1)
                ls_state <= 2'b10;
            else
                ls_state <= 2'b00;    
        end else if(M_allow_in==1'b1&&E_to_M_valid==1'b0)begin
            ls_state <= 2'b00;
        end
    end


    be be_ (
    .be_op          (be_op_E_o      ), 
    .p_data_addr    (alu_result     ), 
    .p_data_wdata   (rd2mfe_o       ), 
    .int_req        (req|has_ext_E  ),
    .m_data_byteen  (m_data_byteen  ),  //output
    .m_data_addr    (m_data_addr    ),  //output
    .m_data_wdata   (m_data_wdata   )   //output
    );


    //------------------M stage----------------------
    
    assign exccode_M_i = (exccode_E_o==0) ? exc_E : exccode_E_o;
    
    M_reg M_reg_ (
    .clk            (clk            ), 
    .reset          (reset          ), 
    .M_allow_in     (M_allow_in     ),
    .M_to_W_valid   (M_to_W_valid   ),
    .W_allow_in     (W_allow_in     ),
    .E_to_M_valid   (E_to_M_valid   ),
    .ls_state       (ls_state       ),    
    .data_rvalid    (data_rvalid    ),
    .data_bvalid    (data_bvalid    ),
    .req            (req            ), 
    .stall          (stall          ), 
    .dmext_op_M_i   (dmext_op_E_o   ), 
    .dmext_op_M_o   (dmext_op_M_o   ), 
    .grfwdm_sel_M_i (grfwdm_sel_E_o ), 
    .grfwdm_sel_M_o (grfwdm_sel_M_o ), 
    .regwrite_M_i   (regwrite_E_o   ), 
    .regwrite_M_o   (regwrite_M_o   ), 
    .a1_M_i         (a1_E_o         ), 
    .a1_M_o         (a1_M_o         ), 
    .a2_M_i         (a2_E_o         ), 
    .a2_M_o         (a2_M_o         ), 
    .a3_M_i         (a3_E_o         ), 
    .a3_M_o         (a3_M_o         ), 
    .tnew_M_i       (tnew_E_o       ), 
    .tnew_M_o       (tnew_M_o       ), 
    .cp0_write_M_i  (cp0_write_E_o  ), 
    .cp0_write_M_o  (cp0_write_M_o  ), 
    .cp0_addr_M_i   (cp0_addr_E_o   ), 
    .cp0_addr_M_o   (cp0_addr_M_o   ), 
    .cp0_sel_M_i    (cp0_sel_E_o    ),
    .cp0_sel_M_o    (cp0_sel_M_o    ),
    .cache_req_M_i  (cache_req_E_o  ),
    .cache_req_M_o  (cache_req_M_o  ),
    .cache_op_M_i   (cache_op_E_o   ),
    .cache_op_M_o   (cache_op_M_o   ),
    .eret_M_i       (eret_E_o       ), 
    .eret_M_o       (eret_M_o       ), 
    .mtc0_M_i       (mtc0_E_o       ), 
    .mtc0_M_o       (mtc0_M_o       ), 
    .bd_M_i         (bd_E_o         ), 
    .bd_M_o         (bd_M_o         ), 
    .pc8_M_i        (pc8_E_o        ), 
    .pc8_M_o        (pc8_M_o        ), 
    .pc_M_i         (pc_E_o         ), 
    .pc_M_o         (pc_M_o         ), 
    .rd2_M_i        (rd2mfe_o       ), 
    .rd2_M_o        (rd2_M_o        ), 
    .alu_result_M_i (alu_result     ), 
    .alu_result_M_o (alu_result_M_o ), 
    .md_result_M_i  (mdm_o          ), 
    .md_result_M_o  (md_result_M_o  ),
    .exccode_M_i    (exccode_M_i    ),
    .exccode_M_o    (exccode_M_o    )
    );

    
    MUX2 rd2mfm_ (
        .sel(rd2mfm_sel ), 
        .in0(rd2_M_o    ), 
        .in1(grfwdm_o   ), 
        .out(rd2mfm_o   )
    );

    
    dmext dmext_ (
    .dmext_op       (dmext_op_M_o   ), 
    .m_data_addr    (alu_result_M_o ), 
    .p_data_rdata   (p_data_rdata   ), 
    .m_data_rdata   (m_data_rdata   )
    );

    
    ep ep_ (
    .pc_F           (pc_o           ), 
    .instr_code_D   (instr_code     ), 
    .instr_code_E   (instr_code_E_o ), 
    .alu_result_E   (alu_result     ), 
    .overflow_E     (overflow       ), 
    .exc_F          (exc_F          ),
    .exc_D          (exc_D          ),
    .exc_E          (exc_E          )
    );

    
    cp0 cp0_ (
    .clk            (clk            ), 
    .reset          (reset          ), 
    .en             (cp0_write_M_o  ), 
    .addr           (cp0_addr_M_o   ),
    .cp0_sel        (cp0_sel_M_o    ), 
    .wdata          (rd2mfm_o       ), 
    .pc_M           (pc_M_o         ), 
    .alu_result_M   (alu_result_M_o ), 
    .ExcCode        (exccode_M_o    ), 
    .HWInt          (ext_int        ), 
    .EXLClr         (eret_M_o       ), 
    .bd             (bd_M_o         ), 
    .req            (req            ), 
    .epc            (epc            ), 
    .rdata          (cp0rdata       )
    );


    //----------------------W stage-----------------------
    
    assign R_allow_in = 1'b1;
    W_reg W_reg_ (
    .clk            (clk            ), 
    .reset          (reset          ),
    .W_allow_in     (W_allow_in     ),
    .W_to_R_valid   (W_to_R_valid   ),
    .R_allow_in     (R_allow_in     ),
    .M_to_W_valid   (M_to_W_valid   ),
    .req            (req            ), 
    .stall          (stall          ), 
    .grfwdm_sel_W_i (grfwdm_sel_M_o ), 
    .grfwdm_sel_W_o (grfwdm_sel_W_o ), 
    .regwrite_W_i   (regwrite_M_o   ), 
    .regwrite_W_o   (regwrite_W_o   ), 
    .a1_W_i         (a1_M_o         ), 
    .a1_W_o         (a1_W_o         ), 
    .a2_W_i         (a2_M_o         ), 
    .a2_W_o         (a2_W_o         ), 
    .a3_W_i         (a3_M_o         ), 
    .a3_W_o         (a3_W_o         ), 
    .pc8_W_i        (pc8_M_o        ), 
    .pc8_W_o        (pc8_W_o        ), 
    .pc_W_i         (pc_M_o         ), 
    .pc_W_o         (pc_W_o         ), 
    .alu_result_W_i (alu_result_M_o ), 
    .alu_result_W_o (alu_result_W_o ), 
    .md_result_W_i  (md_result_M_o  ), 
    .md_result_W_o  (md_result_W_o  ), 
    .m_data_rdata_W_i(m_data_rdata  ), 
    .m_data_rdata_W_o(m_data_rdata_W_o), 
    .cp0_out_W_i        (cp0rdata   ), 
    .cp0_out_W_o        (cp0_out_W_o)
    );

   
    MUX8 grfwdm_ (
    .sel(grfwdm_sel_W_o), 
    .in0(alu_result_W_o), 
    .in1(md_result_W_o), 
    .in2(m_data_rdata_W_o), 
    .in3(pc8_W_o), 
    .in4(cp0_out_W_o), 
    .in5(), 
    .in6(), 
    .in7(), 
    .out(grfwdm_o)
    );


    
    
endmodule