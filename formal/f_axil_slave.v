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

// Language: Verilog 2005

/*
 * Formal properties of AXI4 lite slave port
 */

module f_axil_slave #
(
    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 32,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Maximum number of outstanding request
    parameter OUTSTAND_MAX = 64
)
(
    input  wire                     clk,
    input  wire                     rst,

    /*
     * AXI lite slave interface
     */
    input  wire [ADDR_WIDTH-1:0]    s_axil_awaddr,
    input  wire [2:0]               s_axil_awprot,
    input  wire                     s_axil_awvalid,
    input  wire                     s_axil_awready,
    input  wire [DATA_WIDTH-1:0]    s_axil_wdata,
    input  wire [STRB_WIDTH-1:0]    s_axil_wstrb,
    input  wire                     s_axil_wvalid,
    input  wire                     s_axil_wready,
    input  wire [1:0]               s_axil_bresp,
    input  wire                     s_axil_bvalid,
    input  wire                     s_axil_bready,
    input  wire [ADDR_WIDTH-1:0]    s_axil_araddr,
    input  wire [2:0]               s_axil_arprot,
    input  wire                     s_axil_arvalid,
    input  wire                     s_axil_arready,
    input  wire [DATA_WIDTH-1:0]    s_axil_rdata,
    input  wire [1:0]               s_axil_rresp,
    input  wire                     s_axil_rvalid,
    input  wire                     s_axil_rready,

    // Outputs for formal verification
    output wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_s_ar_outstanding,
    output wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_s_aw_outstanding,
    output wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_s_w_outstanding

);
    reg f_past_valid;

	initial f_past_valid = 0;
	always @(posedge clk)
		f_past_valid <= 1;

    // Assume properties
    //

    // Proof properties
    //

    // Cover properties
    always @(posedge clk) begin
        // AW channel
        cvr_aw_vld: cover property(s_axil_awvalid && s_axil_awready);
        // W channel
        cvr_w_vld: cover property(s_axil_wvalid && s_axil_wready);
        // B channel
        cvr_b_vld: cover property(s_axil_bvalid && s_axil_bready);

        // AR channel
        cvr_ar_vld: cover property(s_axil_arvalid && s_axil_arready);
        // R channel
        cvr_r_vld: cover property(s_axil_rvalid && s_axil_arready);
    end


endmodule

