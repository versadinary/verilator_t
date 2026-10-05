* convert verilog modules into behavior models in CPP
* only clocked modules, verilator doesnt detect combinatorial logic and propagation delays
* `verilator --cc my_module.sv` verilate module
* `Valu.h` - primary design header which contains converted module class definition - V<module_name>
this is what we instantiate in our cpp testbench as the DUT
* `Valu_024unit.h` - internal header for module class and contains types definitions
* verilator only converts verilog to cpp and create build instructions for Make
* the simulator in this case is cpp testbench itself
* regenerate makefile : `verilator -Wall --trace -cc alu.sv --exe tb_alu.cpp`
* build executable from source: `make -C obj_dir -f Valu.mk Valu`
* results are in the obj_dir directory as executable file
