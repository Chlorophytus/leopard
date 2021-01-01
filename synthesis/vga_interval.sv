`timescale 1ns / 1ps
`default_nettype none
// Interval Generator
module vga_interval
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
    output logic unsigned [11:0] px,
    output logic unsigned [11:0] py);
    // ========================================================================
    // X track
    // ========================================================================
    always_ff@(posedge aclk or negedge aresetn) begin
        if(~aresetn | ~(|px))
            px <= WBPRCH - 12'h001;
        else
            px <= px - 12'h001;
    end
    // ========================================================================
    // Y track
    // ========================================================================
    always_ff@(posedge aclk or negedge aresetn) begin
        if(~aresetn | (~(|py) & ~(|px)))
            py <= HBPRCH - 12'h001;
        else if(~(|px))
            py <= py - 12'h001;
    end
    // ========================================================================
    // Combinatorial hblank and vblank tracks
    // ========================================================================
    always_comb begin
        case(px) inside
            WBPRCH - 12'h001: {hblank, hsync} = 2'b11;
            WBLANK - 12'h001: {hblank, hsync} = 2'b10;
            WFPRCH - 12'h001: {hblank, hsync} = 2'b11;
            W - 12'h001: {hblank, hsync} = 2'b01;
            default: ;
        endcase
        case(py) inside
            HBPRCH - 12'h001: {vblank, vsync} = 2'b10;
            HBLANK - 12'h001: {vblank, vsync} = 2'b11;
            HFPRCH - 12'h001: {vblank, vsync} = 2'b10;
            H - 12'h001: {vblank, vsync} = 2'b00;
            default: ;
        endcase
    end
endmodule: vga_interval
