module BE (
    input wire[1:0] BEOp,
    input wire[31:0] MemA,
    input wire[31:0] MemD,
    input wire IntReq,
    output wire[3:0] m_data_byteen,
    output wire[31:0] m_data_addr,
    output wire[31:0] m_data_wdata
);
    //2'b00:none
    //2'b01:sw
    //2'b10:sh
    //2'b11:sb
    reg [3:0] r_m_data_byteen;
    reg [31:0] r_m_data_wdata;

    always @(*) begin
        if(IntReq) begin 
            r_m_data_byteen = 0;
            r_m_data_wdata = 0;
        end else begin
            case (BEOp)
                2'b01:  begin
                            r_m_data_byteen = 4'b1111;
                            r_m_data_wdata = MemD;
                        end
                2'b10:  if(MemA[1]==1'b0) begin
                            r_m_data_byteen = 4'b0011;
                            r_m_data_wdata = MemD;
                        end else begin 
                            r_m_data_byteen = 4'b1100;
                            r_m_data_wdata = {MemD[15:0],16'b0};
                        end
                2'b11:  if(MemA[1:0]==2'b00) begin
                            r_m_data_byteen = 4'b0001;
                            r_m_data_wdata = MemD;
                        end else if(MemA[1:0]==2'b01) begin 
                            r_m_data_byteen = 4'b0010;
                            r_m_data_wdata = {16'b0,MemD[7:0],8'b0};
                        end else if(MemA[1:0]==2'b10) begin 
                            r_m_data_byteen = 4'b0100;
                            r_m_data_wdata = {8'b0,MemD[7:0],16'b0};
                        end else begin 
                            r_m_data_byteen = 4'b1000;
                            r_m_data_wdata = {MemD[7:0],24'b0};
                        end
                default: begin
                            r_m_data_byteen = 4'b0000;
                            r_m_data_wdata = 0;
                        end   
            endcase
        end
    end

    assign m_data_byteen = r_m_data_byteen;
    assign m_data_addr = MemA;
    assign m_data_wdata = r_m_data_wdata;

endmodule