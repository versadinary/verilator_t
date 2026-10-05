module csr_controller(
                       input logic         clk_i,
                       input logic         rst_i,
                       input logic         trap_i,

                       input logic [2:0]   opcode_i,

                       input logic [11:0]  addr_i,
                       input logic [31:0]  pc_i,
                       input logic [31:0]  mcause_i,
                       input logic [31:0]  rs1_data_i,
                       input logic [31:0]  imm_data_i,
                       input logic         write_enable_i,

                       output logic [31:0] read_data_o,
                       output logic [31:0] mie_o,
                       output logic [31:0] mepc_o,
                       output logic [31:0] mtvec_o
                       );

   import csr_pkg::*;

   logic                                   mie_en;
   logic                                   mtvec_en;
   logic                                   mscratch_en;
   logic                                   mepc_en;
   logic                                   mcause_en;

   logic [31:0]                            mie_q;
   logic [31:0]                            mtvec_q;
   logic [31:0]                            mscratch_q;
   logic [31:0]                            mepc_q;
   logic [31:0]                            mcause_q;
   logic [31:0]                            reg_data;
   logic [31:0]                            csr;

   assign mie_o = mie_q;
   assign mtvec_o = mtvec_q;
   assign mepc_o = mepc_q;
   assign read_data_o = csr;

   always @ (*) begin
      case (opcode_i)
        CSR_RW: reg_data = rs1_data_i;
        CSR_RS: reg_data = rs1_data_i | csr;
        CSR_RC: reg_data = ~rs1_data_i & csr;
        CSR_RWI: reg_data = imm_data_i;
        CSR_RSI: reg_data = csr | imm_data_i;
        CSR_RCI: reg_data = csr & ~imm_data_i;
        default: reg_data = '0;
      endcase // case (opcode_i)
   end

   always @ (*) begin
      {mie_en, mtvec_en, mscratch_en, mepc_en, mcause_en} = 'd0;
      case (addr_i)
        MIE_ADDR: mie_en = write_enable_i;
        MTVEC_ADDR: mtvec_en = write_enable_i;
        MSCRATCH_ADDR: mscratch_en = write_enable_i;
        MEPC_ADDR: mepc_en = write_enable_i;
        MCAUSE_ADDR: mcause_en = write_enable_i;
      endcase // case (addr_i)
   end

   /*always @ (posedge clk_i or posedge rst_i) begin
      if (rst_i) {mie_q, mtvec_q, mscratch_q, mepc_q, mcause_q} = 'd0;
      else begin
         if (mie_en) mie_q <= reg_data;
         else mie_q <= mie_q;
         if (mtvec_en) mtvec_q <= reg_data;
         else mtvec_q <= mtvec_q;
         if (mscratch_en) mscratch_q <= reg_data;
         else mscratch_q <= mscratch_q;
         if (mepc_en | trap_i) mepc_q <= trap_i ? pc_i : reg_data;
         else mepc_q <= mepc_q;
         if (mcause_en | trap_i) mcause_q <= trap_i ? mcause_i : reg_data;
         else mcause_q <= mcause_q;
      end
   end*/
   
   always @ (posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        mie_q <= 'd0;
    end
    else if (mie_en) begin
        mie_q <= reg_data; 
    end
   end
   
   always @ (posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        mtvec_q <= 'd0;
    end
    else if (mtvec_en) begin
        mtvec_q <= reg_data; 
    end
   end
   
   always @ (posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        mscratch_q <= 'd0;
    end
    else if (mscratch_en) begin
        mscratch_q <= reg_data; 
    end
   end
   
   always @ (posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        mepc_q <= 'd0;
    end
    else if (mepc_en | trap_i) begin
        mepc_q <= trap_i ? pc_i : reg_data; 
    end
   end
   
   always @ (posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        mcause_q <= 'd0;
    end
    else if (mcause_en | trap_i) begin
        mcause_q <= trap_i ? mcause_i : reg_data;
    end
   end

   always @ (*) begin
      case (addr_i)
        MIE_ADDR: csr = mie_q;
        MTVEC_ADDR: csr = mtvec_q;
        MSCRATCH_ADDR: csr = mscratch_q;
        MEPC_ADDR: csr = mepc_q;
        MCAUSE_ADDR: csr = mcause_q;
        default: csr = 'd0;
      endcase // case (addr_i)
   end

endmodule // csr_constroller
