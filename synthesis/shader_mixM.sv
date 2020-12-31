`timescale 1ns / 1ps
`default_nettype none
// Fragment Swizzle Mux
module shader_mixM
   (input wire logic unsigned [1:0] map_from,

    input wire logic unsigned [3:0] rdata_c3,
    input wire logic unsigned [3:0] rdata_c2,
    input wire logic unsigned [3:0] rdata_c1,
    input wire logic unsigned [3:0] rdata_c0,

    output logic unsigned [3:0] wdata);
    always_comb begin
        case(map_from) inside
            2'h3: wdata = rdata_c3;
            2'h2: wdata = rdata_c2;
            2'h1: wdata = rdata_c1;
            2'h0: wdata = rdata_c0;
            default: ;
        endcase
    end
endmodule: shader_mixM