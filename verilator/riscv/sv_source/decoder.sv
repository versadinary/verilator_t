`include "decoder_pkg.sv"
module decoder (
                input logic [31:0] fetched_instr_i,
                output logic [1:0] a_sel_o,
                output logic [2:0] b_sel_o,
                output logic [4:0] alu_op_o,
                output logic [2:0] csr_op_o,
                output logic       csr_we_o,
                output logic       mem_req_o,
                output logic       mem_we_o,
                output logic [2:0] mem_size_o,
                output logic       gpr_we_o,
                output logic [1:0] wb_sel_o,
                output logic       illegal_instr_o,
                output logic       branch_o,
                output logic       jal_o,
                output logic       jalr_o,
                output logic       mret_o
                );

   // import decoder_pkg::*;

   logic [6:0]                     opcode;
   logic [2:0]                     func3;
   logic [6:0]                     func7;

   assign opcode = fetched_instr_i[6:0];
   assign func3 = fetched_instr_i[14:12];
   assign func7 = fetched_instr_i[31:25];

   always @ (*) begin
      {a_sel_o, b_sel_o, alu_op_o, csr_op_o, csr_we_o, mem_req_o,
       mem_size_o, gpr_we_o, wb_sel_o, branch_o, jal_o, jalr_o,
       mret_o, mem_we_o} = 27'd0;
      illegal_instr_o = ~(&opcode[1:0]); // in next usages dusjunct with this vaule
      case (opcode[6:2])
        OP_OPCODE: begin
           gpr_we_o = 1'd1;
           wb_sel_o = WB_EX_RESULT;
           a_sel_o = OP_A_RS1;
           b_sel_o = OP_B_RS2;
           case (func7)
             7'b0: begin
                case (func3)
                  3'h0: alu_op_o = ALU_ADD;
                  3'h4: alu_op_o = ALU_XOR;
                  3'h6: alu_op_o = ALU_OR;
                  3'h7: alu_op_o = ALU_AND;
                  3'h1: alu_op_o = ALU_SLL;
                  3'h5: alu_op_o = ALU_SRL;
                  3'h2: alu_op_o = ALU_SLTS;
                  3'h3: alu_op_o = ALU_SLTU;
                  default: illegal_instr_o = illegal_instr_o | 1'd1;
                endcase // case (func3)
             end
             7'b0100000: begin
                case (func3)
                  3'h0: alu_op_o = ALU_SUB;
                  3'h5: alu_op_o = ALU_SRA;
                  default: illegal_instr_o = illegal_instr_o | 1'd1;
                endcase // case (func3)
             end
             default: illegal_instr_o = illegal_instr_o | 1'd1;
           endcase // case (func7)
        end
        OP_IMM_OPCODE: begin
           gpr_we_o = 1'd1;
           wb_sel_o = WB_EX_RESULT;
           a_sel_o = OP_A_RS1;
           b_sel_o = OP_B_IMM_I;
           case (func3)
             3'h0: alu_op_o = ALU_ADD;
             3'h4: alu_op_o = ALU_XOR;
             3'h6: alu_op_o = ALU_OR;
             3'h7: alu_op_o = ALU_AND;
             3'h2: alu_op_o = ALU_SLTS;
             3'h3: alu_op_o = ALU_SLTU;
             3'h1: begin
                if (func7 == 7'b0) alu_op_o = ALU_SLL;
                else illegal_instr_o = illegal_instr_o | 1'd1;
             end
             3'h5: begin
               case (func7)
                 7'b0: alu_op_o = ALU_SRL;
                 7'b0100000: alu_op_o = ALU_SRA;
                 default: illegal_instr_o = illegal_instr_o | 1'd1;
               endcase // case (func7)
             end
             default: illegal_instr_o = illegal_instr_o | 1'd1;
           endcase // case (func3)
        end
        LOAD_OPCODE: begin
           gpr_we_o = 1'd1;
           wb_sel_o = WB_LSU_DATA;
           a_sel_o = OP_A_RS1;
           b_sel_o = OP_B_IMM_I;
           mem_req_o = 1'b1;
           case (func3)
             3'h0: mem_size_o = LDST_B;
             3'h1: mem_size_o = LDST_H;
             3'h2: mem_size_o = LDST_W;
             3'h4: mem_size_o = LDST_BU;
             3'h5: mem_size_o = LDST_HU;
             default: illegal_instr_o = illegal_instr_o | 1'd1;
           endcase // case (func3)
        end
        STORE_OPCODE: begin
           a_sel_o = OP_A_RS1;
           b_sel_o = OP_B_IMM_S;
           alu_op_o = ALU_ADD;
           mem_req_o = 1'b1;
           mem_we_o = 1'b1;
           case (func3)
             3'h0: mem_size_o = LDST_B;
             3'h1: mem_size_o = LDST_H;
             3'h2: mem_size_o = LDST_W;
             default: illegal_instr_o = illegal_instr_o | 1'd1;
           endcase // case (func3)
        end
        BRANCH_OPCODE: begin
           a_sel_o = OP_A_RS1;
           b_sel_o = OP_B_RS2;
           branch_o = 1'd1;
           case (func3)
             3'h0: alu_op_o = ALU_EQ;
             3'h1: alu_op_o = ALU_NE;
             3'h4: alu_op_o = ALU_LTS;
             3'h5: alu_op_o = ALU_GES;
             3'h6: alu_op_o = ALU_LTU;
             3'h7: alu_op_o = ALU_GEU;
             default: illegal_instr_o = illegal_instr_o | 1'd1;
           endcase // case (func3)
        end
        JAL_OPCODE: begin
           a_sel_o = OP_A_CURR_PC;
           b_sel_o = OP_B_INCR;
           alu_op_o = ALU_ADD;
           gpr_we_o = 1'b1;
           jal_o = 1'd1;
        end
        JALR_OPCODE: begin
           a_sel_o = OP_A_CURR_PC;
           b_sel_o = OP_B_INCR;
           alu_op_o = ALU_ADD;
           gpr_we_o = 1'b1;
           wb_sel_o = WB_EX_RESULT;
           jalr_o = 1'd1;
           if (func3 != 3'd0) illegal_instr_o = illegal_instr_o | 1'd1;
           else illegal_instr_o = illegal_instr_o;
        end
        LUI_OPCODE: begin
           a_sel_o = OP_A_ZERO;
           b_sel_o = OP_B_IMM_U;
           alu_op_o = ALU_ADD;
           wb_sel_o = WB_EX_RESULT;
           gpr_we_o = 1'b1;
        end
        AUIPC_OPCODE: begin
           a_sel_o = OP_A_CURR_PC;
           b_sel_o = OP_B_IMM_U;
           alu_op_o = ALU_ADD;
           wb_sel_o = WB_EX_RESULT;
           gpr_we_o = 1'b1;
        end
        MISC_MEM_OPCODE: begin
           if (func3 != 0) illegal_instr_o = illegal_instr_o | 1'd1;
           else illegal_instr_o = illegal_instr_o;
        end
        SYSTEM_OPCODE: begin
           if (func3 == 3'h0) begin
              case (fetched_instr_i[31:7])
                25'd6307840: mret_o = 1'd1;
                default: illegal_instr_o = illegal_instr_o | 1'd1;
              endcase // case (fetched_instr_i[31:7])
           end
           else begin
              wb_sel_o = WB_CSR_DATA;
              csr_we_o = 1'd1;
              gpr_we_o = 1'd1;
              if (func3 <= 3'h3) a_sel_o = OP_A_RS1;
              else a_sel_o = 1'd0;
              case (func3)
                3'h1: csr_op_o = CSR_RW;
                3'h2: csr_op_o = CSR_RS;
                3'h3: csr_op_o = CSR_RC;
                3'h5: csr_op_o = CSR_RWI;
                3'h6: csr_op_o = CSR_RSI;
                3'h7: csr_op_o = CSR_RCI;
                default: illegal_instr_o = illegal_instr_o | 1'd1;
              endcase // case (func3)
           end
        end
        default: illegal_instr_o = illegal_instr_o | 1'd1;
      endcase // case (opcode)
      {a_sel_o, b_sel_o, alu_op_o, csr_op_o, csr_we_o, mem_req_o,
       mem_size_o, gpr_we_o, wb_sel_o, branch_o, jal_o, jalr_o,
       mret_o, mem_we_o} &= {27{~illegal_instr_o}};
   end

endmodule
