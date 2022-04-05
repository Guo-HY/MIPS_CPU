module forward_controller (
    input wire[4:0] a1,
    input wire[4:0] a1_E,
    input wire[4:0] a2,
    input wire[4:0] a2_E,
    input wire[4:0] a2_M,
    input wire[4:0] a3_E,
    input wire[4:0] a3_M,
    input wire[4:0] a3_W,
    input wire[1:0] tnew_E,
    input wire[1:0] tnew_M,
    input wire regwrite_E,
    input wire regwrite_M,
    input wire regwrite_W,
    input wire[2:0] grfwdm_sel_M,
    output wire [2:0]rd1mfd_sel,
    output wire [2:0]rd2mfd_sel,
    output wire [2:0]rd1mfe_sel,
    output wire [2:0]rd2mfe_sel,
    output wire rd2mfm_sel
);
    //转发控制----------------------------------------------
    reg [2:0] r_rd1mfd_sel,r_rd2mfd_sel,r_rd1mfe_sel,r_rd2mfe_sel;
    reg r_rd2mfm_sel;
    always @(*) begin//rd1mfd_sel
        if(a1!=5'b0&&a1==a3_E&&tnew_E==2'b0&&regwrite_E==1'b1) r_rd1mfd_sel = 3'b100;
        else if(a1!=5'b0&&a1==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b011) r_rd1mfd_sel = 3'b011;
        else if(a1!=5'b0&&a1==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b001) r_rd1mfd_sel = 3'b010;
        else if(a1!=5'b0&&a1==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b000) r_rd1mfd_sel = 3'b001;//可以简化
        else r_rd1mfd_sel = 3'b000;
    end
    always @(*) begin//rd2mfd_sel
        if(a2!=5'b0&&a2==a3_E&&tnew_E==2'b0&&regwrite_E==1'b1) r_rd2mfd_sel = 3'b100;
        else if(a2!=5'b0&&a2==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b011) r_rd2mfd_sel = 3'b011;
        else if(a2!=5'b0&&a2==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b001) r_rd2mfd_sel = 3'b010;
        else if(a2!=5'b0&&a2==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b000) r_rd2mfd_sel = 3'b001;
        else r_rd2mfd_sel = 3'b000;
    end
    always @(*) begin//rd1mfe_sel
        if(a1_E!=5'b0&&a1_E==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b011)  r_rd1mfe_sel = 3'b100;
        else if(a1_E!=5'b0&&a1_E==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b001) r_rd1mfe_sel = 3'b011;
        else if(a1_E!=5'b0&&a1_E==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b000) r_rd1mfe_sel = 3'b010;
        else if(a1_E!=5'b0&&a1_E==a3_W&&regwrite_W==1'b1) r_rd1mfe_sel = 3'b001;
        else r_rd1mfe_sel = 3'b000;
    end
    always @(*) begin//rd2mfe_sel
        if(a2_E!=5'b0&&a2_E==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b011)  r_rd2mfe_sel = 3'b100;
        else if(a2_E!=5'b0&&a2_E==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b001) r_rd2mfe_sel = 3'b011;
        else if(a2_E!=5'b0&&a2_E==a3_M&&tnew_M==2'b0&&regwrite_M==1'b1&&grfwdm_sel_M==3'b000) r_rd2mfe_sel = 3'b010;
        else if(a2_E!=5'b0&&a2_E==a3_W&&regwrite_W==1'b1) r_rd2mfe_sel = 3'b001;
        else r_rd2mfe_sel = 3'b000;
    end
    always @(*) begin//rd2mfm_sel
        if(a2_M!=5'b0&&a2_M==a3_W&&regwrite_W==1'b1) r_rd2mfm_sel = 1'b1;
        else r_rd2mfm_sel = 1'b0;
    end
    assign rd1mfd_sel = r_rd1mfd_sel;
    assign rd2mfd_sel = r_rd2mfd_sel;
    assign rd1mfe_sel = r_rd1mfe_sel;
    assign rd2mfe_sel = r_rd2mfe_sel;
    assign rd2mfm_sel = r_rd2mfm_sel;

endmodule