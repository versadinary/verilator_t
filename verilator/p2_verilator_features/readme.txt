PART 2
* set makefile rules to quickly compile build and simulte 
* verilator is 2 state simulator: all defaults to 0s - no Xs and Zs
* we can change it by initializing all signals to random value so we can check if reset signal work
* `Verilated::gotFinish()` checks if `$finish()` called from verilog testbench
* set clock to 1, evaluate to create positive edge, then set inputs/check outputs BEFORE dumping and incrementing sim time
* on the next posedge inside while loop the inputs set previously will propagate into the design during DUT->eval() and
then right after eval the inputs should be reset to their default values
