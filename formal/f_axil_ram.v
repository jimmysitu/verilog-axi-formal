/*

Copyright (c) 2021 Jimmy Situ

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
 * Formal properties of AXI4-Lite RAM
 */
module f_axil_ram #
(
    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 16,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Extra pipeline register on output
    parameter PIPELINE_OUTPUT = 1
)
(
    input  wire                   clk,
    input  wire                   rst,

    input  wire [ADDR_WIDTH-1:0]  s_axil_awaddr,
    input  wire [2:0]             s_axil_awprot,
    input  wire                   s_axil_awvalid,
    output wire                   s_axil_awready,
    input  wire [DATA_WIDTH-1:0]  s_axil_wdata,
    input  wire [STRB_WIDTH-1:0]  s_axil_wstrb,
    input  wire                   s_axil_wvalid,
    output wire                   s_axil_wready,
    output wire [1:0]             s_axil_bresp,
    output wire                   s_axil_bvalid,
    input  wire                   s_axil_bready,
    input  wire [ADDR_WIDTH-1:0]  s_axil_araddr,
    input  wire [2:0]             s_axil_arprot,
    input  wire                   s_axil_arvalid,
    output wire                   s_axil_arready,
    output wire [DATA_WIDTH-1:0]  s_axil_rdata,
    output wire [1:0]             s_axil_rresp,
    output wire                   s_axil_rvalid,
    input  wire                   s_axil_rready
);

parameter VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH);
parameter WORD_WIDTH = STRB_WIDTH;
parameter WORD_SIZE = DATA_WIDTH/WORD_WIDTH;

localparam OUTSTAND_MAX = 16;

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_s_ar_outstanding;// From f_slave of f_axil_slave.v
wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_s_aw_outstanding;// From f_slave of f_axil_slave.v
wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_s_w_outstanding;// From f_slave of f_axil_slave.v
// End of automatics

// ================
// Help logic
// ================

// ================
// Cover properties
// ================

// ================
// Formal bench
// ================
    axil_ram #(/*AUTOINSTPARAM*/
               // Parameters
               .DATA_WIDTH              (DATA_WIDTH),
               .ADDR_WIDTH              (ADDR_WIDTH),
               .STRB_WIDTH              (STRB_WIDTH),
               .PIPELINE_OUTPUT         (PIPELINE_OUTPUT),
               .VALID_ADDR_WIDTH        (VALID_ADDR_WIDTH),
               .WORD_WIDTH              (WORD_WIDTH),
               .WORD_SIZE               (WORD_SIZE))
        dut(/*AUTOINST*/
            // Outputs
            .s_axil_awready             (s_axil_awready),
            .s_axil_wready              (s_axil_wready),
            .s_axil_bresp               (s_axil_bresp[1:0]),
            .s_axil_bvalid              (s_axil_bvalid),
            .s_axil_arready             (s_axil_arready),
            .s_axil_rdata               (s_axil_rdata[DATA_WIDTH-1:0]),
            .s_axil_rresp               (s_axil_rresp[1:0]),
            .s_axil_rvalid              (s_axil_rvalid),
            // Inputs
            .clk                        (clk),
            .rst                        (rst),
            .s_axil_awaddr              (s_axil_awaddr[ADDR_WIDTH-1:0]),
            .s_axil_awprot              (s_axil_awprot[2:0]),
            .s_axil_awvalid             (s_axil_awvalid),
            .s_axil_wdata               (s_axil_wdata[DATA_WIDTH-1:0]),
            .s_axil_wstrb               (s_axil_wstrb[STRB_WIDTH-1:0]),
            .s_axil_wvalid              (s_axil_wvalid),
            .s_axil_bready              (s_axil_bready),
            .s_axil_araddr              (s_axil_araddr[ADDR_WIDTH-1:0]),
            .s_axil_arprot              (s_axil_arprot[2:0]),
            .s_axil_arvalid             (s_axil_arvalid),
            .s_axil_rready              (s_axil_rready));

    f_axil_slave #(/*AUTOINSTPARAM*/
                   // Parameters
                   .DATA_WIDTH          (DATA_WIDTH),
                   .ADDR_WIDTH          (ADDR_WIDTH),
                   .STRB_WIDTH          (STRB_WIDTH),
                   .OUTSTAND_MAX        (OUTSTAND_MAX))
        f_slave(/*AUTOINST*/
                // Outputs
                .f_axil_s_aw_outstanding(f_axil_s_aw_outstanding[$clog2(OUTSTAND_MAX)-1:0]),
                .f_axil_s_w_outstanding (f_axil_s_w_outstanding[$clog2(OUTSTAND_MAX)-1:0]),
                .f_axil_s_ar_outstanding(f_axil_s_ar_outstanding[$clog2(OUTSTAND_MAX)-1:0]),
                // Inputs
                .clk                    (clk),
                .rst                    (rst),
                .s_axil_awaddr          (s_axil_awaddr[ADDR_WIDTH-1:0]),
                .s_axil_awprot          (s_axil_awprot[2:0]),
                .s_axil_awvalid         (s_axil_awvalid),
                .s_axil_awready         (s_axil_awready),
                .s_axil_wdata           (s_axil_wdata[DATA_WIDTH-1:0]),
                .s_axil_wstrb           (s_axil_wstrb[STRB_WIDTH-1:0]),
                .s_axil_wvalid          (s_axil_wvalid),
                .s_axil_wready          (s_axil_wready),
                .s_axil_bresp           (s_axil_bresp[1:0]),
                .s_axil_bvalid          (s_axil_bvalid),
                .s_axil_bready          (s_axil_bready),
                .s_axil_araddr          (s_axil_araddr[ADDR_WIDTH-1:0]),
                .s_axil_arprot          (s_axil_arprot[2:0]),
                .s_axil_arvalid         (s_axil_arvalid),
                .s_axil_arready         (s_axil_arready),
                .s_axil_rdata           (s_axil_rdata[DATA_WIDTH-1:0]),
                .s_axil_rresp           (s_axil_rresp[1:0]),
                .s_axil_rvalid          (s_axil_rvalid),
                .s_axil_rready          (s_axil_rready));

endmodule

// Local Variables:
// verilog-library-files:("../verilog-axi/rtl/axil_ram.v")
// End:

