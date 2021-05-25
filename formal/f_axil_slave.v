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
    parameter F_OSTD_MAX = 64,
    // Maximum clock number of AW/W/AR channel can be stalled
    parameter F_REQ_STALL_MAX = 16,
    // Maximum clock number of B/R channel can be stalled
    parameter F_RSP_STALL_MAX = 16,
    // Maximum clock number between request and response
    parameter F_DELAY_MAX = 64,
    // Only AR/R channel
    parameter F_OPT_READ_ONLY = 1'b0,
    // Only AW/W/B channel
    parameter F_OPT_WRITE_ONLY = 1'b0
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
    output reg [$clog2(F_OSTD_MAX)-1:0] f_axil_s_aw_outstanding,
    output reg [$clog2(F_OSTD_MAX)-1:0] f_axil_s_w_outstanding,
    output reg [$clog2(F_OSTD_MAX)-1:0] f_axil_s_ar_outstanding

);
// ================
// Help logic
// ================
    reg f_past_valid;
    reg [$clog2(F_REQ_STALL_MAX)-1:0] f_axil_aw_stall, f_axil_w_stall, f_axil_ar_stall;
    reg [$clog2(F_RSP_STALL_MAX)-1:0] f_axil_b_stall, f_axil_r_stall;
    reg [$clog2(F_DELAY_MAX)-1:0] f_axil_aw_delay, f_axil_w_delay, f_axil_ar_delay;

	initial f_past_valid = 0;
	always @(posedge clk)
		f_past_valid <= 1;

    // Outstanding count
    // AW channel
    wire aw_req = s_axil_awvalid && s_axil_awready && !rst;
    wire aw_rsp = s_axil_bvalid && s_axil_bready && !rst;
    always @(posedge clk) begin
        if(rst) begin
            f_axil_s_aw_outstanding <= 'b0;
        end else if(aw_req && !aw_rsp) begin
            f_axil_s_aw_outstanding <= f_axil_s_aw_outstanding + 'b1;
        end else if(!aw_req && aw_rsp) begin
            f_axil_s_aw_outstanding <= f_axil_s_aw_outstanding - 'b1;
        end else begin
            f_axil_s_aw_outstanding <= f_axil_s_aw_outstanding;
        end
    end

    // W channel
    wire w_req = s_axil_wvalid && s_axil_wready && !rst;
    wire w_rsp = s_axil_bvalid && s_axil_bready && !rst;
    always @(posedge clk) begin
        if(rst) begin
            f_axil_s_w_outstanding <= 'b0;
        end else if(w_req && !w_rsp) begin
            f_axil_s_w_outstanding <= f_axil_s_w_outstanding + 'b1;
        end else if(!w_req && w_rsp) begin
            f_axil_s_w_outstanding <= f_axil_s_w_outstanding - 'b1;
        end else begin
            f_axil_s_w_outstanding <= f_axil_s_w_outstanding;
        end
    end

    // AR channel
    wire ar_req = s_axil_arvalid && s_axil_arready && !rst;
    wire ar_rsp = s_axil_rvalid && s_axil_rready && !rst;
    always @(posedge clk) begin
        if(rst) begin
            f_axil_s_ar_outstanding <= 'b0;
        end else if(ar_req && !ar_rsp) begin
            f_axil_s_ar_outstanding <= f_axil_s_ar_outstanding + 'b1;
        end else if(!ar_req && ar_rsp) begin
            f_axil_s_ar_outstanding <= f_axil_s_ar_outstanding - 'b1;
        end else begin
            f_axil_s_ar_outstanding <= f_axil_s_ar_outstanding;
        end
    end

    // AW stall count
    always @(posedge clk) begin
        if(rst) begin
            f_axil_aw_stall <= 'b0;
        end else if(s_axil_awvalid && !s_axil_awready) begin
            f_axil_aw_stall <= f_axil_aw_stall + 'b1;
        end else begin
            f_axil_aw_stall <= 'b0;
        end
    end

    // W stall count
    always @(posedge clk) begin
        if(rst) begin
            f_axil_w_stall <= 'b0;
        end else if(s_axil_wvalid && !s_axil_wready) begin
            f_axil_w_stall <= f_axil_w_stall + 'b1;
        end else begin
            f_axil_w_stall <= 'b0;
        end
    end

    // B stall count
    always @(posedge clk) begin
        if(rst) begin
            f_axil_b_stall <= 'b0;
        end else if(s_axil_bvalid && !s_axil_bready) begin
            f_axil_b_stall <= f_axil_b_stall + 'b1;
        end else begin
            f_axil_b_stall <= 'b0;
        end
    end

    // AR Stall count
    always @(posedge clk) begin
        if(rst) begin
            f_axil_ar_stall <= 'b0;
        end else if(s_axil_arvalid && !s_axil_arready) begin
            f_axil_ar_stall <= f_axil_ar_stall + 'b1;
        end else begin
            f_axil_ar_stall <= 'b0;
        end
    end

    // R Stall count
    always @(posedge clk) begin
        if(rst) begin
            f_axil_r_stall <= 'b0;
        end else if(s_axil_rvalid && !s_axil_rready) begin
            f_axil_r_stall <= f_axil_r_stall + 'b1;
        end else begin
            f_axil_r_stall <= 'b0;
        end
    end

    // AW-B delay count
    always @(posedge clk) begin
        if(rst) begin
            f_axil_aw_delay <= 'b0;
        end else if(f_axil_s_aw_outstanding > 0) begin
            f_axil_aw_delay <= f_axil_aw_delay + 'b1;
        end else if(s_axil_bvalid) begin
            f_axil_aw_delay <= 'b0;
        end else begin
            f_axil_aw_delay <= f_axil_aw_delay;
        end
    end

    // W-B delay count
    always @(posedge clk) begin
        if(rst) begin
            f_axil_w_delay <= 'b0;
        end else if(f_axil_s_w_outstanding > 0) begin
            f_axil_w_delay <= f_axil_w_delay + 'b1;
        end else if(s_axil_bvalid) begin
            f_axil_w_delay <= 'b0;
        end else begin
            f_axil_w_delay <= f_axil_w_delay;
        end
    end

    // AR-R delay count
    always @(posedge clk) begin
        if(rst) begin
            f_axil_ar_delay <= 'b0;
        end else if(f_axil_s_w_outstanding > 0) begin
            f_axil_ar_delay <= f_axil_ar_delay + 'b1;
        end else if(s_axil_rvalid) begin
            f_axil_ar_delay <= 'b0;
        end else begin
            f_axil_ar_delay <= f_axil_ar_delay;
        end
    end

// ================
// Options properties
// ================
    // F_OPT_WRITE_ONLY or F_OPT_READ_ONLY
    generate if(F_OPT_WRITE_ONLY) begin
        always @(*) begin
            if(f_past_valid) begin
                assume property(s_axil_arvalid == 1'b0);
                assert property(s_axil_rvalid  == 1'b0);
                assert property(f_axil_s_ar_outstanding == 'b0);
            end
        end
    end endgenerate

    generate if(F_OPT_READ_ONLY) begin
        always @(*) begin
            if(f_past_valid) begin
                assume property(s_axil_awvalid == 1'b0);
                assume property(s_axil_wvalid == 1'b0);
                assert property(s_axil_bvalid  == 1'b0);
                assert property(f_axil_s_aw_outstanding == 'b0);
                assert property(f_axil_s_w_outstanding == 'b0);
            end
        end
    end endgenerate

// ================
// Assume properties
// ================
    always @(*) begin
        if(!f_past_valid)
            assume property(rst==1);
    end

    // Assume rst relative
    always @(posedge clk) begin
        if($past(rst) && f_past_valid) begin
            // Assume no request valid when rst valid
            assume property(
                (s_axil_awvalid == 1'b0) &&
                (s_axil_wvalid  == 1'b0) &&
                (s_axil_arvalid == 1'b0)
            );
            // Assume no response ready when rst valid
            assume property(
                (s_axil_bready == 1'b0) &&
                (s_axil_rready  == 1'b0)
            );
        end
    end

    // Assume stall relative properties
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            // Assume request valid should be kept when stalled
            if($past(s_axil_awvalid) && !$past(s_axil_awready)) begin
                assume property(
                    (s_axil_awvalid) && $stable(s_axil_awaddr));
            end
            if($past(s_axil_wvalid) && !$past(s_axil_wready)) begin
                assume property(
                    (s_axil_wvalid) && $stable(s_axil_wdata) && $stable(s_axil_wstrb));
            end
            if($past(s_axil_arvalid) && !$past(s_axil_arready)) begin
                assume property(
                    (s_axil_arvalid) && $stable(s_axil_araddr));
            end

            // Assume no request valid when almost reach F_OSTD_MAX
            if(f_axil_s_aw_outstanding == (F_OSTD_MAX-2))
                assume property(!s_axil_awvalid);
            if(f_axil_s_w_outstanding == (F_OSTD_MAX-2))
                assume property(!s_axil_wvalid);
            if(f_axil_s_ar_outstanding == (F_OSTD_MAX-2))
                assume property(!s_axil_arvalid);
        end
    end

    // Assume each rsp channel will never be stalled longer than STALL_MAX
    always @(*) begin
        assume property(f_axil_b_stall < F_RSP_STALL_MAX);
        assume property(f_axil_r_stall < F_RSP_STALL_MAX);
    end

// ================
// Proof properties
// ================
    // Proof rst relative properties
    always @(posedge clk) begin
        if($past(rst) && f_past_valid) begin
            // Proof no response valid when rst valid
            prf_rst_bvld: assert property(
                (s_axil_bvalid == 1'b0));
            prf_rst_rvld: assert property(
                (s_axil_rvalid == 1'b0));

            // Proof no request ready when rst valid
            prf_rst_awrdy: assert property(
                (s_axil_awready == 1'b0));
            prf_rst_wrdy: assert property(
                (s_axil_wready == 1'b0));
            prf_rst_arrdy: assert property(
                (s_axil_arready == 1'b0));
        end
    end

    // Proof stall relative properties
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            // Proof response should be kept when stalled
            if($past(s_axil_bvalid) && !$past(s_axil_bready)) begin
                prf_stl_b: assert property(
                    (s_axil_bvalid) && $stable(s_axil_bresp));
            end
            if($past(s_axil_rvalid) && !$past(s_axil_rready)) begin
                prf_stl_r: assert property(
                    (s_axil_rvalid) && $stable(s_axil_rdata) && $stable(s_axil_rresp));
            end
        end
    end

    // Proof when there is rsp there must be a req
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            if(s_axil_bvalid) begin
                prf_aw_ostd: assert property(f_axil_s_aw_outstanding>0);
                prf_w_ostd: assert property(f_axil_s_w_outstanding>0);
            end
//            if(f_axil_s_aw_outstanding == 'b0) begin
//                prf_rsp_aw: assert property(!s_axil_bvalid);
//            end
//            if(f_axil_s_w_outstanding == 'b0) begin
//                prf_rsp_w: assert property(!s_axil_bvalid);
//            end
//            if(f_axil_s_ar_outstanding == 'b0) begin
//                prf_rsp_ar: assert property(!s_axil_rvalid);
//            end
        end
    end

    // Proof outstanding cycles never overflow
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            prf_aw_ovf: assert property(f_axil_s_aw_outstanding < (F_OSTD_MAX-1));
            prf_w_ovf:  assert property(f_axil_s_w_outstanding  < (F_OSTD_MAX-1));
            prf_ar_ovf: assert property(f_axil_s_ar_outstanding < (F_OSTD_MAX-1));
        end
    end

    // Proof each req channel will never be stalled longer than STALL_MAX
    always @(*) begin
        prf_aw_stl: assert property(f_axil_aw_stall < F_REQ_STALL_MAX);
        prf_w_stl:  assert property(f_axil_w_stall  < F_REQ_STALL_MAX);
        prf_ar_stl: assert property(f_axil_ar_stall < F_REQ_STALL_MAX);
    end

    // Proof each req will get rsp in DELAY_MAX
    always @(*) begin
        prf_aw_dly: assert property(f_axil_aw_delay < F_DELAY_MAX);
        prf_w_dly:  assert property(f_axil_w_delay  < F_DELAY_MAX);
        prf_ar_dly: assert property(f_axil_ar_delay < F_DELAY_MAX);
    end

// ================
// Cover properties
// ================
    // Cover valid properties
    generate if(!F_OPT_READ_ONLY) begin
        always @(posedge clk) begin
            if(!$past(rst) && f_past_valid) begin
                // AW channel
                cvr_aw_vld: cover property(s_axil_awvalid && s_axil_awready);
                // W channel
                cvr_w_vld: cover property(s_axil_wvalid && s_axil_wready);
                // B channel
                cvr_b_vld: cover property(s_axil_bvalid && s_axil_bready);
            end
        end
    end endgenerate

    generate if(!F_OPT_WRITE_ONLY) begin
        always @(posedge clk) begin
            if(!$past(rst) && f_past_valid) begin
                // AR channel
                cvr_ar_vld: cover property(s_axil_arvalid && s_axil_arready);
                // R channel
                cvr_r_vld: cover property(s_axil_rvalid && s_axil_arready);
            end
        end
    end endgenerate

    // Cover outstanding
    generate if(!F_OPT_READ_ONLY) begin
        always @(posedge clk) begin
            if(!$past(rst) && f_past_valid) begin
                if(s_axil_bvalid) begin
                    cvr_aw_ostd: cover property(
                        f_axil_s_aw_outstanding > 0
                    );
                    cvr_w_ostd: cover property(
                        f_axil_s_w_outstanding > 0
                    );
                end
            end
        end
    end endgenerate

    generate if(!F_OPT_WRITE_ONLY) begin
        always @(posedge clk) begin
            if(!$past(rst) && f_past_valid) begin
                if(s_axil_rvalid) begin
                    cvr_ar_ostd: cover property(
                        f_axil_s_ar_outstanding > 0
                    );
                end
            end
        end
    end endgenerate

endmodule

