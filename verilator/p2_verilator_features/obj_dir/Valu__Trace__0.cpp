// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Valu__Syms.h"


void Valu___024root__trace_chg_0_sub_0(Valu___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Valu___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root__trace_chg_0\n"); );
    // Init
    Valu___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Valu___024root*>(voidSelf);
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Valu___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Valu___024root__trace_chg_0_sub_0(Valu___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root__trace_chg_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[1U])) {
        bufp->chgBit(oldp+0,(vlSelfRef.alu__DOT__op_type_ff));
        bufp->chgCData(oldp+1,(vlSelfRef.alu__DOT__op_a_ff),8);
        bufp->chgCData(oldp+2,(vlSelfRef.alu__DOT__op_b_ff),8);
        bufp->chgBit(oldp+3,(vlSelfRef.alu__DOT__valid_ff));
        bufp->chgCData(oldp+4,(vlSelfRef.alu__DOT__res),8);
    }
    bufp->chgBit(oldp+5,(vlSelfRef.clk_i));
    bufp->chgBit(oldp+6,(vlSelfRef.rst_i));
    bufp->chgBit(oldp+7,(vlSelfRef.op_type_i));
    bufp->chgCData(oldp+8,(vlSelfRef.op_a_i),8);
    bufp->chgCData(oldp+9,(vlSelfRef.op_b_i),8);
    bufp->chgBit(oldp+10,(vlSelfRef.valid_i));
    bufp->chgCData(oldp+11,(vlSelfRef.res_o),8);
    bufp->chgBit(oldp+12,(vlSelfRef.valid_res_o));
}

void Valu___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu___024root__trace_cleanup\n"); );
    // Init
    Valu___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Valu___024root*>(voidSelf);
    Valu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
}
