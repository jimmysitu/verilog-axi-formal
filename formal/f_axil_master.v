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
 * Formal properties of AXI4 lite master port
 */

module f_axil_master #
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
     * AXI lite master interface
     */
    input  wire [ADDR_WIDTH-1:0]    m_axil_awaddr,
    input  wire [2:0]               m_axil_awprot,
    input  wire                     m_axil_awvalid,
    input  wire                     m_axil_awready,
    input  wire [DATA_WIDTH-1:0]    m_axil_wdata,
    input  wire [STRB_WIDTH-1:0]    m_axil_wstrb,
    input  wire                     m_axil_wvalid,
    input  wire                     m_axil_wready,
    input  wire [1:0]               m_axil_bresp,
    input  wire                     m_axil_bvalid,
    input  wire                     m_axil_bready,
    input  wire [ADDR_WIDTH-1:0]    m_axil_araddr,
    input  wire [2:0]               m_axil_arprot,
    input  wire                     m_axil_arvalid,
    input  wire                     m_axil_arready,
    input  wire [DATA_WIDTH-1:0]    m_axil_rdata,
    input  wire [1:0]               m_axil_rresp,
    input  wire                     m_axil_rvalid,
    input  wire                     m_axil_rready,

    // Outputs for formal verification
    output reg [$clog2(OUTSTAND_MAX)-1:0] f_axil_m_aw_outstanding,
    output reg [$clog2(OUTSTAND_MAX)-1:0] f_axil_m_w_outstanding,
    output reg [$clog2(OUTSTAND_MAX)-1:0] f_axil_m_ar_outstanding

);
// ================
// Help logic
// ================
    reg f_past_valid;

	initial f_past_valid = 0;
	always @(posedge clk)
		f_past_valid <= 1;

    // AW channel
    wire aw_req = m_axil_awvalid && m_axil_awready && !rst;
    wire aw_rsp = m_axil_bvalid && m_axil_bready && !rst;
    always @(posedge clk) begin
        if(rst) begin
            f_axil_m_aw_outstanding <= 'b0;
        end else if(aw_req && !aw_rsp) begin
            f_axil_m_aw_outstanding <= f_axil_m_aw_outstanding + 'b1;
        end else if(!aw_req && aw_rsp) begin
            f_axil_m_aw_outstanding <= f_axil_m_aw_outstanding - 'b1;
        end else begin
            f_axil_m_aw_outstanding <= f_axil_m_aw_outstanding;
        end
    end

    // W channel
    wire w_req = m_axil_wvalid && m_axil_wready && !rst;
    wire w_rsp = m_axil_bvalid && m_axil_bready && !rst;
    always @(posedge clk) begin
        if(rst) begin
            f_axil_m_w_outstanding <= 'b0;
        end else if(w_req && !w_rsp) begin
            f_axil_m_w_outstanding <= f_axil_m_w_outstanding + 'b1;
        end else if(!w_req && w_rsp) begin
            f_axil_m_w_outstanding <= f_axil_m_w_outstanding - 'b1;
        end else begin
            f_axil_m_w_outstanding <= f_axil_m_w_outstanding;
        end
    end

    // AR channel
    wire ar_req = m_axil_arvalid && m_axil_arready && !rst;
    wire ar_rsp = m_axil_rvalid && m_axil_rready && !rst;
    always @(posedge clk) begin
        if(rst) begin
            f_axil_m_ar_outstanding <= 'b0;
        end else if(ar_req && !ar_rsp) begin
            f_axil_m_ar_outstanding <= f_axil_m_ar_outstanding + 'b1;
        end else if(!ar_req && ar_rsp) begin
            f_axil_m_ar_outstanding <= f_axil_m_ar_outstanding - 'b1;
        end else begin
            f_axil_m_ar_outstanding <= f_axil_m_ar_outstanding;
        end
    end

// ================
// Assume properties
// ================
    always @(*) begin
        if(!f_past_valid)
            assume property(rst==1);
    end

    // Assume reset relative
    always @(posedge clk) begin
        if($past(rst) && f_past_valid) begin
            // Assume no request ready when rst valid
            assume property(
                (m_axil_awready == 1'b0) &&
                (m_axil_wready  == 1'b0) &&
                (m_axil_arready == 1'b0)
            );
            // Assume no response valid when rst valid
            assume property(
                (m_axil_bvalid == 1'b0) &&
                (m_axil_rvalid == 1'b0)
            );
        end
    end

    // Assume stall relative properties
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            // Assume response valid should be kept when stalled
            if($past(m_axil_bvalid) && !$past(m_axil_bready)) begin
                assume property(
                    (m_axil_bvalid) && $stable(m_axil_bresp));
            end
            if($past(m_axil_rvalid) && !$past(m_axil_rready)) begin
                assume property(
                    (m_axil_rvalid) && $stable(m_axil_rdata) && $stable(m_axil_rresp));
            end

            // Assume no ready assert when almost reach OUTSTAND_MAX
            if(f_axil_m_aw_outstanding == (OUTSTAND_MAX-2))
                assume property(!m_axil_awready);
            if(f_axil_m_w_outstanding == (OUTSTAND_MAX-2))
                assume property(!m_axil_wready);
            if(f_axil_m_ar_outstanding == (OUTSTAND_MAX-2))
                assume property(!m_axil_arready);

        end
    end

    // Assume outstanding cycles never overflow
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            assume property(f_axil_m_aw_outstanding < (OUTSTAND_MAX-1));
            assume property(f_axil_m_w_outstanding  < (OUTSTAND_MAX-1));
            assume property(f_axil_m_ar_outstanding < (OUTSTAND_MAX-1));
        end
    end

    // Assume rsp sync with req
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            if(m_axil_bvalid) begin
                assume property(f_axil_m_aw_outstanding > 0);
                assume property(f_axil_m_w_outstanding  > 0);
            end
            if(m_axil_rvalid) begin
                assume property(f_axil_m_ar_outstanding > 0);
            end
//            if(f_axil_m_aw_outstanding == 'b0) begin
//                assume property(!m_axil_bvalid);
//            end
//            if(f_axil_m_w_outstanding == 'b0) begin
//                assume property(!m_axil_bvalid);
//            end
//            if(f_axil_m_ar_outstanding == 'b0) begin
//                assume property(!m_axil_rvalid);
//            end
        end
    end

    // TODO: Assume each req will get rsp in DELAY_MAX


// ================
// Proof properties
// ================
    // Proof rst relative properties
    always @(posedge clk) begin
        if($past(rst) && f_past_valid) begin
            // Proof no request valid when rst valid
            prf_rst_awvld: assert property(
                (m_axil_awvalid == 1'b0));
            prf_rst_wvld: assert property(
                (m_axil_wvalid == 1'b0));
            prf_rst_arvld: assert property(
                (m_axil_arvalid == 1'b0));

            // Proof no response ready when rst valid
            prf_rst_brdy: assert property(
                (m_axil_bready == 1'b0));
            prf_rst_rrdy: assert property(
                (m_axil_rready == 1'b0));
        end
    end

    // Proof stall relative properties
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            // Proof request valid should be kept when stalled
            if($past(m_axil_awvalid) && !$past(m_axil_awready)) begin
                prf_stl_aw: assert property(
                    (m_axil_awvalid) && $stable(m_axil_awaddr));
            end
            if($past(m_axil_wvalid) && !$past(m_axil_wready)) begin
                prf_stl_w: assert property(
                    (m_axil_wvalid) && $stable(m_axil_wdata) && $stable(m_axil_wstrb));
            end
            if($past(m_axil_arvalid) && !$past(m_axil_arready)) begin
                prf_stl_ar: assert property(
                    (m_axil_arvalid) && $stable(m_axil_araddr));
            end
        end
    end

// ================
// Cover properties
// ================
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            // AW channel
            cvr_aw_vld: cover property(m_axil_awvalid && m_axil_awready);
            // W channel
            cvr_w_vld: cover property(m_axil_wvalid && m_axil_wready);
            // B channel
            cvr_b_vld: cover property(m_axil_bvalid && m_axil_bready);

            // AR channel
            cvr_ar_vld: cover property(m_axil_arvalid && m_axil_arready);
            // R channel
            cvr_r_vld: cover property(m_axil_rvalid && m_axil_arready);
        end
    end

    // Cover outstanding
    always @(posedge clk) begin
        if(!$past(rst) && f_past_valid) begin
            cvr_aw_ostd: cover property(
                f_axil_m_aw_outstanding > 0
            );
            cvr_w_ostd: cover property(
                f_axil_m_w_outstanding > 0
            );
            cvr_ar_ostd: cover property(
                f_axil_m_ar_outstanding > 0
            );
        end
    end


endmodule

