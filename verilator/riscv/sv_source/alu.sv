`include "alu_opcodes_pkg.sv"
module alu(
           input logic [31:0]  a_i,
           input logic [31:0]  b_i,
           input logic [4:0]   alu_op_i,
           output logic        flag_o,
           output logic [31:0] result_o
           );

   // import alu_opcodes_pkg::*;
   logic                        carry_o;
   logic [31:0] sum;

   fulladder32 add_sub32(
                         .a_i(a_i),
                         .b_i(b_i),
                         .carry_i(1'd0),
                         .sum_o(sum),
                         .carry_o(carry_o)
                         );

   always @ (*) begin
      flag_o = 1'd0;
      case (alu_op_i)
        ALU_ADD:
          result_o = sum;
        ALU_SUB:
          result_o = $signed(a_i) - $signed(b_i);
        ALU_XOR:
          result_o = a_i ^ b_i;
        ALU_OR:
          result_o = a_i | b_i;
        ALU_AND:
          result_o = a_i & b_i;
        ALU_SRA:
          result_o = $signed(a_i) >>> b_i[4:0];
        ALU_SRL:
          result_o = a_i >> b_i[4:0];
        ALU_SLL:
          result_o = a_i << b_i[4:0];
        ALU_SLTS:
          result_o = $signed(a_i) < $signed(b_i);
        default:
          result_o = 32'd0;
      endcase

      case (alu_op_i)
        ALU_EQ:
          flag_o = (a_i == b_i);
        ALU_NE:
          flag_o = (a_i != b_i);
        ALU_LTS:
          flag_o = ($signed(a_i) < $signed(b_i));
        ALU_GES:
          flag_o = ($signed(a_i) >= $signed(b_i));
        ALU_LTU:
          flag_o = (a_i < b_i);
        ALU_GEU:
          flag_o = (a_i >= b_i);
        default:
          flag_o = 1'd0;
      endcase
   end

endmodule
