`timescale 1ns / 1ps
`default_nettype none
module vgabuffer
  #(parameter BUFFER_X = 320,
    parameter BUFFER_Y = 240)
   (input wire logic aclk4,
    input wire logic aresetn,
    input wire logic unsigned [11:0] x,
    input wire logic unsigned [11:0] y,
    input wire logic unsigned [11:0] wdata,
    input wire logic select,
    input wire logic wen,
    output logic unsigned [11:0] rdata);
    logic unsigned [11:0] buffer[BUFFER_X*BUFFER_Y] = '{default:{12'h777}};
    logic unsigned [2:0] state = 3'b000;
    logic strb = 1'b0;
    always_ff@(posedge aclk4 or negedge aresetn) begin
        if(~aresetn)
            state <= 3'b000;
        else if(strb)
            state <= 3'b001;
        else
            state <= state << 1;
    end
    always_ff@(posedge aclk4 or negedge aresetn) begin
        if(~aresetn)
            strb <= 1'b0;
        else if(select) begin
            if(~(|state))
                strb <= 1'b1;
            else
                strb <= 1'b0;
        end
    end
    always_ff@(posedge aclk4 or negedge aresetn) begin
        if(~aresetn)
            rdata <= 12'h000;
        else if(~wen & strb & select)
            rdata <= buffer[x + (y * BUFFER_X)];
    end
    always_ff@(posedge aclk4) begin
        if(wen & strb & select)
            buffer[x + (y * BUFFER_X)] <= wdata;
    end
    
    initial buffer = '{default:{12'h777}};
endmodule: vgabuffer
