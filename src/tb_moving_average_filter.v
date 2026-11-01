`timescale 1ns/1ps

// Standalone ModelSim testbench.
// Generates a 5 Hz sine wave plus deterministic Gaussian-like noise internally.
// No MATLAB-generated HEX files are required.
module tb_moving_average_filter;
    parameter integer N = 31;
    parameter integer DATA_WIDTH = 16;
    parameter integer ACC_WIDTH = 22;
    parameter integer NUM_SAMPLES = 2001;
    parameter real FS_HZ = 1000.0;
    parameter real SIGNAL_HZ = 5.0;
    parameter real NOISE_SIGMA = 0.6;
    parameter real PI = 3.14159265358979323846;
    parameter integer FRAC_BITS = 12;

    reg clk;
    reg rst;
    reg sample_valid;
    reg signed [DATA_WIDTH-1:0] sample_in;

    wire sample_out_valid;
    wire signed [DATA_WIDTH-1:0] sample_out;

    integer i;
    integer rng_seed;
    integer fixed_input;
    integer ref_history [0:N-1];
    integer ref_ptr;
    integer ref_sum;
    integer ref_oldest;
    integer ref_sum_next;
    integer expected_integer;
    reg signed [DATA_WIDTH-1:0] expected_word;
    integer mismatch_count;
    integer output_count;
    integer input_file;
    integer output_file;

    moving_average_filter #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .sample_in(sample_in),
        .sample_out_valid(sample_out_valid),
        .sample_out(sample_out)
    );

    // 100 MHz simulation clock (10 ns period).
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Generate one fixed-point input sample.
    // Box-Muller transforms two deterministic pseudo-random values into
    // a normally distributed value. The seed makes this test repeatable.
    task make_sample;
        input integer sample_index;
        output integer sample_fixed;
        real u1;
        real u2;
        real gaussian_value;
        real clean_value;
        real noise_value;
        real noisy_value;
        real scaled_value;
        integer random_a;
        integer random_b;
        begin
            random_a = $random(rng_seed);
            random_b = $random(rng_seed);

            u1 = ((random_a & 32'h7fffffff) + 1.0) / 2147483649.0;
            u2 = (random_b & 32'h7fffffff) / 2147483648.0;

            gaussian_value = $sqrt(-2.0 * $ln(u1)) * $cos(2.0 * PI * u2);
            clean_value = $sin(2.0 * PI * SIGNAL_HZ * sample_index / FS_HZ);
            noise_value = NOISE_SIGMA * gaussian_value;
            noisy_value = clean_value + noise_value;
            scaled_value = noisy_value * (2.0 ** FRAC_BITS);

            // Round to nearest integer, symmetrically for positive/negative values.
            if (scaled_value >= 0.0)
                sample_fixed = $rtoi(scaled_value + 0.5);
            else
                sample_fixed = $rtoi(scaled_value - 0.5);

            // Saturate to signed DATA_WIDTH range.
            if (sample_fixed > 32767)
                sample_fixed = 32767;
            else if (sample_fixed < -32768)
                sample_fixed = -32768;
        end
    endtask

    initial begin
        rst = 1'b1;
        sample_valid = 1'b0;
        sample_in = {DATA_WIDTH{1'b0}};
        mismatch_count = 0;
        output_count = 0;
        rng_seed = 32'h13579BDF;
        ref_ptr = 0;
        ref_sum = 0;

        for (i = 0; i < N; i = i + 1)
            ref_history[i] = 0;

        input_file = $fopen("input_generated_q4_12.txt", "w");
        output_file = $fopen("hdl_output.txt", "w");
        if (input_file == 0 || output_file == 0) begin
            $display("ERROR: Could not create simulation output files.");
            $finish;
        end

        repeat (4) @(negedge clk);
        rst = 1'b0;

        for (i = 0; i < NUM_SAMPLES; i = i + 1) begin
            @(negedge clk);
            make_sample(i, fixed_input);
            sample_in = fixed_input;
            sample_valid = 1'b1;

            // Independent reference calculation: sum the newest N samples.
            ref_oldest = ref_history[ref_ptr];
            ref_sum_next = ref_sum + fixed_input - ref_oldest;
            ref_history[ref_ptr] = fixed_input;
            ref_sum = ref_sum_next;

            if (ref_sum_next >= 0)
                expected_integer = (ref_sum_next + (N/2)) / N;
            else
                expected_integer = (ref_sum_next - (N/2)) / N;
            expected_word = expected_integer;

            if (ref_ptr == N-1)
                ref_ptr = 0;
            else
                ref_ptr = ref_ptr + 1;

            $fwrite(input_file, "%0d\n", fixed_input);

            @(posedge clk);
            #1;
            if (sample_out_valid !== 1'b1) begin
                mismatch_count = mismatch_count + 1;
                $display("ERROR: sample_out_valid missing at sample %0d", i);
            end else begin
                output_count = output_count + 1;
                $fwrite(output_file, "%0d\n", $signed(sample_out));
                if (sample_out !== expected_word) begin
                    mismatch_count = mismatch_count + 1;
                    if (mismatch_count <= 10)
                        $display("MISMATCH sample %0d: HDL=%0d, reference=%0d",
                                 i, $signed(sample_out), expected_integer);
                end
            end
        end

        @(negedge clk);
        sample_valid = 1'b0;
        sample_in = {DATA_WIDTH{1'b0}};
        repeat (2) @(posedge clk);
        #1;

        $fclose(input_file);
        $fclose(output_file);

        $display("--------------------------------------------------");
        $display("Standalone Moving Average Filter simulation");
        $display("Input             : 5 Hz sine + Gaussian noise");
        $display("Sampling frequency: %0.1f Hz", FS_HZ);
        $display("Noise standard dev: %0.2f", NOISE_SIGMA);
        $display("Window size       : %0d", N);
        $display("Samples expected  : %0d", NUM_SAMPLES);
        $display("Samples written   : %0d", output_count);
        $display("Mismatches        : %0d", mismatch_count);
        if ((output_count == NUM_SAMPLES) && (mismatch_count == 0))
            $display("RESULT: PASS - HDL matches the independent testbench reference.");
        else
            $display("RESULT: FAIL - inspect mismatch messages and waveform.");
        $display("Generated input   : input_generated_q4_12.txt");
        $display("HDL output        : hdl_output.txt");
        $display("--------------------------------------------------");
        $finish;
    end
endmodule
