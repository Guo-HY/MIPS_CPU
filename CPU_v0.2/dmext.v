module dmext (
    input wire[2:0] dmext_op,
    input wire[31:0] m_data_addr,
    input wire[31:0] p_data_rdata,
    output wire[31:0] m_data_rdata
);
    //dmext_op-------------
    // 000：无扩展
    // 001：无符号字节数据扩展
    // 010：符号字节数据扩展
    // 011：无符号半字数据扩展
    // 100：符号半字数据扩展
    //---------------------

    reg [31:0] r_m_data_rdata;
    
    assign m_data_rdata = r_m_data_rdata;

    always @(*) begin
        case (dmext_op)
            3'b000: r_m_data_rdata = p_data_rdata;
            3'b001: begin
                if(m_data_addr[1:0]==2'b00) r_m_data_rdata = {24'b0,p_data_rdata[7:0]};
                else if(m_data_addr[1:0]==2'b01) r_m_data_rdata = {24'b0,p_data_rdata[15:8]};
                else if(m_data_addr[1:0]==2'b10) r_m_data_rdata = {24'b0,p_data_rdata[23:16]};
                else r_m_data_rdata = {24'b0,p_data_rdata[31:24]};
            end
            3'b010: begin
                if(m_data_addr[1:0]==2'b00) r_m_data_rdata = {{24{p_data_rdata[7]}},p_data_rdata[7:0]};
                else if(m_data_addr[1:0]==2'b01) r_m_data_rdata = {{24{p_data_rdata[15]}},p_data_rdata[15:8]};
                else if(m_data_addr[1:0]==2'b10) r_m_data_rdata = {{24{p_data_rdata[23]}},p_data_rdata[23:16]};
                else r_m_data_rdata = {{24{p_data_rdata[31]}},p_data_rdata[31:24]};
            end
            3'b011: begin
                if(m_data_addr[1]==1'b0) r_m_data_rdata = {16'b0,p_data_rdata[15:0]};
                else r_m_data_rdata = {16'b0,p_data_rdata[31:16]};
            end
            3'b100: begin
                if(m_data_addr[1]==1'b0) r_m_data_rdata = {{16{p_data_rdata[15]}},p_data_rdata[15:0]};
                else r_m_data_rdata = {{16{p_data_rdata[31]}},p_data_rdata[31:16]};
            end
            default: r_m_data_rdata = 32'h1234abcd;
        endcase
    end
    
endmodule