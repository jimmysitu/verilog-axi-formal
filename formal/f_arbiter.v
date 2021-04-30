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

// Language: Verilog 2001


/*
 * Formal properties of arbiter
 */
module f_arbiter #
(
    parameter PORTS = 4,
    // arbitration type: "PRIORITY" or "ROUND_ROBIN"
    parameter TYPE = "PRIORITY",
    // block type: "NONE", "REQUEST", "ACKNOWLEDGE"
    parameter BLOCK = "NONE",
    // LSB priority: "LOW", "HIGH"
    parameter LSB_PRIORITY = "LOW"
)
(
    input  wire                     clk,
    input  wire                     rst,

    input  wire [PORTS-1:0]         request,
    input  wire [PORTS-1:0]         acknowledge,

    output wire [PORTS-1:0]         grant,
    output wire                     grant_valid,
    output wire [$clog2(PORTS)-1:0] grant_encoded
);

    arbiter #(/*AUTOINSTPARAM*/
              // Parameters
              .PORTS                    (PORTS),
              .TYPE                     (TYPE),
              .BLOCK                    (BLOCK),
              .LSB_PRIORITY             (LSB_PRIORITY))
        dut(/*AUTOINST*/
            // Outputs
            .grant                      (grant[PORTS-1:0]),
            .grant_valid                (grant_valid),
            .grant_encoded              (grant_encoded[$clog2(PORTS)-1:0]),
            // Inputs
            .clk                        (clk),
            .rst                        (rst),
            .request                    (request[PORTS-1:0]),
            .acknowledge                (acknowledge[PORTS-1:0]));

    // Assume properties

    // Proof properties

    // Cover properties
    // output need to sync between encoded and unencoded
    cvr_onehot: cover property(
        (1<<grant_encoded) == grant
    );

    // Valid signal
    always @(*) begin
        if(request)
            cvr_vld: cover property(
                (grant_valid == 1'b1)
            );
        else
            cvr_invld: cover property(
                (grant_valid == 1'b0)
            );
    end

endmodule

// Local Variables:
// verilog-library-files:("../verilog-axi/rtl/arbiter.v")
// End:

