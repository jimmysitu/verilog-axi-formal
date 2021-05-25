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
 * Formal properties of AXI4 lite register (read)
 */
module f_axil_register_rd #
(
    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 32,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
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
    output wire [ADDR_WIDTH-1:0]    m_axil_araddr,
    output wire [2:0]               m_axil_arprot,
    output wire                     m_axil_arvalid,
    input  wire                     m_axil_arready,
    input  wire [DATA_WIDTH-1:0]    m_axil_rdata,
    input  wire [1:0]               m_axil_rresp,
    input  wire                     m_axil_rvalid,
    output wire                     m_axil_rready
);

localparam F_OSTD_MAX       = 16;
localparam F_REQ_STALL_MAX  = 16;
localparam F_RSP_STALL_MAX  = 16;
localparam F_DELAY_MAX      = 16;
localparam F_OPT_READ_ONLY   = 1'b1;
localparam F_OPT_WRITE_ONLY  = 1'b0;

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [$clog2(F_OSTD_MAX)-1:0] f_axil_m_ar_outstanding;// From f_master of f_axil_master.v
wire [$clog2(F_OSTD_MAX)-1:0] f_axil_m_aw_outstanding;// From f_master of f_axil_master.v
wire [$clog2(F_OSTD_MAX)-1:0] f_axil_m_w_outstanding;// From f_master of f_axil_master.v
wire [$clog2(F_OSTD_MAX)-1:0] f_axil_s_ar_outstanding;// From f_slave of f_axil_slave.v
wire [$clog2(F_OSTD_MAX)-1:0] f_axil_s_aw_outstanding;// From f_slave of f_axil_slave.v
wire [$clog2(F_OSTD_MAX)-1:0] f_axil_s_w_outstanding;// From f_slave of f_axil_slave.v
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


    // Outstanding counts inside axil_register
    // From the view of slave side,  ostd = slave_intf ostd - buff rsp
    // From the veiw of master side, ostd = master_intf ostd + buff req
    reg [$clog2(F_OSTD_MAX)-1:0] s_ar_ostd;
    reg [$clog2(F_OSTD_MAX)-1:0] m_ar_ostd;

    always @(*) begin
        if(!rst && f_past_valid) begin
            // With skid buffer
            s_ar_ostd = f_axil_s_ar_outstanding - (s_axil_rvalid?'b1:'b0) - (m_axil_rready?'b0:'b1);
            m_ar_ostd = f_axil_m_ar_outstanding + (m_axil_arvalid?'b1:'b0) + (s_axil_arready?'b0:'b1);
        end else begin
            s_ar_ostd = 'b0;
            m_ar_ostd = 'b0;
        end
    end

    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            dut_prf_ar_ostd: assert property(s_ar_ostd == m_ar_ostd);
        end
    end

// ================
// Cover properties
// ================
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            dut_cvr_ar_ostd: cover property(s_ar_ostd == m_ar_ostd);
        end
    end


// ================
// Formal bench
// ================
    axil_register_rd #(/*AUTOINSTPARAM*/
                       // Parameters
                       .DATA_WIDTH      (DATA_WIDTH),
                       .ADDR_WIDTH      (ADDR_WIDTH),
                       .STRB_WIDTH      (STRB_WIDTH),
                       .AR_REG_TYPE     (AR_REG_TYPE),
                       .R_REG_TYPE      (R_REG_TYPE))
        dut(/*AUTOINST*/
            // Outputs
            .s_axil_arready             (s_axil_arready),
            .s_axil_rdata               (s_axil_rdata[DATA_WIDTH-1:0]),
            .s_axil_rresp               (s_axil_rresp[1:0]),
            .s_axil_rvalid              (s_axil_rvalid),
            .m_axil_araddr              (m_axil_araddr[ADDR_WIDTH-1:0]),
            .m_axil_arprot              (m_axil_arprot[2:0]),
            .m_axil_arvalid             (m_axil_arvalid),
            .m_axil_rready              (m_axil_rready),
            // Inputs
            .clk                        (clk),
            .rst                        (rst),
            .s_axil_araddr              (s_axil_araddr[ADDR_WIDTH-1:0]),
            .s_axil_arprot              (s_axil_arprot[2:0]),
            .s_axil_arvalid             (s_axil_arvalid),
            .s_axil_rready              (s_axil_rready),
            .m_axil_arready             (m_axil_arready),
            .m_axil_rdata               (m_axil_rdata[DATA_WIDTH-1:0]),
            .m_axil_rresp               (m_axil_rresp[1:0]),
            .m_axil_rvalid              (m_axil_rvalid));

     f_axil_slave #(/*AUTOINSTPARAM*/
                    // Parameters
                    .DATA_WIDTH         (DATA_WIDTH),
                    .ADDR_WIDTH         (ADDR_WIDTH),
                    .STRB_WIDTH         (STRB_WIDTH),
                    .F_OSTD_MAX         (F_OSTD_MAX),
                    .F_REQ_STALL_MAX    (F_REQ_STALL_MAX),
                    .F_RSP_STALL_MAX    (F_RSP_STALL_MAX),
                    .F_DELAY_MAX        (F_DELAY_MAX),
                    .F_OPT_READ_ONLY    (F_OPT_READ_ONLY),
                    .F_OPT_WRITE_ONLY   (F_OPT_WRITE_ONLY))
        f_slave(
                .s_axil_awaddr          ('h0),
                .s_axil_awprot          ('h0),
                .s_axil_awvalid         ('h0),
                .s_axil_awready         ('h0),
                .s_axil_wdata           ('h0),
                .s_axil_wstrb           ('h0),
                .s_axil_wvalid          ('h0),
                .s_axil_wready          ('h0),
                .s_axil_bresp           ('h0),
                .s_axil_bvalid          ('h0),
                .s_axil_bready          ('h0),
                /*AUTOINST*/
                // Outputs
                .f_axil_s_aw_outstanding(f_axil_s_aw_outstanding[$clog2(F_OSTD_MAX)-1:0]),
                .f_axil_s_w_outstanding (f_axil_s_w_outstanding[$clog2(F_OSTD_MAX)-1:0]),
                .f_axil_s_ar_outstanding(f_axil_s_ar_outstanding[$clog2(F_OSTD_MAX)-1:0]),
                // Inputs
                .clk                    (clk),
                .rst                    (rst),
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
                     .F_OSTD_MAX        (F_OSTD_MAX),
                     .F_REQ_STALL_MAX   (F_REQ_STALL_MAX),
                     .F_RSP_STALL_MAX   (F_RSP_STALL_MAX),
                     .F_DELAY_MAX       (F_DELAY_MAX),
                     .F_OPT_READ_ONLY   (F_OPT_READ_ONLY),
                     .F_OPT_WRITE_ONLY  (F_OPT_WRITE_ONLY))
        f_master(
                 .m_axil_awaddr         ('h0),
                 .m_axil_awprot         ('h0),
                 .m_axil_awvalid        ('h0),
                 .m_axil_awready        ('h0),
                 .m_axil_wdata          ('h0),
                 .m_axil_wstrb          ('h0),
                 .m_axil_wvalid         ('h0),
                 .m_axil_wready         ('h0),
                 .m_axil_bresp          ('h0),
                 .m_axil_bvalid         ('h0),
                 .m_axil_bready         ('h0),
                 .m_axil_araddr         ('h0),
                 .m_axil_arprot         ('h0),
                 /*AUTOINST*/
                 // Outputs
                 .f_axil_m_aw_outstanding(f_axil_m_aw_outstanding[$clog2(F_OSTD_MAX)-1:0]),
                 .f_axil_m_w_outstanding(f_axil_m_w_outstanding[$clog2(F_OSTD_MAX)-1:0]),
                 .f_axil_m_ar_outstanding(f_axil_m_ar_outstanding[$clog2(F_OSTD_MAX)-1:0]),
                 // Inputs
                 .clk                   (clk),
                 .rst                   (rst),
                 .m_axil_arvalid        (m_axil_arvalid),
                 .m_axil_arready        (m_axil_arready),
                 .m_axil_rdata          (m_axil_rdata[DATA_WIDTH-1:0]),
                 .m_axil_rresp          (m_axil_rresp[1:0]),
                 .m_axil_rvalid         (m_axil_rvalid),
                 .m_axil_rready         (m_axil_rready));

endmodule

// Local Variables:
// verilog-library-files:("../verilog-axi/rtl/axil_register_rd.v")
// End:

