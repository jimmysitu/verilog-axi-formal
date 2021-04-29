/*

Copyright (c) 2014-2021 Jimmy Situ

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: SystemVerilog 2012

/*
 * Formal properties of priority_encoder
 */
module f_priority_encoder #
(
    parameter WIDTH = 4,
    // LSB priority: "LOW", "HIGH"
    parameter LSB_PRIORITY = "LOW"
)
(
    input  wire [WIDTH-1:0]         input_unencoded,
    output wire                     output_valid,
    output wire [$clog2(WIDTH)-1:0] output_encoded,
    output wire [WIDTH-1:0]         output_unencoded
);

parameter LEVELS = WIDTH > 2 ? $clog2(WIDTH) : 1;
parameter W = 2**LEVELS;

    priority_encoder #(/*AUTOINSTPARAM*/
                       // Parameters
                       .WIDTH           (WIDTH),
                       .LSB_PRIORITY    (LSB_PRIORITY),
                       .LEVELS          (LEVELS),
                       .W               (W))
        dut(/*AUTOINST*/
            // Outputs
            .output_valid               (output_valid),
            .output_encoded             (output_encoded[$clog2(WIDTH)-1:0]),
            .output_unencoded           (output_unencoded[WIDTH-1:0]),
            // Inputs
            .input_unencoded            (input_unencoded[WIDTH-1:0]));

    // Assume properties

    // Proof properties
    // output need to sync between encoded and unencoded
    prf_sync: assert property(
        (1<<output_encoded) == output_unencoded
    );

    always @(*) begin
        if(input_unencoded)
            prf_input: assert property(
                (input_unencoded >> output_encoded) == 'b1
            );
    end


    // Cover properties
    // output need to sync between encoded and unencoded
    cvr_onehot: cover property(
        (1<<output_encoded) == output_unencoded
    );

    always @(*) begin
        if(input_unencoded)
            cvr_vld: cover property(
                (output_valid == 1'b1)
            );
        else
            cvr_invld: cover property(
                (output_valid == 1'b0)
            );
    end

endmodule

// Local Variables:
// verilog-library-files:("../verilog-axi/rtl/priority_encoder.v")
// End:

