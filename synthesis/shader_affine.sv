`timescale 1ns / 1ps
`default_nettype none
// Affine transform stuff
module shader_affine
   (input wire logic aclk,
    input wire logic aresetn,
    input wire logic strobe,
    input wire logic wen,
    // Pixel X from interval counters
    input wire logic unsigned [11:0] px,
    input wire logic unsigned [11:0] py,
    // Position of the square
    input wire logic unsigned [11:0] qx,
    input wire logic unsigned [11:0] qy,
    // The square's origin
    input wire logic unsigned [11:0] qx0,
    input wire logic unsigned [11:0] qy0,
    // The affine transform matrix
    input wire logic unsigned [11:0] qm[4],
    output logic unsigned [11:0] tu,
    output logic unsigned [11:0] tv);
    logic unsigned [1:0] state = 2'b000000;
    // ========================================================================
    // State machine
    // ========================================================================
    always_ff@(posedge aclk or negedge aresetn) begin: state_machine
        if(~aresetn)
            state <= 2'b00;
        else if(strobe & ~(|state) & ~wen)
            state <= 2'b01;
        else
            state <= state << 1;
    end: state_machine
    // ========================================================================
    // Register holds
    // ========================================================================
    logic unsigned [11:0] r_qx;
    logic unsigned [11:0] r_qx0;
    logic unsigned [11:0] r_qy;
    logic unsigned [11:0] r_qy0;
    logic unsigned [11:0] r_qm[4];
    always_ff@(posedge aclk or negedge aresetn) begin: hold_qx
        if(~aresetn)
            r_qx <= 12'h000;
        else if(~(|state) & wen)
            r_qx <= qx - qx0;
    end: hold_qx
    always_ff@(posedge aclk or negedge aresetn) begin: hold_qx0
        if(~aresetn)
            r_qx0 <= 12'h000;
        else if(~(|state) & wen)
            r_qx0 <= qx0;
    end: hold_qx0
    always_ff@(posedge aclk or negedge aresetn) begin: hold_qy
        if(~aresetn)
            r_qy <= 12'h000;
        else if(~(|state) & wen)
            r_qy <= qy - qy0;
    end: hold_qy
    always_ff@(posedge aclk or negedge aresetn) begin: hold_qy0
        if(~aresetn)
            r_qy0 <= 12'h000;
        else if(~(|state) & wen)
            r_qy0 <= qy0;
    end: hold_qy0
    generate
        for (genvar i = 0; i < 4; i++) begin: gen_hold_mat
            always_ff@(posedge aclk or negedge aresetn) begin: hold_mat
                if(~aresetn)
                    r_qm[i] <= 12'h000;
                else if(~(|state) & wen)
                    r_qm[i] <= qm[i];
            end: hold_mat
        end: gen_hold_mat
    endgenerate
    // ========================================================================
    // Matrix multiplier
    // ========================================================================
    // FYI:
    //
    // | a b | e |
    // | c d | f |
    //
    // [(a * e) + (b * f)] = e'
    // [(c * e) + (d * f)] = f'
    //
    // PLEASE check this.
    logic unsigned [23:0] accum_xprime;
    logic unsigned [23:0] accum_yprime;
    always_comb begin: multiply
        case(state) inside
            2'b01: accum_xprime = (r_qm[0] * r_qx) + (r_qm[1] * r_qy) +
                                      {12'h000, r_qx0};
            2'b10: accum_yprime = (r_qm[2] * r_qx) + (r_qm[3] * r_qy) +
                                      {12'h000, r_qx0};
            2'b00: {tu, tv} = {accum_xprime[23:12], accum_yprime[23:12]};
            default: ;
        endcase
    end: multiply
endmodule: shader_affine