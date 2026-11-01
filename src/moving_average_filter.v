`timescale 1ns/1ps

// Moving Average FIR filter using a circular delay line and running sum.
// Input/output format: signed 16-bit Q4.12.
// Default window size: 31 samples.
module moving_average_filter #(
    parameter integer N = 31,
    parameter integer DATA_WIDTH = 16,
    parameter integer ACC_WIDTH = 22
) (
    input  wire                             clk,
    input  wire                             rst,
    input  wire                             sample_valid,
    input  wire signed [DATA_WIDTH-1:0]     sample_in,
    output reg                              sample_out_valid,
    output reg signed [DATA_WIDTH-1:0]      sample_out
);

    function integer clog2;
        input integer value;
        integer temp;
        begin
            temp = value - 1;
            for (clog2 = 0; temp > 0; clog2 = clog2 + 1)
                temp = temp >> 1;
        end
    endfunction

    localparam integer PTR_WIDTH = (N <= 2) ? 1 : clog2(N);

    reg signed [DATA_WIDTH-1:0] delay_line [0:N-1];
    reg [PTR_WIDTH-1:0] write_ptr;
    reg signed [ACC_WIDTH-1:0] running_sum;

    reg signed [DATA_WIDTH-1:0] oldest_sample;
    wire signed [ACC_WIDTH-1:0] sample_in_ext;
    wire signed [ACC_WIDTH-1:0] oldest_sample_ext;
    wire signed [ACC_WIDTH-1:0] sum_next;
    wire signed [ACC_WIDTH-1:0] sum_rounded;
    wire signed [ACC_WIDTH-1:0] average_next;

    integer i;

    assign sample_in_ext = {{(ACC_WIDTH-DATA_WIDTH){sample_in[DATA_WIDTH-1]}}, sample_in};

    always @(*) begin
        oldest_sample = delay_line[write_ptr];
    end

    assign oldest_sample_ext = {{(ACC_WIDTH-DATA_WIDTH){oldest_sample[DATA_WIDTH-1]}}, oldest_sample};
    assign sum_next = running_sum + sample_in_ext - oldest_sample_ext;

    // Verilog signed division truncates toward zero. Add/subtract N/2 first
    // to implement round-to-nearest, matching the MATLAB integer reference.
    assign sum_rounded = (sum_next >= 0) ? (sum_next + (N/2)) : (sum_next - (N/2));
    assign average_next = sum_rounded / N;

    always @(posedge clk) begin
        if (rst) begin
            write_ptr        <= {PTR_WIDTH{1'b0}};
            running_sum      <= {ACC_WIDTH{1'b0}};
            sample_out       <= {DATA_WIDTH{1'b0}};
            sample_out_valid <= 1'b0;
            for (i = 0; i < N; i = i + 1)
                delay_line[i] <= {DATA_WIDTH{1'b0}};
        end else begin
            sample_out_valid <= 1'b0;

            if (sample_valid) begin
                delay_line[write_ptr] <= sample_in;
                running_sum <= sum_next;
                sample_out <= average_next[DATA_WIDTH-1:0];
                sample_out_valid <= 1'b1;

                if (write_ptr == N-1)
                    write_ptr <= {PTR_WIDTH{1'b0}};
                else
                    write_ptr <= write_ptr + 1'b1;
            end
        end
    end

endmodule
