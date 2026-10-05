#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Valu.h"
#include "Valu___024root.h"

#define MAX_SIM_TIME 50
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;



int main(int argc, char **argv, char** env)
{
    /* support for random values */
    Verilated::commandArgs(argc, argv);

    /* instantiate module ~ alu DUT(.*) */
    Valu *DUT = new Valu;

    /* set up the waveform dumping */
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC; // create trace object
    DUT->trace(m_trace, 5); // pass it to DUT, 5 - depth of the trace eg 1 - only top module
    // default to entire model
    m_trace->open("waveform.vcd");

    while (sim_time < MAX_SIM_TIME) {
        DUT->rst_i = 0;
        if (sim_time < 2) {
            DUT->rst_i = 1;
            DUT->op_type_i = 0;
            DUT->op_a_i = 0;
            DUT->op_b_i = 0;
            DUT->valid_i = 0;
        }

        DUT->clk_i = DUT->clk_i ^ 1;
        DUT->eval(); // set clock, evaluate and then set signals before incrementing sim time

        if (DUT->clk_i == 1) {
            DUT->valid_i = 0;
            posedge_cnt++;
            if (posedge_cnt == 5) DUT->valid_i = 1;
        }

        m_trace->dump(sim_time);
        sim_time++;
    }

    /* clean memory */
    m_trace->close();
    delete DUT;

    return 0;
}
