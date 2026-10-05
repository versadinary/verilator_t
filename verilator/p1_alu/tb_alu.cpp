#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Valu.h"
#include "Valu___024root.h"

#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;


int main()
{
    /* instantiate module ~ alu DUT(.*) */
    Valu *DUT = new Valu;

    /* set up the waveform dumping */
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC; // create trace object
    DUT->trace(m_trace, 5); // pass it to DUT, 5 - depth of the trace eg 1 - only top module
    // default to entire model
    m_trace->open("waveform.vcd");

    while (sim_time < MAX_SIM_TIME) {
       DUT->clk_i = DUT->clk_i ^ 1;
       DUT->eval();
       m_trace->dump(sim_time);
       sim_time++;
    }

    /* clean memory */
    m_trace->close();
    delete DUT;

    return 0;
}
