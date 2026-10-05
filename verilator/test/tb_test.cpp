#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtest.h"
#include "Vtest___024root.h"

#define MAX_SIM_TIME 50
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

int main(int argc, char **argv, char** env)
{
    /* support for random values */
    Verilated::commandArgs(argc, argv);

    /* instantiate module ~ alu DUT(.*) */
    Vtest *DUT = new Vtest;

    /* set up the waveform dumping */
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC; // create trace object
    DUT->trace(m_trace, 5); // pass it to DUT, 5 - depth of the trace eg 1 - only top module
    // default to entire model
    m_trace->open("waveform.vcd");

    while (sim_time < MAX_SIM_TIME) {
        if (sim_time < 2) {
            DUT->a = 0;
            DUT->b = 0;
        }

        DUT->clk = DUT->clk ^ 1;
        DUT->eval(); // set clock, evaluate and then set signals before incrementing sim time

        /* signal changes are here */
        if (DUT->clk == 1) {
           posedge_cnt++;
           DUT->a = 0;
           DUT->b = 0;
           if (posedge_cnt == 2) {
               DUT->a = 1;
               DUT->b = 0;
           }
           if (posedge_cnt == 5) {
               DUT->a = 0;
               DUT->b = 1;
           }
           if (posedge_cnt == 10) {
               DUT->a = 1;
               DUT->b = 1;
           }
        }

        m_trace->dump(sim_time);
        sim_time++;
    }

    /* clean memory */
    m_trace->close();
    delete DUT;

    return 0;
}
