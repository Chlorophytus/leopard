`timescale 1ns / 1ps
`default_nettype none
module vgainterval_sim;
    logic aclk;
    logic aresetn;
    
    logic hsync;
    logic vsync;
    logic hblank;
    logic vblank;
    logic select;

    logic unsigned [11:0] x;
    logic unsigned [11:0] y;
    
    vgainterval dut(.*);
    
    initial begin
        aclk <= 1'b0;
        aresetn <= 1'b0;
        #5ns aresetn <= 1'b1;
        forever #5ns aclk <= ~aclk;
    end
endmodule: vgainterval_sim