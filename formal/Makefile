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


RTL       := ../verilog-axi/rtl
FORMAL    := .

PRIORITY_ENCODER 		:= priority_encoder
PRIORITY_ENCODER_CASES 	:= cvr1 cvr3 cvr6 prf1 prf3 prf6
PRIORITY_ENCODER_CASES 	+= cvr1h cvr3h cvr6h prf1h prf3h prf6h

ARBITER         := arbiter
ARBITER_CASES 	:= cvr1 cvr3 cvr6 prf1 prf3 prf6
ARBITER_CASES 	+= cvr1h cvr3h cvr6h prf1h prf3h prf6h
ARBITER_CASES 	+= cvr1r cvr3r cvr6r prf1r prf3r prf6r
ARBITER_CASES 	+= cvr1a cvr3a cvr6a prf1a prf3a prf6a

HELPERS := $(PRIORITY_ENCODER) $(ARBITER)
MODULES := $(HELPERS)

# $1 = module name, $2 = test case
define run_sby =
$1_$2/PASS: $(RTL)/$1.v $(FORMAL)/f_$1.v $1.sby
	sby -f $1.sby $2
endef

all: $(MODULES)

$(foreach case,$(PRIORITY_ENCODER_CASES),$(eval $(call run_sby,$(PRIORITY_ENCODER),$(case))))
$(PRIORITY_ENCODER): $(foreach case,$(PRIORITY_ENCODER_CASES),$(PRIORITY_ENCODER)_$(case)/PASS)

$(foreach case,$(ARBITER_CASES),$(eval $(call run_sby,$(ARBITER),$(case))))
$(ARBITER): $(foreach case,$(ARBITER_CASES),$(ARBITER)_$(case)/PASS)





clean:
	rm -rf $(addsuffix _*,$(HELPERS))


