`timescale 1ns / 1ps
`default_nettype none
module vgainterval
  #(parameter W = 640,
    parameter WFPRCH = 664,
    parameter WBLANK = 720,
    parameter WBPRCH = 800,
    parameter H = 480,
    parameter HFPRCH = 483,
    parameter HBLANK = 487,
    parameter HBPRCH = 500)
   (input wire logic aclk,
    input wire logic aresetn,
    output logic hsync,
    output logic vsync,
    output logic hblank,
    output logic vblank,
    output logic unsigned [11:0] x,
    output logic unsigned [11:0] y);
    always_ff@(posedge aclk or negedge aresetn) begin
        if(~aresetn | ~(|x))
            x <= WBPRCH - 12'h001;
        else
            x <= x - 12'h001;
    end
    always_ff@(posedge aclk or negedge aresetn) begin
        if(~aresetn | (~(|y) & ~(|x)))
            y <= HBPRCH - 12'h001;
        else if(~(|x))
            y <= y - 12'h001;
    end
    always_comb begin
        case(x) inside
            WBPRCH - 12'h001: {hblank, hsync} = 2'b11;
            WBLANK - 12'h001: {hblank, hsync} = 2'b10;
            WFPRCH - 12'h001: {hblank, hsync} = 2'b11;
            W - 12'h001: {hblank, hsync} = 2'b01;
            default: ;
        endcase
        case(y) inside
            HBPRCH - 12'h001: {vblank, vsync} = 2'b10;
            HBLANK - 12'h001: {vblank, vsync} = 2'b11;
            HFPRCH - 12'h001: {vblank, vsync} = 2'b10;
            H - 12'h001: {vblank, vsync} = 2'b00;
            default: ;
        endcase
    end
endmodule: vgainterval
