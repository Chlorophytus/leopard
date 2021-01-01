`timescale 1ns / 1ps
`default_nettype none
// Texture Cache w/DMA write
module shader_tcache
  #(// Will be raised to a power of 2, i.e. 2 ** 3
    parameter TCACHE_SIZE = 3)
   (input wire logic aclk,
    input wire logic aresetn,
    input wire logic strobe,
    // NOTE: Will adding a high-bandwidth DMA line cause trouble?
    input wire logic dma_en,
    input wire logic unsigned [3:0] dma_data[TCACHE_WIDTH**2],
    input wire logic unsigned [(TCACHE_WIDTH**2)-1:0] dma_mask,
    input wire logic unsigned [TCACHE_SIZE-1:0] tu,
    input wire logic unsigned [TCACHE_SIZE-1:0] tv,
    output logic unsigned [3:0] rdata);
    localparam TCACHE_WIDTH = 2 ** TCACHE_SIZE;
    logic unsigned [3:0] tcache[TCACHE_WIDTH**2];
    logic unsigned [2:0] state = 3'b000;
    // ========================================================================
    // State machine
    // ========================================================================
    always_ff@(posedge aclk or negedge aresetn) begin: state_machine
        if(~aresetn)
            state <= 3'b000;
        else if(strobe & ~(|state))
            state <= 3'b001;
        else
            state <= state << 1;
    end: state_machine
    // ========================================================================
    // Read register
    // ========================================================================
    always_ff@(posedge aclk or negedge aresetn) begin: read_register
        if(~aresetn)
            rdata <= 4'h0;
        else if(~dma_en & state[2])
            rdata <= tcache[tu + (tv * TCACHE_WIDTH)];
    end: read_register
    // ========================================================================
    // Write/DMA handling
    // ========================================================================
    generate
        for(genvar i = 0; i < TCACHE_WIDTH**2; i++) begin: writedma_gen
            always_ff@(posedge aclk) begin: writedma_register
                if(dma_en & state[2] & dma_mask[i])
                    tcache[i] <= dma_data[i];
            end: writedma_register
        end: writedma_gen
    endgenerate
    // ========================================================================
    // Initialize TCACHE
    // ========================================================================
    initial tcache = '{default:{4'hF}};
endmodule: shader_tcache