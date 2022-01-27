`include "cpu_def.vh"
module D_reg (
    input wire clk,
    input wire reset,
    input wire req,
    input wire stall,
    input wire bd_D_i,
    input wire eret,
    output reg bd_D_o,
    input wire [31:0] instr_D_i,
    output reg [31:0] instr_D_o,
    input wire [31:0] pc8_D_i,
    output reg [31:0] pc8_D_o,
    input wire [31:0] pc_D_i,
    output reg [31:0] pc_D_o
);
    // reg [31:0] instr_D,pc8_D,pc_D;
    // reg bd_D;

    always @(posedge clk) begin
        if(reset|req)begin
            instr_D_o <= 0;
            pc8_D_o <= 0;
            pc_D_o <= 0;
            bd_D_o <= 0;
        end else if(stall)begin
            instr_D_o <= instr_D_o;
            pc8_D_o <= pc8_D_o;
            pc_D_o <= pc_D_o;
            bd_D_o <= bd_D_o;
        end else if(eret)begin
            instr_D_o <= 0;
            pc8_D_o <= 0;
            pc_D_o <= pc_D_i;
            bd_D_o <= 0;
        end else begin
            instr_D_o <= instr_D_i;
            pc8_D_o <= pc8_D_i;
            pc_D_o <= pc_D_i;
            bd_D_o <= bd_D_i;
        end
    end

endmodule

module E_reg (
    input wire clk,
    input wire reset,
    input wire req,
    input wire stall,
    input wire[4:0] alu_op_E_i,
    output reg[4:0] alu_op_E_o,
    input wire[2:0] md_op_E_i,
    output reg[2:0] md_op_E_o,
    input wire start_E_i,
    output reg start_E_o,
    input wire srcbm_sel_E_i,
    output reg srcbm_sel_E_o,
    input wire mdm_sel_E_i,
    output reg mdm_sel_E_o,
    input wire [1:0] be_op_E_i,
    output reg [1:0] be_op_E_o,
    input wire [2:0] dmext_op_E_i,
    output reg [2:0] dmext_op_E_o,
    input wire [2:0] grfwdm_sel_E_i,
    output reg [2:0] grfwdm_sel_E_o,
    input wire regwrite_E_i,
    output reg regwrite_E_o,
    input wire [4:0] a1_E_i,
    output reg [4:0] a1_E_o,
    input wire [4:0] a2_E_i,
    output reg [4:0] a2_E_o,
    input wire [4:0] a3_E_i,
    output reg [4:0] a3_E_o,
    input wire [1:0] tnew_E_i,
    output reg [1:0] tnew_E_o,
    input wire [`INSTR_CODE_WIDTH-1:0] instr_code_E_i,
    output reg [`INSTR_CODE_WIDTH-1:0] instr_code_E_o,
    input wire cp0_write_E_i,
    output reg cp0_write_E_o,
    input wire [4:0] cp0_addr_E_i,
    output reg [4:0] cp0_addr_E_o,
    input wire eret_E_i,
    output reg eret_E_o,
    input wire mtc0_E_i,
    output reg mtc0_E_o,
    input wire bd_E_i,
    output reg bd_E_o,
    input wire [31:0] pc8_E_i,
    output reg [31:0] pc8_E_o,
    input wire [31:0] pc_E_i,
    output reg [31:0] pc_E_o,
    input wire [31:0] rd1_E_i,
    output reg [31:0] rd1_E_o,
    input wire [31:0] rd2_E_i,
    output reg [31:0] rd2_E_o,
    input wire [31:0] ext32_E_i,
    output reg [31:0] ext32_E_o,
    input wire [4:0] shamt_E_i,
    output reg [4:0] shamt_E_o
);
    // reg [4:0] alu_op_E,a1_E,a2_E,a3_E,cp0_addr_E,shamt_E;
    // reg [2:0] md_op_E,dmext_op_E,grfwdm_sel_E;
    // reg start_E,srcbm_sel_E,mdm_sel_E,regwrite_E,cp0_write_E,eret_E,mtc0_E,bd_E;
    // reg [1:0] be_op_E,tnew_E;
    // reg [`INSTR_CODE_WIDTH-1:0] instr_code_E;
    // reg [31:0] pc8_E,pc_E,rd1_E,rd2_E,ext32_E;

    always @(posedge clk) begin
        if(reset|req|stall)begin
            alu_op_E_o <= 0;
            md_op_E_o <= 0;
            start_E_o <= 0;
            srcbm_sel_E_o <= 0;
            mdm_sel_E_o <= 0;
            be_op_E_o <= 0;
            dmext_op_E_o <= 0;
            grfwdm_sel_E_o <= 0;
            regwrite_E_o <= 0;
            a1_E_o <= 0;
            a2_E_o <= 0;
            a3_E_o <= 0;
            tnew_E_o <= 0;
            instr_code_E_o <= 0;
            cp0_write_E_o <= 0;
            cp0_addr_E_o <= 0;
            eret_E_o <= 0;
            mtc0_E_o <= 0;
            bd_E_o <= 0;
            pc8_E_o <= 0;
            pc_E_o <= 0;
            rd1_E_o <= 0;
            rd2_E_o <= 0;
            ext32_E_o <= 0;
            shamt_E_o <= 0;
        end else if(stall)begin
            alu_op_E_o <= 0;
            md_op_E_o <= 0;
            start_E_o <= 0;
            srcbm_sel_E_o <= 0;
            mdm_sel_E_o <= 0;
            be_op_E_o <= 0;
            dmext_op_E_o <= 0;
            grfwdm_sel_E_o <= 0;
            regwrite_E_o <= 0;
            a1_E_o <= 0;
            a2_E_o <= 0;
            a3_E_o <= 0;
            tnew_E_o <= 0;
            instr_code_E_o <= 0;
            cp0_write_E_o <= 0;
            cp0_addr_E_o <= 0;
            eret_E_o <= 0;
            mtc0_E_o <= 0;
            bd_E_o <= bd_E_o;
            pc8_E_o <= 0;
            pc_E_o <= pc_E_o;
            rd1_E_o <= 0;
            rd2_E_o <= 0;
            ext32_E_o <= 0;
            shamt_E_o <= 0;
        end else begin
            alu_op_E_o <= alu_op_E_i;
            md_op_E_o <= md_op_E_i;
            start_E_o <= start_E_i;
            srcbm_sel_E_o <= srcbm_sel_E_i;
            mdm_sel_E_o <= mdm_sel_E_i;
            be_op_E_o <= be_op_E_i;
            dmext_op_E_o <= dmext_op_E_i;
            grfwdm_sel_E_o <= grfwdm_sel_E_i;
            regwrite_E_o <= regwrite_E_i;
            a1_E_o <= a1_E_i;
            a2_E_o <= a2_E_i;
            a3_E_o <= a3_E_i;
            tnew_E_o <= tnew_E_i;
            instr_code_E_o <= instr_code_E_i;
            cp0_write_E_o <= cp0_write_E_i;
            cp0_addr_E_o <= cp0_addr_E_i;
            eret_E_o <= eret_E_i;
            mtc0_E_o <= mtc0_E_i;
            bd_E_o <= bd_E_i;
            pc8_E_o <= pc8_E_i;
            pc_E_o <= pc_E_i;
            rd1_E_o <= rd1_E_i;
            rd2_E_o <= rd2_E_i;
            ext32_E_o <= ext32_E_i;
            shamt_E_o <= shamt_E_i;
        end
    end
endmodule

module M_reg (
    input wire clk,
    input wire reset,
    input wire req,
    input wire stall,
    input wire [2:0] dmext_op_M_i,
    output reg [2:0] dmext_op_M_o,
    input wire [2:0] grfwdm_sel_M_i,
    output reg [2:0] grfwdm_sel_M_o,
    input wire regwrite_M_i,
    output reg regwrite_M_o,
    input wire [4:0] a1_M_i,
    output reg [4:0] a1_M_o,
    input wire [4:0] a2_M_i,
    output reg [4:0] a2_M_o,
    input wire [4:0] a3_M_i,
    output reg [4:0] a3_M_o,
    input wire [1:0] tnew_M_i,
    output reg [1:0] tnew_M_o,
    input wire cp0_write_M_i,
    output reg cp0_write_M_o,
    input wire [4:0] cp0_addr_M_i,
    output reg [4:0] cp0_addr_M_o,
    input wire eret_M_i,
    output reg eret_M_o,
    input wire mtc0_M_i,
    output reg mtc0_M_o,
    input wire bd_M_i,
    output reg bd_M_o,
    input wire [31:0] pc8_M_i,
    output reg [31:0] pc8_M_o,
    input wire [31:0] pc_M_i,
    output reg [31:0] pc_M_o,
    input wire [31:0] rd2_M_i,
    output reg [31:0] rd2_M_o,
    input wire [31:0] alu_result_M_i,
    output reg [31:0] alu_result_M_o,
    input wire [31:0] md_result_M_i,
    output reg [31:0] md_result_M_o
);
    always @(posedge clk) begin
        if(reset|req)begin
            dmext_op_M_o <= 0;
            grfwdm_sel_M_o <= 0;
            regwrite_M_o <= 0;
            a1_M_o <= 0;
            a2_M_o <= 0;
            a3_M_o <= 0;
            tnew_M_o <= 0;
            cp0_write_M_o <= 0;
            cp0_addr_M_o <= 0;
            eret_M_o <= 0;
            mtc0_M_o <= 0;
            bd_M_o <= 0;
            pc8_M_o <= 0;
            pc_M_o <= 0;
            rd2_M_o <= 0;
            alu_result_M_o <= 0;
            md_result_M_o <= 0;
        end else begin
            dmext_op_M_o <= dmext_op_M_i;
            grfwdm_sel_M_o <= grfwdm_sel_M_i;
            regwrite_M_o <= regwrite_M_i;
            a1_M_o <= a1_M_i;
            a2_M_o <= a2_M_i;
            a3_M_o <= a3_M_i;

            if(tnew_M_i>0)  tnew_M_o <= tnew_M_i - 1;
            else            tnew_M_o <= tnew_M_i;
            
            cp0_write_M_o <= cp0_write_M_i;
            cp0_addr_M_o <= cp0_addr_M_i;
            eret_M_o <= eret_M_i;
            mtc0_M_o <= mtc0_M_i;
            bd_M_o <= bd_M_i;
            pc8_M_o <= pc8_M_i;
            pc_M_o <= pc_M_i;
            rd2_M_o <= rd2_M_i;
            alu_result_M_o <= alu_result_M_i;
            md_result_M_o <= md_result_M_i;
        end
    end
endmodule

module W_reg (
    input wire clk,
    input wire reset,
    input wire req,
    input wire stall,
    input wire [2:0] grfwdm_sel_W_i,
    output reg [2:0] grfwdm_sel_W_o,
    input wire regwrite_W_i,
    output reg regwrite_W_o,
    input wire [4:0] a1_W_i,
    output reg [4:0] a1_W_o,
    input wire [4:0] a2_W_i,
    output reg [4:0] a2_W_o,
    input wire [4:0] a3_W_i,
    output reg [4:0] a3_W_o,
    input wire [31:0] pc8_W_i,
    output reg [31:0] pc8_W_o,
    input wire [31:0] pc_W_i,
    output reg [31:0] pc_W_o,
    input wire [31:0] alu_result_W_i,
    output reg [31:0] alu_result_W_o,
    input wire [31:0] md_result_W_i,
    output reg [31:0] md_result_W_o,
    input wire [31:0] m_data_rdata_W_i,
    output reg [31:0] m_data_rdata_W_o,
    input wire [31:0] cp0_out_W_i,
    output reg [31:0] cp0_out_W_o
);

    always @(posedge clk) begin
        if(reset|req)begin
            grfwdm_sel_W_o <= 0;
            regwrite_W_o <= 0;
            a1_W_o <= 0;
            a2_W_o <= 0;
            a3_W_o <= 0;
            pc8_W_o <= 0;
            pc_W_o <= 0;
            alu_result_W_o <= 0;
            md_result_W_o <= 0;
            m_data_rdata_W_o <= 0;
            cp0_out_W_o <= 0;
        end else begin
            grfwdm_sel_W_o <= grfwdm_sel_W_i;
            regwrite_W_o <= regwrite_W_i;
            a1_W_o <= a1_W_i;
            a2_W_o <= a2_W_i;
            a3_W_o <= a3_W_i;
            pc8_W_o <= pc8_W_i;
            pc_W_o <= pc_W_i;
            alu_result_W_o <= alu_result_W_i;
            md_result_W_o <= md_result_W_i;
            m_data_rdata_W_o <= m_data_rdata_W_i;
            cp0_out_W_o <= cp0_out_W_i;
        end
    end

endmodule