`timescale 1ns/1ps
// ============================================================================
// TOP: cnn_accelerator_fgg484_top
//
// Device target:
//   Family : Artix-7
//   Device : XC7A100T
//   Package: FGG484
//   Part   : xc7a100tfgg484-1
//
// This wrapper intentionally exposes a flat 243-bit external interface:
//
//   pixel_flat   : 72 bits  (9 x INT8)
//   weight_flat  : 72 bits  (9 x INT8)
//   bias         : 32 bits
//   conv_result  : 32 bits
//   relu_result  : 32 bits
//   clk/reset/start : 3 bits
//
// Total = 72 + 72 + 32 + 32 + 32 + 3 = 243 I/O bits.
//
// IMPORTANT:
// This is a package-level implementation/placement test interface.
// It is NOT a board-specific pinout. A real FGG484 development/custom board
// must provide the physical PACKAGE_PIN assignments for these ports.
// ============================================================================
module cnn_accelerator_fgg484_top (
    input  logic                   clk,
    input  logic                   reset,
    input  logic                   start,

    input  logic signed [71:0]     pixel_flat,
    input  logic signed [71:0]     weight_flat,
    input  logic signed [31:0]     bias,

    output logic signed [31:0]     conv_result,
    output logic signed [31:0]     relu_result
);

    logic signed [7:0]  pixel  [0:8];
    logic signed [7:0]  weight [0:8];
    logic               ready_unused;
    logic               done_unused;

    genvar g;
    generate
        for (g = 0; g < 9; g = g + 1) begin : GEN_UNPACK
            assign pixel[g]  = pixel_flat[g*8 +: 8];
            assign weight[g] = weight_flat[g*8 +: 8];
        end
    endgenerate

    cnn_accelerator_core u_cnn (
        .clk         (clk),
        .reset       (reset),
        .start       (start),
        .ready       (ready_unused),
        .done        (done_unused),
        .pixel       (pixel),
        .weight      (weight),
        .bias        (bias),
        .conv_result (conv_result),
        .relu_result (relu_result)
    );

endmodule
