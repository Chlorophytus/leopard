`timescale 1ns / 1ps
`default_nettype none
// Top-level RTL module
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
    wire [11:0] px;
    wire [11:0] py;
    vga_interval interval(
        .aclk(aclk),
        .aresetn(aresetn),
        .hsync(hsync),
        .vsync(vsync),
        .hblank(hblank),
        .vblank(vblank),
        .px(px),
        .py(py)
    );
    assign datar = (px[3:0] ^ py[3:0]);
    assign datag = (px[4:1] ^ py[4:1]);
    assign datab = (px[5:2] ^ py[5:2]);
endmodule
