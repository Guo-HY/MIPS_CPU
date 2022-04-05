`include "cpu_def.vh"
module D_reg (
    input wire clk,
    input wire reset,
    output wire D_allow_in,
    output wire D_to_E_valid,
    input wire E_allow_in,
    input wire F_to_D_valid,
    input wire req,
    input wire stall,
    input wire eret,
    input wire bd_D_i,
    output wire bd_D_o,
    input wire [31:0] instr_D_i,
    output wire [31:0] instr_D_o,
    input wire [31:0] pc8_D_i,
    output wire [31:0] pc8_D_o,
    input wire [31:0] pc_D_i,
    output wire [31:0] pc_D_o,
    input wire [4:0] exccode_D_i,
    output wire [4:0] exccode_D_o
);
    reg [31:0] instr_D,pc8_D,pc_D;
    reg bd_D;
    reg [4:0] exccode_D;

    reg     D_valid;
    wire    D_ready_go   = ~stall;   
    assign  D_allow_in   = !D_valid || D_ready_go && E_allow_in;
    assign  D_to_E_valid = D_valid && D_ready_go;

    reg r_eret;

    always @(posedge clk) begin
        if(reset|req) begin
            D_valid <= 0;
            r_eret <= 0;
        end else if(D_allow_in) begin
            if(eret|r_eret)begin
                D_valid <= 0;
            end else begin
                D_valid <= F_to_D_valid;
            end
            if(eret&~F_to_D_valid)begin
                r_eret <= 1'b1;
            end else if(r_eret&F_to_D_valid)begin
                r_eret <= 1'b0;
            end
            instr_D <= instr_D_i;
            pc8_D <= pc8_D_i;
            pc_D <= pc_D_i;
            exccode_D <= exccode_D_i;
        end
    end

    reg [1:0] bd_state;
    parameter IDLE  = 2'b00;
    parameter SLOT1 = 2'b01;
    parameter SLOT2 = 2'b10;
    always @(posedge clk) begin
        if(reset|req)   bd_state <= IDLE;
        else begin
            case (bd_state)
                IDLE:   if(D_allow_in&bd_D_i&~F_to_D_valid)     bd_state <= SLOT1;//下一拍pc是延迟槽的，但是延迟槽指令还没到位
                        else if(D_allow_in&bd_D_i&F_to_D_valid) bd_state <= SLOT2;//转移指令从D级离开的下一拍就是有效的延迟槽指令

                SLOT1:  if(D_allow_in&F_to_D_valid)         bd_state <= SLOT2;//延迟槽指令到D级了

                SLOT2:  if(D_allow_in)                      bd_state <= IDLE; //当前D级为延迟槽指令并且要离开了

                default: bd_state <= 2'b11;
            endcase
        end
    end

    assign bd_D_o       = (bd_state==SLOT1)||(bd_state==SLOT2);
    assign instr_D_o    = instr_D   & {32{D_valid}};
    assign pc8_D_o      = pc8_D;
    assign pc_D_o       = pc_D;
    assign exccode_D_o  = exccode_D & {5{D_valid}}; 

endmodule

module E_reg (
    input wire clk,
    input wire reset,
    output wire E_allow_in,
    output wire E_to_M_valid,
    input wire M_allow_in,
    input wire D_to_E_valid,
    input wire req,
    input wire stall,
    input wire[4:0] alu_op_E_i,
    output wire[4:0] alu_op_E_o,
    input wire[2:0] md_op_E_i,
    output wire[2:0] md_op_E_o,
    input wire start_E_i,
    output wire start_E_o,
    input wire srcbm_sel_E_i,
    output wire srcbm_sel_E_o,
    input wire mdm_sel_E_i,
    output wire mdm_sel_E_o,
    input wire [1:0] be_op_E_i,
    output wire [1:0] be_op_E_o,
    input wire data_addr_valid,
    input wire data_addr_ready,
    input wire store_req,
    input wire load_req,
    input wire [2:0] dmext_op_E_i,
    output wire [2:0] dmext_op_E_o,
    input wire [2:0] grfwdm_sel_E_i,
    output wire [2:0] grfwdm_sel_E_o,
    input wire regwrite_E_i,
    output wire regwrite_E_o,
    input wire [4:0] a1_E_i,
    output wire [4:0] a1_E_o,
    input wire [4:0] a2_E_i,
    output wire [4:0] a2_E_o,
    input wire [4:0] a3_E_i,
    output wire [4:0] a3_E_o,
    input wire [1:0] tnew_E_i,
    output wire [1:0] tnew_E_o,
    input wire [`INSTR_CODE_WIDTH-1:0] instr_code_E_i,
    output wire [`INSTR_CODE_WIDTH-1:0] instr_code_E_o,
    input wire cp0_write_E_i,
    output wire cp0_write_E_o,
    input wire [4:0] cp0_addr_E_i,
    output wire [4:0] cp0_addr_E_o,
    input wire [2:0] cp0_sel_E_i,
    output wire [2:0] cp0_sel_E_o,
    input wire cache_req_E_i,
    output wire cache_req_E_o,
    input wire [4:0] cache_op_E_i,
    output wire [4:0] cache_op_E_o,
    input wire eret_E_i,
    output wire eret_E_o,
    input wire mtc0_E_i,
    output wire mtc0_E_o,
    input wire bd_E_i,
    output wire bd_E_o,
    input wire [31:0] pc8_E_i,
    output wire [31:0] pc8_E_o,
    input wire [31:0] pc_E_i,
    output wire [31:0] pc_E_o,
    input wire [31:0] rd1_E_i,
    output wire [31:0] rd1_E_o,
    input wire [31:0] rd2_E_i,
    output wire [31:0] rd2_E_o,
    input wire [31:0] ext32_E_i,
    output wire [31:0] ext32_E_o,
    input wire [4:0] shamt_E_i,
    output wire [4:0] shamt_E_o,
    input wire [4:0] exccode_E_i,
    output wire [4:0] exccode_E_o
);
    reg [4:0] alu_op_E,a1_E,a2_E,a3_E,cp0_addr_E,shamt_E,exccode_E,cache_op_E;
    reg [2:0] md_op_E,dmext_op_E,grfwdm_sel_E,cp0_sel_E;
    reg start_E,srcbm_sel_E,mdm_sel_E,regwrite_E,cp0_write_E,eret_E,mtc0_E,bd_E,cache_req_E;
    reg [1:0] be_op_E,tnew_E;
    reg [`INSTR_CODE_WIDTH-1:0] instr_code_E;
    reg [31:0] pc8_E,pc_E,rd1_E,rd2_E,ext32_E;

    reg     E_valid;
    wire    E_ready_go      = (store_req==1'b0&&load_req==1'b0) || (data_addr_valid&&data_addr_ready);
    assign  E_allow_in      = !E_valid || E_ready_go && M_allow_in;
    assign  E_to_M_valid    = E_valid && E_ready_go;

    always @(posedge clk)begin
        if(reset|req)
            E_valid <= 0;
        else if(E_allow_in)begin
            E_valid <= D_to_E_valid;
            bd_E <= bd_E_i;
            pc_E <= pc_E_i;
            alu_op_E <= alu_op_E_i;
            md_op_E <= md_op_E_i;
            start_E <= start_E_i;
            srcbm_sel_E <= srcbm_sel_E_i;
            mdm_sel_E <= mdm_sel_E_i;
            be_op_E <= be_op_E_i;
            dmext_op_E <= dmext_op_E_i;
            grfwdm_sel_E <= grfwdm_sel_E_i;
            regwrite_E <= regwrite_E_i;
            a1_E <= a1_E_i;
            a2_E <= a2_E_i;
            a3_E <= a3_E_i;
            tnew_E <= tnew_E_i;
            instr_code_E <= instr_code_E_i;
            cp0_write_E <= cp0_write_E_i;
            cp0_addr_E <= cp0_addr_E_i;
            cp0_sel_E <= cp0_sel_E_i;
            cache_req_E <= cache_req_E_i;
            cache_op_E <= cache_op_E_i;
            eret_E <= eret_E_i;
            mtc0_E <= mtc0_E_i;
            pc8_E <= pc8_E_i;
            rd1_E <= rd1_E_i;
            rd2_E <= rd2_E_i;
            ext32_E <= ext32_E_i;
            shamt_E <= shamt_E_i;
            exccode_E <= exccode_E_i;    
        end
    end

    assign alu_op_E_o       = alu_op_E;
    assign md_op_E_o        = md_op_E       & {3{E_valid}};
    assign start_E_o        = start_E       & E_valid;
    assign srcbm_sel_E_o    = srcbm_sel_E;
    assign mdm_sel_E_o      = mdm_sel_E;
    assign be_op_E_o        = be_op_E       & {2{E_valid}};
    assign dmext_op_E_o     = dmext_op_E    & {3{E_valid}};
    assign grfwdm_sel_E_o   = grfwdm_sel_E;
    assign regwrite_E_o     = regwrite_E    & E_valid;
    assign a1_E_o           = a1_E          & {5{E_valid}};
    assign a2_E_o           = a2_E          & {5{E_valid}};
    assign a3_E_o           = a3_E          & {5{E_valid}};
    assign tnew_E_o         = tnew_E        & {2{E_valid}};
    assign instr_code_E_o   = instr_code_E  & {`INSTR_CODE_WIDTH{E_valid}};
    assign cp0_write_E_o    = cp0_write_E   & E_valid;
    assign cp0_addr_E_o     = cp0_addr_E    & {5{E_valid}};
    assign cp0_sel_E_o      = cp0_sel_E;
    assign eret_E_o         = eret_E        & E_valid;
    assign mtc0_E_o         = mtc0_E        & E_valid;
    assign pc8_E_o          = pc8_E;
    assign rd1_E_o          = rd1_E;
    assign rd2_E_o          = rd2_E;
    assign ext32_E_o        = ext32_E;
    assign shamt_E_o        = shamt_E;
    assign bd_E_o           = bd_E;
    assign pc_E_o           = pc_E;
    assign exccode_E_o      = exccode_E     & {5{E_valid}};
    assign cache_req_E_o    = cache_req_E;
    assign cache_op_E_o     = cache_op_E;
    
endmodule

module M_reg (
    input wire clk,
    input wire reset,
    output wire M_allow_in,
    output wire M_to_W_valid,
    input wire W_allow_in,
    input wire E_to_M_valid,
    input wire [1:0] ls_state,
    input wire data_rvalid,
    input wire data_bvalid,
    input wire req,
    input wire stall,
    input wire [2:0] dmext_op_M_i,
    output wire [2:0] dmext_op_M_o,
    input wire [2:0] grfwdm_sel_M_i,
    output wire [2:0] grfwdm_sel_M_o,
    input wire regwrite_M_i,
    output wire regwrite_M_o,
    input wire [4:0] a1_M_i,
    output wire [4:0] a1_M_o,
    input wire [4:0] a2_M_i,
    output wire [4:0] a2_M_o,
    input wire [4:0] a3_M_i,
    output wire [4:0] a3_M_o,
    input wire [1:0] tnew_M_i,
    output wire [1:0] tnew_M_o,
    input wire cp0_write_M_i,
    output wire cp0_write_M_o,
    input wire [4:0] cp0_addr_M_i,
    output wire [4:0] cp0_addr_M_o,
    input wire [2:0] cp0_sel_M_i,
    output wire [2:0] cp0_sel_M_o,
    input wire cache_req_M_i,
    output wire cache_req_M_o,
    input wire [4:0] cache_op_M_i,
    output wire [4:0] cache_op_M_o,
    input wire eret_M_i,
    output wire eret_M_o,
    input wire mtc0_M_i,
    output wire mtc0_M_o,
    input wire bd_M_i,
    output wire bd_M_o,
    input wire [31:0] pc8_M_i,
    output wire [31:0] pc8_M_o,
    input wire [31:0] pc_M_i,
    output wire [31:0] pc_M_o,
    input wire [31:0] rd2_M_i,
    output wire [31:0] rd2_M_o,
    input wire [31:0] alu_result_M_i,
    output wire [31:0] alu_result_M_o,
    input wire [31:0] md_result_M_i,
    output wire [31:0] md_result_M_o,
    input wire [4:0] exccode_M_i,
    output wire [4:0] exccode_M_o
);
    reg [2:0] dmext_op_M,grfwdm_sel_M,cp0_sel_M;
    reg regwrite_M,cp0_write_M,eret_M,mtc0_M,bd_M,cache_req_M;
    reg [4:0] a1_M,a2_M,a3_M,cp0_addr_M,exccode_M,cache_op_M;
    reg [1:0] tnew_M;
    reg [31:0] pc8_M,pc_M,rd2_M,alu_result_M,md_result_M;

    reg  M_valid;
    wire M_ready_go = ls_state==2'b00 || (ls_state==2'b01 && data_rvalid==1'b1) || (ls_state==2'b10 && data_bvalid==1'b1);
    assign M_allow_in = !M_valid || M_ready_go && W_allow_in;
    assign M_to_W_valid = M_valid && M_ready_go;

    always @(posedge clk) begin
        if(reset|req)
            M_valid <= 0;
        else if(M_allow_in)begin
            M_valid <= E_to_M_valid;
            dmext_op_M <= dmext_op_M_i;
            grfwdm_sel_M <= grfwdm_sel_M_i;
            regwrite_M <= regwrite_M_i;
            a1_M <= a1_M_i;
            a2_M <= a2_M_i;
            a3_M <= a3_M_i;

            if(tnew_M_i>0)  tnew_M <= tnew_M_i - 1;
            else            tnew_M <= tnew_M_i;
            
            cp0_write_M <= cp0_write_M_i;
            cp0_addr_M <= cp0_addr_M_i;
            cp0_sel_M  <= cp0_sel_M_i;
            cache_req_M <= cache_req_M_i;
            cache_op_M <= cache_op_M_i;
            eret_M <= eret_M_i;
            mtc0_M <= mtc0_M_i;
            bd_M <= bd_M_i;
            pc8_M <= pc8_M_i;
            pc_M <= pc_M_i;
            rd2_M <= rd2_M_i;
            alu_result_M <= alu_result_M_i;
            md_result_M <= md_result_M_i;
            exccode_M <= exccode_M_i;
        end    
    end
    
    assign dmext_op_M_o     = dmext_op_M;
    assign grfwdm_sel_M_o   = grfwdm_sel_M;
    assign regwrite_M_o     = regwrite_M    & M_valid;
    assign a1_M_o           = a1_M          & {5{M_valid}};
    assign a2_M_o           = a2_M          & {5{M_valid}};
    assign a3_M_o           = a3_M          & {5{M_valid}};
    assign tnew_M_o         = tnew_M        & {2{M_valid}};
    assign cp0_write_M_o    = cp0_write_M   & M_valid;
    assign cp0_addr_M_o     = cp0_addr_M    & {5{M_valid}};
    assign cp0_sel_M_o      = cp0_sel_M;
    assign eret_M_o         = eret_M        & M_valid;
    assign mtc0_M_o         = mtc0_M        & M_valid;
    assign bd_M_o           = bd_M;
    assign pc8_M_o          = pc8_M;
    assign pc_M_o           = pc_M;
    assign rd2_M_o          = rd2_M;
    assign alu_result_M_o   = alu_result_M;
    assign md_result_M_o    = md_result_M;
    assign exccode_M_o      = exccode_M     & {5{M_valid}};
    assign cache_req_M_o    = cache_req_M   & M_valid;
    assign cache_op_M_o     = cache_op_M;

endmodule

module W_reg (
    input wire clk,
    input wire reset,
    output wire W_allow_in,
    output wire W_to_R_valid,
    input wire R_allow_in,
    input wire M_to_W_valid,
    input wire req,
    input wire stall,
    input wire [2:0] grfwdm_sel_W_i,
    output wire [2:0] grfwdm_sel_W_o,
    input wire regwrite_W_i,
    output wire regwrite_W_o,
    input wire [4:0] a1_W_i,
    output wire [4:0] a1_W_o,
    input wire [4:0] a2_W_i,
    output wire [4:0] a2_W_o,
    input wire [4:0] a3_W_i,
    output wire [4:0] a3_W_o,
    input wire [31:0] pc8_W_i,
    output wire [31:0] pc8_W_o,
    input wire [31:0] pc_W_i,
    output wire [31:0] pc_W_o,
    input wire [31:0] alu_result_W_i,
    output wire [31:0] alu_result_W_o,
    input wire [31:0] md_result_W_i,
    output wire [31:0] md_result_W_o,
    input wire [31:0] m_data_rdata_W_i,
    output wire [31:0] m_data_rdata_W_o,
    input wire [31:0] cp0_out_W_i,
    output wire [31:0] cp0_out_W_o
);
    reg [2:0] grfwdm_sel_W;
    reg regwrite_W;
    reg [4:0] a1_W,a2_W,a3_W;
    reg [31:0] pc8_W,pc_W,alu_result_W,md_result_W,m_data_rdata_W,cp0_out_W;

    reg     W_valid;
    wire    W_ready_go      = 1'b1;
    assign  W_allow_in      = !W_valid || W_ready_go && R_allow_in;
    assign  W_to_R_valid    = W_valid && W_ready_go;

    always @(posedge clk) begin
        if(reset|req)
            W_valid <= 0;
        else if(W_allow_in)begin
            W_valid <= M_to_W_valid;
            grfwdm_sel_W <= grfwdm_sel_W_i;
            regwrite_W <= regwrite_W_i;
            a1_W <= a1_W_i;
            a2_W <= a2_W_i;
            a3_W <= a3_W_i;
            pc8_W <= pc8_W_i;
            pc_W <= pc_W_i;
            alu_result_W <= alu_result_W_i;
            md_result_W <= md_result_W_i;
            m_data_rdata_W <= m_data_rdata_W_i;
            cp0_out_W <= cp0_out_W_i;
        end
    end

    assign grfwdm_sel_W_o   = grfwdm_sel_W;
    assign regwrite_W_o     = regwrite_W    & W_valid;
    assign a1_W_o           = a1_W          & {5{W_valid}};
    assign a2_W_o           = a2_W          & {5{W_valid}};
    assign a3_W_o           = a3_W          & {5{W_valid}};
    assign pc8_W_o          = pc8_W;
    assign pc_W_o           = pc_W;
    assign alu_result_W_o   = alu_result_W;
    assign md_result_W_o    = md_result_W;
    assign m_data_rdata_W_o = m_data_rdata_W;
    assign cp0_out_W_o      = cp0_out_W;

endmodule