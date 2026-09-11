`timescale 1ns/1ps
// ============================================================================
// Module: cnn_accelerator_core
//
// Reusable CNN convolution IP block for an Artix-7 design.
//
// Datapath:
//   3x3 INT8 pixels
//        x
//   3x3 INT8 weights
//        |
//        v
//   9 parallel multipliers
//        |
//        v
//   32-bit accumulator + bias
//        |
//        v
//       ReLU
//
// This is the compute engine. In a production image pipeline, a line-buffer
// / AXI4-Stream front end would generate the 3x3 pixel window and feed it here.
//
// Interface is intentionally simple for RTL verification and FPGA bring-up.
// ============================================================================
module cnn_accelerator_core (
    input  logic                   clk,
    input  logic                   reset,

    input  logic                   start,
    output logic                   ready,
    output logic                   done,

    input  logic signed [7:0]       pixel [0:8],
    input  logic signed [7:0]       weight [0:8],
    input  logic signed [31:0]      bias,

    output logic signed [31:0]      conv_result,
    output logic signed [31:0]      relu_result
);

    logic signed [31:0] product [0:8];
    logic signed [31:0] sum_comb;
    logic signed [31:0] biased_comb;

    integer i;

    always_comb begin
        for (i = 0; i < 9; i = i + 1)
            product[i] = $signed(pixel[i]) * $signed(weight[i]);

        sum_comb = 32'sd0;
        for (i = 0; i < 9; i = i + 1)
            sum_comb = sum_comb + product[i];

        biased_comb = sum_comb + bias;
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            conv_result <= 32'sd0;
            relu_result <= 32'sd0;
            done        <= 1'b0;
        end else begin
            done <= 1'b0;

            if (start && ready) begin
                conv_result <= biased_comb;

                if (biased_comb < 0)
                    relu_result <= 32'sd0;
                else
                    relu_result <= biased_comb;

                done <= 1'b1;
            end
        end
    end

    assign ready = 1'b1;

endmodule
