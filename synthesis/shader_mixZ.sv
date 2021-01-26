`timescale 1ns / 1ps
`default_nettype none
// Z grouping
module shader_mixZ
  #(// This uses a mux by the way
    parameter ZGROUPS = 1,
    // Will be raised to a power of 2
    parameter SHADERS_POW2 = 3)
   (input wire logic aclk,
    input wire logic aresetn,
    input wire logic strobe,
    output logic ready);
    localparam SHADERS = 2 ** SHADERS_POW2;
    localparam ZLAYERS = ZGROUPS * 5;
    logic unsigned [ZLAYERS-1:0] states_interleave = '{default:{1'b0}};
    logic unsigned [SHADERS-1:0] z_data[ZLAYERS];
    logic unsigned [4:0] state[ZLAYERS] = '{default:{5'b00000}};
    // ========================================================================
    // State machines
    // ========================================================================
    // Interleaver.
    always_ff@(posedge aclk or negedge aresetn) begin: state_machine_interleaver
        if(~aresetn)
            states_interleave <= '{default:{1'b0}};
        else if(strobe & ~(|states_interleave))
            states_interleave[0] <= 1'b1;
        else
            states_interleave <= states_interleave << 1;
    end: state_machine_interleaver
    assign ready = ~(|states_interleave);
    // ========================================================================
    // Multiple redundant components
    // ========================================================================
    generate
        // Each layer runs in a pipelined fashion.
        for (genvar z = 0; z < ZLAYERS; z++) begin
            always_ff@(posedge aclk or negedge aresetn) begin
                if(~aresetn)
                    state[z] <= 5'b00000;
                else if(states_interleave[z])
                    state[z] <= 5'b00001;
                else
                    state[z] <= state[z] << 1;
            end
        end
        // Generate shaders
        for (genvar i = 0; i < SHADERS; i++) begin
            logic use_this_z;
            // assign use_this_z = z_data[]
            shader_affine vert(
                .aclk(aclk),
                .aresetn(aresetn),
                .strobe(),
                .wen(),
                .px(),
                .py(),
                .qx(),
                .qy(),
                .qx0(),
                .qy0(),
                .qm(),
                .tu(),
                .tv()
            );
        end
    endgenerate
endmodule: shader_mixZ