`timescale 1ns / 1ps
`default_nettype none
module leopard_rtl
   (input wire aclk,
    input wire aclk4,
    input wire aresetn,
    input wire [11:0] wdata,
    output wire hsync,
    output wire vsync,
    output wire [11:0] scaled_x,
    output wire [11:0] scaled_y,
    output wire [3:0] datar,
    output wire [3:0] datag,
    output wire [3:0] datab,
    output wire [1:0] blank);
    wire [11:0] rdata0;
    wire [11:0] rdata1;
    wire [11:0] x;
    wire [11:0] y;
    wire select;
    wire hblank;
    wire vblank;
    vgainterval interval(
        .aclk(aclk),
        .aresetn(aresetn),
        .hsync(hsync),
        .vsync(vsync),
        .hblank(hblank),
        .vblank(vblank),
        .x(x),
        .y(y),
        .select(select)
    );
    
    vgabuffer b0(
        .aclk4(aclk4),
        .aresetn(aresetn),
        .x(scaled_x),
        .y(scaled_y),
        .wdata(wdata),
        .select(~hblank & ~vblank),
        .wen(select),
        .rdata(rdata0)
    );
        
    vgabuffer b1(
        .aclk4(aclk4),
        .aresetn(aresetn),
        .x(scaled_x),
        .y(scaled_y),
        .wdata(wdata),
        .select(~hblank & ~vblank),
        .wen(~select),
        .rdata(rdata1)
    );
    
    assign scaled_x[11] = 1'b0;
    assign scaled_x[10:0] = x[11:1];
    assign scaled_y[11] = 1'b0;
    assign scaled_y[10:0] = y[11:1];
    assign datar = (select ? rdata1[3:0] : rdata0[3:0]);
    assign datag = (select ? rdata1[7:4] : rdata0[7:4]);
    assign datab = (select ? rdata1[11:8] : rdata0[11:8]);
    assign blank[0] = hblank;
    assign blank[1] = vblank;
endmodule
