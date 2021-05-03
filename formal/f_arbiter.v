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


    reg f_past_valid;

	initial f_past_valid = 0;
	always @(posedge clk)
		f_past_valid <= 1;

    // Assume properties
    always @(*) begin
        if(!f_past_valid)
            assume property(rst == 1'b1);
    end

    // Proof properties
    // Proof grant and grant_encoded must be sync
    always @(posedge clk) begin
        if(grant_valid)
            prf_onehot: assert property(
                (1<<grant_encoded) == grant
            );
    end

    always @(posedge clk) begin
        if($past(rst) && f_past_valid) begin
            // Proof reset works
            prf_rst: assert property(
                (grant_valid == 1'b0)
            );
        end else if(!$past(rst) && f_past_valid) begin
            if(BLOCK == "REQUEST") begin
                // Proof valid properties
                if($past(request) == 'b0) begin
                    prf_invld_req: assert property(
                        grant_valid == 1'b0
                    );
                end else if($past(request) != 'b0) begin
                    prf_vld_req: assert property(
                        grant_valid == 1'b1
                    );
                end
            end else if(BLOCK == "ACKNOWLEDGE") begin
                // Proof valid properties
                if($past(request) == 'b0 && ($past(acknowledge) & $past(grant))) begin
                    prf_invld_ack: assert property(
                        grant_valid == 1'b0
                    );
                end else if($past(request) != 'b0 && ($past(acknowledge) & $past(grant))) begin
                    prf_vld_req: assert property(
                        grant_valid == 1'b1
                    );
                end
            end
        end
    end

    // Proof block properties
    generate
        if (BLOCK == "REQUEST")
            always @(posedge clk) begin
                if(!$past(rst) && f_past_valid) begin
                    if($past(grant_valid) && ($past(request) & $past(grant)))
                        prf_blk_req: assert property(
                            grant_valid == 1'b1 &
                            $past(grant_encoded) == grant_encoded
                        );
                end
            end
        else if (BLOCK == "ACKNOWLEDGE")
            always @(posedge clk) begin
                if(!$past(rst) && f_past_valid) begin
                    if($past(grant_valid) && !($past(acknowledge) & $past(grant)))
                        prf_blk_ack: assert property(
                            grant_valid == 1'b1 &
                            $past(grant_encoded) == grant_encoded
                        );
                end
            end
    endgenerate

    // Cover properties
    // Cover output need to sync between encoded and unencoded
    always @(posedge clk) begin
        cvr_onehot: cover property(
            (1<<grant_encoded) == grant
        );
    end

    // Cover valid signal
    always @(posedge clk) begin
        if($past(rst) && f_past_valid) begin
            cvr_rst: cover property(
                (grant_valid == 1'b0)
            );
        end else if(BLOCK == "REQUEST") begin
            if(!$past(rst) && f_past_valid) begin
                if($past(request) == 'b0)
                    cvr_invld_req: cover property(
                        (grant_valid == 1'b0)
                    );
                else if($past(request) != 'b0)
                    cvr_vld_req: cover property(
                        (grant_valid == 1'b1)
                    );
            end
        end else if(BLOCK == "ACKNOWLEDGE") begin
            if(!$past(rst) && f_past_valid) begin
                if($past(request) == 'b0 && ($past(acknowledge) & $past(grant))) begin
                    cvr_invld_ack: cover property(
                        grant_valid == 1'b0
                    );
                end else if($past(request) != 'b0 && ($past(acknowledge) & $past(grant))) begin
                    cvr_vld_ack: cover property(
                        grant_valid == 1'b1
                    );
                end
            end
        end
    end

    // Cover block properties
    generate
        if (BLOCK == "REQUEST")
            always @(posedge clk) begin
                if(!$past(rst) && f_past_valid) begin
                    if($past(grant_valid) && ($past(request) & $past(grant)))
                        cvr_blk_req: cover property(
                            grant_valid == 1'b1 &
                            $past(grant_encoded) == grant_encoded
                        );
                end
            end
        if (BLOCK == "ACKNOWLEDGE")
            always @(posedge clk) begin
                if(!$past(rst) && f_past_valid) begin
                    if($past(grant_valid) && !($past(acknowledge) & $past(grant)))
                        cvr_blk_ack: cover property(
                            grant_valid == 1'b1 &
                            $past(grant_encoded) == grant_encoded
                        );
                end
            end
    endgenerate
endmodule

// Local Variables:
// verilog-library-files:("../verilog-axi/rtl/arbiter.v")
// End:

