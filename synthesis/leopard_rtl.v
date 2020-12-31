`timescale 1ns / 1ps
`default_nettype none
module leopard_rtl
   (input wire aclk,
    input wire aresetn,
    output wire hsync,
    output wire vsync,
    output wire hblank,
    output wire vblank,
    output wire [3:0] datar,
    output wire [3:0] datag,
    output wire [3:0] datab);
    wire [11:0] x;
    wire [11:0] y;
    vgainterval interval(
        .aclk(aclk),
        .aresetn(aresetn),
        .hsync(hsync),
        .vsync(vsync),
        .hblank(hblank),
        .vblank(vblank),
        .x(x),
        .y(y)
    );
    assign datar = (x[3:0] ^ y[3:0]);
    assign datag = (x[4:1] ^ y[4:1]);
    assign datab = (x[5:2] ^ y[5:2]);
endmodule
