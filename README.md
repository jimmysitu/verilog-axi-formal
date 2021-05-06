# verilog-axi-formal

Formal verification for [alexforencich/verilog-axi](https://github.com/alexforencich/verilog-axi) using [SymbiYosys](https://github.com/YosysHQ/SymbiYosys).

Simple usage:

1. Clone this repo and update the submodule

   ```bash
   git clone https://github.com/jimmysitu/verilog-axi-formal.git
   git submodule update --init --recursive
   ```
2. Run formal verification with SymbiYosys
   ```bash
   cd formal
   make axil_ram
   ```





