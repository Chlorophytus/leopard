`timescale 1ns / 1ps
`default_nettype none
module vga_interval_sim;
    logic aclk;
    logic aresetn;
    
    logic hsync;
    logic vsync;
    logic hblank;
    logic vblank;
    logic select;

    logic unsigned [11:0] px;
    logic unsigned [11:0] py;
    
    vga_interval dut(.*);
    
    initial begin
        aclk <= 1'b0;
        aresetn <= 1'b0;
        #10ns aresetn <= 1'b1;
        forever #10ns aclk <= ~aclk;
    end
endmodule: vga_interval_sim