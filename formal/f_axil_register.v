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
 * Formal properties of AXI4 lite register
 */
module f_axil_register #
(
    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 32,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // AW channel register type
    // 0 to bypass, 1 for simple buffer
    parameter AW_REG_TYPE = 1,
    // W channel register type
    // 0 to bypass, 1 for simple buffer
    parameter W_REG_TYPE = 1,
    // B channel register type
    // 0 to bypass, 1 for simple buffer
    parameter B_REG_TYPE = 1,
    // AR channel register type
    // 0 to bypass, 1 for simple buffer
    parameter AR_REG_TYPE = 1,
    // R channel register type
    // 0 to bypass, 1 for simple buffer
    parameter R_REG_TYPE = 1
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
    output wire                     s_axil_awready,
    input  wire [DATA_WIDTH-1:0]    s_axil_wdata,
    input  wire [STRB_WIDTH-1:0]    s_axil_wstrb,
    input  wire                     s_axil_wvalid,
    output wire                     s_axil_wready,
    output wire [1:0]               s_axil_bresp,
    output wire                     s_axil_bvalid,
    input  wire                     s_axil_bready,
    input  wire [ADDR_WIDTH-1:0]    s_axil_araddr,
    input  wire [2:0]               s_axil_arprot,
    input  wire                     s_axil_arvalid,
    output wire                     s_axil_arready,
    output wire [DATA_WIDTH-1:0]    s_axil_rdata,
    output wire [1:0]               s_axil_rresp,
    output wire                     s_axil_rvalid,
    input  wire                     s_axil_rready,

    /*
     * AXI lite master interface
     */
    output wire [ADDR_WIDTH-1:0]    m_axil_awaddr,
    output wire [2:0]               m_axil_awprot,
    output wire                     m_axil_awvalid,
    input  wire                     m_axil_awready,
    output wire [DATA_WIDTH-1:0]    m_axil_wdata,
    output wire [STRB_WIDTH-1:0]    m_axil_wstrb,
    output wire                     m_axil_wvalid,
    input  wire                     m_axil_wready,
    input  wire [1:0]               m_axil_bresp,
    input  wire                     m_axil_bvalid,
    output wire                     m_axil_bready,
    output wire [ADDR_WIDTH-1:0]    m_axil_araddr,
    output wire [2:0]               m_axil_arprot,
    output wire                     m_axil_arvalid,
    input  wire                     m_axil_arready,
    input  wire [DATA_WIDTH-1:0]    m_axil_rdata,
    input  wire [1:0]               m_axil_rresp,
    input  wire                     m_axil_rvalid,
    output wire                     m_axil_rready
);

localparam OUTSTAND_MAX = 16;

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_m_ar_outstanding;// From f_master of f_axil_master.v
wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_m_aw_outstanding;// From f_master of f_axil_master.v
wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_m_w_outstanding;// From f_master of f_axil_master.v
wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_s_ar_outstanding;// From f_slave of f_axil_slave.v
wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_s_aw_outstanding;// From f_slave of f_axil_slave.v
wire [$clog2(OUTSTAND_MAX)-1:0] f_axil_s_w_outstanding;// From f_slave of f_axil_slave.v
// End of automatics

// ================
// Help logic
// ================
    reg f_past_valid;

	initial f_past_valid = 0;
	always @(posedge clk)
		f_past_valid <= 1;


    // Notes. 
    // Since Yosys does not support for hierarchcial connections yet,
    // cannot get buffered info directly from DUT
    //

//    wire [$clog2(OUTSTAND_MAX)-1:0] f_aw_buffered;
//    wire [$clog2(OUTSTAND_MAX)-1:0] f_w_buffered;
//    wire [$clog2(OUTSTAND_MAX)-1:0] f_b_buffered;
//    wire [$clog2(OUTSTAND_MAX)-1:0] f_ar_buffered;
//    wire [$clog2(OUTSTAND_MAX)-1:0] f_r_buffered;
//    generate
//        if(AW_REG_TYPE>=1) begin
//            assign f_aw_buffered = !rst && (s_axil_awready ? 'b0 : 'b1);
//        end else begin
//            assign f_aw_buffered = 'b0;
//        end
//        if(W_REG_TYPE>=1) begin
//            assign f_w_buffered = !rst && (s_axil_wready ? 'b0 : 'b1);
//        end else begin
//            assign f_w_buffered = 'b0;
//        end
//        if(B_REG_TYPE>=1) begin
//            assign f_b_buffered = !rst && (m_axil_bready ? 'b0 : 'b1);
//        end else begin
//            assign f_b_buffered = 'b0;
//        end
//
//        if(AR_REG_TYPE>=1) begin
//            assign f_ar_buffered = !rst && (s_axil_arready ? 'b0 : 'b1);
//        end else begin
//            assign f_ar_buffered = 'b0;
//        end
//        if(R_REG_TYPE>=1) begin
//            assign f_r_buffered = !rst && (m_axil_rready ? 'b0 : 'b1);
//        end else begin
//            assign f_r_buffered = 'b0;
//        end
//    endgenerate

    reg [$clog2(OUTSTAND_MAX):0] f_aw_buffered;
    reg [$clog2(OUTSTAND_MAX):0] f_w_buffered;
    reg [$clog2(OUTSTAND_MAX):0] f_b_buffered;
    reg [$clog2(OUTSTAND_MAX):0] f_ar_buffered;
    reg [$clog2(OUTSTAND_MAX):0] f_r_buffered;

    always @(posedge clk) begin
        if(rst)begin
            f_aw_buffered <= 1'b0;
            f_w_buffered <= 1'b0;
            f_b_buffered <= 1'b0;
            f_ar_buffered <= 1'b0;
            f_r_buffered <= 1'b0;
        end else if(!$past(rst) && f_past_valid) begin
            // AW Channel
            if(AW_REG_TYPE>=1) begin
               if(!s_axil_awready)
                   f_aw_buffered <= 1'b1;
               else
                   f_aw_buffered <= 1'b0;
            end else begin
                f_aw_buffered <= 1'b0;
            end
            // W Channel
            if(W_REG_TYPE>=1) begin
                if(!s_axil_wready)
                    f_w_buffered <= 1'b1;
                else
                    f_w_buffered <= 1'b0;
            end else begin
                f_w_buffered <= 1'b0;
            end
            // B Channel
            if(B_REG_TYPE>=1) begin
                if(!m_axil_bready)
                    f_b_buffered <= 1'b1;
                else
                    f_b_buffered <= 1'b0;
            end else begin
                f_b_buffered <= 1'b0;
            end

            // AR Channel
            if(AR_REG_TYPE>=1) begin
                if(!s_axil_arready)
                    f_ar_buffered <= 1'b1;
                else
                    f_ar_buffered <= 1'b0;
            end else begin
                f_ar_buffered <= 1'b0;
            end
            // R Channel
            if(R_REG_TYPE>=1) begin
                if(!m_axil_rready)
                    f_r_buffered <= 1'b1;
                else
                    f_r_buffered <= 1'b0;
            end else begin
                f_r_buffered <= 1'b0;
            end
        end //if
    end //always

// ================
// Assume properties
// ================
    always @(posedge clk) begin
        if(!rst && f_past_valid) begin
            assume property(f_aw_buffered < 'd2);
            assume property(f_w_buffered < 'd2);
            assume property(f_b_buffered < 'd2);
            assume property(f_ar_buffered < 'd2);
            assume property(f_r_buffered < 'd2);
        end
    end
// ================
// Proof properties
// ================
//    always @(posedge clk) begin
//        if(!rst && f_past_valid) begin
//            dut_prf_aw_ostd: assert property(
//                f_axil_s_aw_outstanding >= f_axil_m_aw_outstanding
//            );
//            dut_prf_w_ostd: assert property(
//                f_axil_s_w_outstanding >= f_axil_m_w_outstanding
//            );
//            dut_prf_ar_ostd: assert property(
//                f_axil_s_ar_outstanding >= f_axil_m_ar_outstanding
//            );
//        end
//    end
    always @(posedge clk) begin
        if(!$past(rst) && !rst && f_past_valid) begin
            // Both side outstanding transaction should be synced
            dut_prf_aw_ostd: assert property(
                {1'b0, $past(f_axil_s_aw_outstanding)} ==
                    ({1'b0, $past(f_axil_m_aw_outstanding)} + f_aw_buffered + f_b_buffered)
            );
            dut_prf_w_ostd: assert property(
                {1'b0, $past(f_axil_s_w_outstanding)} ==
                    ({1'b0, $past(f_axil_m_w_outstanding)} + f_w_buffered + f_b_buffered)
            );
            dut_prf_ar_ostd: assert property(
                {1'b0, $past(f_axil_s_ar_outstanding)} ==
                    ({1'b0, $past(f_axil_m_ar_outstanding)} + f_ar_buffered + f_r_buffered)
            );
        end
    end

// ================
// Cover properties
// ================
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            dut_cvr_aw_ostd: cover property(
                f_axil_s_aw_outstanding ==
                    (f_axil_m_aw_outstanding + f_aw_buffered + f_b_buffered)
            );
            dut_cvr_w_ostd: cover property(
                f_axil_s_w_outstanding ==
                    (f_axil_m_w_outstanding + f_w_buffered + f_b_buffered)
            );
            dut_cvr_ar_ostd: cover property(
                f_axil_s_ar_outstanding ==
                    (f_axil_m_ar_outstanding + f_ar_buffered + f_r_buffered)
            );
        end
    end


// ================
// Formal bench
// ================
    axil_register #(/*AUTOINSTPARAM*/
                    // Parameters
                    .DATA_WIDTH         (DATA_WIDTH),
                    .ADDR_WIDTH         (ADDR_WIDTH),
                    .STRB_WIDTH         (STRB_WIDTH),
                    .AW_REG_TYPE        (AW_REG_TYPE),
                    .W_REG_TYPE         (W_REG_TYPE),
                    .B_REG_TYPE         (B_REG_TYPE),
                    .AR_REG_TYPE        (AR_REG_TYPE),
                    .R_REG_TYPE         (R_REG_TYPE))
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
            .m_axil_awaddr              (m_axil_awaddr[ADDR_WIDTH-1:0]),
            .m_axil_awprot              (m_axil_awprot[2:0]),
            .m_axil_awvalid             (m_axil_awvalid),
            .m_axil_wdata               (m_axil_wdata[DATA_WIDTH-1:0]),
            .m_axil_wstrb               (m_axil_wstrb[STRB_WIDTH-1:0]),
            .m_axil_wvalid              (m_axil_wvalid),
            .m_axil_bready              (m_axil_bready),
            .m_axil_araddr              (m_axil_araddr[ADDR_WIDTH-1:0]),
            .m_axil_arprot              (m_axil_arprot[2:0]),
            .m_axil_arvalid             (m_axil_arvalid),
            .m_axil_rready              (m_axil_rready),
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
            .s_axil_rready              (s_axil_rready),
            .m_axil_awready             (m_axil_awready),
            .m_axil_wready              (m_axil_wready),
            .m_axil_bresp               (m_axil_bresp[1:0]),
            .m_axil_bvalid              (m_axil_bvalid),
            .m_axil_arready             (m_axil_arready),
            .m_axil_rdata               (m_axil_rdata[DATA_WIDTH-1:0]),
            .m_axil_rresp               (m_axil_rresp[1:0]),
            .m_axil_rvalid              (m_axil_rvalid));

     f_axil_slave #(/*AUTOINSTPARAM*/
                    // Parameters
                    .DATA_WIDTH         (DATA_WIDTH),
                    .ADDR_WIDTH         (ADDR_WIDTH),
                    .STRB_WIDTH         (STRB_WIDTH),
                    .OUTSTAND_MAX       (OUTSTAND_MAX))
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

     f_axil_master #(/*AUTOINSTPARAM*/
                     // Parameters
                     .DATA_WIDTH        (DATA_WIDTH),
                     .ADDR_WIDTH        (ADDR_WIDTH),
                     .STRB_WIDTH        (STRB_WIDTH),
                     .OUTSTAND_MAX      (OUTSTAND_MAX))
        f_master(/*AUTOINST*/
                 // Outputs
                 .f_axil_m_aw_outstanding(f_axil_m_aw_outstanding[$clog2(OUTSTAND_MAX)-1:0]),
                 .f_axil_m_w_outstanding(f_axil_m_w_outstanding[$clog2(OUTSTAND_MAX)-1:0]),
                 .f_axil_m_ar_outstanding(f_axil_m_ar_outstanding[$clog2(OUTSTAND_MAX)-1:0]),
                 // Inputs
                 .clk                   (clk),
                 .rst                   (rst),
                 .m_axil_awaddr         (m_axil_awaddr[ADDR_WIDTH-1:0]),
                 .m_axil_awprot         (m_axil_awprot[2:0]),
                 .m_axil_awvalid        (m_axil_awvalid),
                 .m_axil_awready        (m_axil_awready),
                 .m_axil_wdata          (m_axil_wdata[DATA_WIDTH-1:0]),
                 .m_axil_wstrb          (m_axil_wstrb[STRB_WIDTH-1:0]),
                 .m_axil_wvalid         (m_axil_wvalid),
                 .m_axil_wready         (m_axil_wready),
                 .m_axil_bresp          (m_axil_bresp[1:0]),
                 .m_axil_bvalid         (m_axil_bvalid),
                 .m_axil_bready         (m_axil_bready),
                 .m_axil_araddr         (m_axil_araddr[ADDR_WIDTH-1:0]),
                 .m_axil_arprot         (m_axil_arprot[2:0]),
                 .m_axil_arvalid        (m_axil_arvalid),
                 .m_axil_arready        (m_axil_arready),
                 .m_axil_rdata          (m_axil_rdata[DATA_WIDTH-1:0]),
                 .m_axil_rresp          (m_axil_rresp[1:0]),
                 .m_axil_rvalid         (m_axil_rvalid),
                 .m_axil_rready         (m_axil_rready));

endmodule

// Local Variables:
// verilog-library-files:("../verilog-axi/rtl/axil_register.v")
// End:

