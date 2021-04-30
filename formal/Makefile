#
#Copyright (c) 2014-2021 Jimmy Situ
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#


RTL 	  := ../verilog-axi/rtl
HELPERS   := priority_encoder
PRIORITY_ENCODER := priority_encoder

TESTS := $(HELPERS)
all: $(TESTS)

$(PRIORITY_ENCODER): $(PRIORITY_ENCODER)_cvr1/PASS
$(PRIORITY_ENCODER): $(PRIORITY_ENCODER)_cvr3/PASS
$(PRIORITY_ENCODER): $(PRIORITY_ENCODER)_cvr6/PASS

$(PRIORITY_ENCODER): $(PRIORITY_ENCODER)_prf1/PASS
$(PRIORITY_ENCODER): $(PRIORITY_ENCODER)_prf3/PASS
$(PRIORITY_ENCODER): $(PRIORITY_ENCODER)_prf6/PASS

$(PRIORITY_ENCODER)_cvr1/PASS: $(RTL)/$(PRIORITY_ENCODER).v $(PRIORITY_ENCODER).sby
	sby -f $(PRIORITY_ENCODER).sby cvr1
$(PRIORITY_ENCODER)_cvr3/PASS: $(RTL)/$(PRIORITY_ENCODER).v $(PRIORITY_ENCODER).sby
	sby -f $(PRIORITY_ENCODER).sby cvr3
$(PRIORITY_ENCODER)_cvr6/PASS: $(RTL)/$(PRIORITY_ENCODER).v $(PRIORITY_ENCODER).sby
	sby -f $(PRIORITY_ENCODER).sby cvr6

$(PRIORITY_ENCODER)_prf1/PASS: $(RTL)/$(PRIORITY_ENCODER).v $(PRIORITY_ENCODER).sby
	sby -f $(PRIORITY_ENCODER).sby prf1
$(PRIORITY_ENCODER)_prf3/PASS: $(RTL)/$(PRIORITY_ENCODER).v $(PRIORITY_ENCODER).sby
	sby -f $(PRIORITY_ENCODER).sby prf3
$(PRIORITY_ENCODER)_prf6/PASS: $(RTL)/$(PRIORITY_ENCODER).v $(PRIORITY_ENCODER).sby
	sby -f $(PRIORITY_ENCODER).sby prf6
clean:
	rm -rf $(addsuffix _*,$(HELPERS))


