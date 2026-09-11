`timescale 1ns/1ps

module cnn_accelerator_tb;

    logic clk = 1'b0;
    logic reset = 1'b1;
    logic start = 1'b0;
    logic ready;
    logic done;

    logic signed [7:0]  pixel  [0:8];
    logic signed [7:0]  weight [0:8];
    logic signed [31:0] bias;

    logic signed [31:0] conv_result;
    logic signed [31:0] relu_result;

    integer i;

    always #5 clk = ~clk; // 100 MHz

    cnn_accelerator_core dut (
        .clk         (clk),
        .reset       (reset),
        .start       (start),
        .ready       (ready),
        .done        (done),
        .pixel       (pixel),
        .weight      (weight),
        .bias        (bias),
        .conv_result (conv_result),
        .relu_result (relu_result)
    );

    task automatic load_pixels_1_to_9;
        begin
            pixel[0]=8'sd1; pixel[1]=8'sd2; pixel[2]=8'sd3;
            pixel[3]=8'sd4; pixel[4]=8'sd5; pixel[5]=8'sd6;
            pixel[6]=8'sd7; pixel[7]=8'sd8; pixel[8]=8'sd9;
        end
    endtask

    task automatic pulse_start;
        begin
            @(negedge clk);
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;
        end
    endtask

    initial begin
        bias = 32'sd0;

        for (i = 0; i < 9; i = i + 1) begin
            pixel[i]  = 8'sd0;
            weight[i] = 8'sd0;
        end

        repeat (2) @(posedge clk);
        reset = 1'b0;

        // TEST 1: identity-like kernel => 1 + 5 + 9 = 15
        load_pixels_1_to_9();
        for (i = 0; i < 9; i = i + 1) weight[i] = 8'sd0;
        weight[0] = 8'sd1;
        weight[4] = 8'sd1;
        weight[8] = 8'sd1;

        pulse_start();
        @(posedge clk);
        #1;
        if (conv_result !== 32'sd15 || relu_result !== 32'sd15)
            $fatal(1, "TEST1 FAIL: conv=%0d relu=%0d", conv_result, relu_result);
        else
            $display("TEST1 PASS: conv=%0d relu=%0d", conv_result, relu_result);

        // TEST 2: all weights 1 => 45
        load_pixels_1_to_9();
        for (i = 0; i < 9; i = i + 1) weight[i] = 8'sd1;

        pulse_start();
        @(posedge clk);
        #1;
        if (conv_result !== 32'sd45 || relu_result !== 32'sd45)
            $fatal(1, "TEST2 FAIL: conv=%0d relu=%0d", conv_result, relu_result);
        else
            $display("TEST2 PASS: conv=%0d relu=%0d", conv_result, relu_result);

        // TEST 3: left-column kernel => 1+4+7 = 12
        load_pixels_1_to_9();
        for (i = 0; i < 9; i = i + 1) weight[i] = 8'sd0;
        weight[0] = 8'sd1;
        weight[3] = 8'sd1;
        weight[6] = 8'sd1;

        pulse_start();
        @(posedge clk);
        #1;
        if (conv_result !== 32'sd12 || relu_result !== 32'sd12)
            $fatal(1, "TEST3 FAIL: conv=%0d relu=%0d", conv_result, relu_result);
        else
            $display("TEST3 PASS: conv=%0d relu=%0d", conv_result, relu_result);

        // TEST 4: negative kernel => -3, ReLU => 0
        load_pixels_1_to_9();
        for (i = 0; i < 9; i = i + 1) weight[i] = 8'sd0;
        weight[0] = 8'sd1;
        weight[3] = 8'sd1;
        weight[6] = 8'sd1;
        weight[2] = -8'sd1;
        weight[5] = -8'sd1;
        weight[8] = -8'sd1;

        pulse_start();
        @(posedge clk);
        #1;
        if (conv_result !== -32'sd3 || relu_result !== 32'sd0)
            $fatal(1, "TEST4 FAIL: conv=%0d relu=%0d", conv_result, relu_result);
        else
            $display("TEST4 PASS: conv=%0d relu=%0d", conv_result, relu_result);

        $display("ALL CNN ACCELERATOR TESTS PASSED.");
        $finish;
    end

endmodule
