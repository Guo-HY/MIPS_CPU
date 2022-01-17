`timescale 1ns / 1ps
`define IDLE 2'b00
`define LOAD 2'b01
`define CNT  2'b10
`define INT  2'b11

`define ctrl   mem[0]
`define preset mem[1]
`define count  mem[2] //只读

module TC(
    input wire clk,
    input wire reset,
    input wire [31:2] Addr,
    input wire WE,
    input wire [31:0] Din,
    output wire [31:0] Dout,
    output wire IRQ
    );

	reg [1:0] state;
	reg [31:0] mem [2:0];
	
	reg _IRQ;
	assign IRQ = `ctrl[3] & _IRQ;//允许中断且_IRQ为1
	
	assign Dout = mem[Addr[3:2]];//直接输出地址对应的寄存器
	
	wire [31:0] load = Addr[3:2] == 0 ? {28'h0, Din[3:0]} : Din;//地址为0时代表可能写CTRL，仅取Din低4位，将高位置零
	
	integer i;
	always @(posedge clk) begin
		if(reset) begin				//复位时全部置零
			state <= 0; 
			for(i = 0; i < 3; i = i+1) mem[i] <= 0;
			_IRQ <= 0;
		end
		else if(WE) begin			//如果写使能为1，将load中值赋给对应地址的寄存器
			// $display("%d@: *%h <= %h", $time, {Addr, 2'b00}, load);
			mem[Addr[3:2]] <= load;
		end
		else begin
			case(state)
				`IDLE : if(`ctrl[0]) begin
					state <= `LOAD;
					_IRQ <= 1'b0;
				end
				`LOAD : begin
					`count <= `preset;
					state <= `CNT;
				end
				`CNT  : 
					if(`ctrl[0]) begin
						if(`count > 1) `count <= `count-1;
						else begin
							`count <= 0;
							state <= `INT;
							_IRQ <= 1'b1;
						end
					end
					else state <= `IDLE;
				default : begin
					if(`ctrl[2:1] == 2'b00) `ctrl[0] <= 1'b0;//模式0，计数器倒计时为0后使能自动变为0，此时中断信号持续有效，直到下一次开始计数
					else _IRQ <= 1'b0;
					state <= `IDLE;
				end
			endcase
		end
	end

endmodule
