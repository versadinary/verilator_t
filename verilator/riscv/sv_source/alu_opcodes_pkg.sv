/* -----------------------------------------------------------------------------
* Project Name   : Architectures of Processor Systems (APS) lab work
* Organization   : National Research University of Electronic Technology (MIET)
* Department     : Institute of Microdevices and Control Systems
* Author(s)      : Andrei Solodovnikov
* Email(s)       : hepoh@org.miet.ru

See https://github.com/MPSU/APS/blob/master/LICENSE file for licensing details.
* ------------------------------------------------------------------------------
*/
`ifndef ALU_OPCODES_PKG
`define ALU_OPCODES_PKG
package alu_opcodes_pkg;
   localparam ALU_OP_WIDTH = 5;

   localparam ALU_ADD  = 5'b00000;
   localparam ALU_SUB  = 5'b01000;

   localparam ALU_XOR  = 5'b00100;
   localparam ALU_OR   = 5'b00110;
   localparam ALU_AND  = 5'b00111;

   // shifts
   localparam ALU_SRA  = 5'b01101;
   localparam ALU_SRL  = 5'b00101;
   localparam ALU_SLL  = 5'b00001;

   // comparisons
   localparam ALU_LTS  = 5'b11100;
   localparam ALU_LTU  = 5'b11110;
   localparam ALU_GES  = 5'b11101;
   localparam ALU_GEU  = 5'b11111;
   localparam ALU_EQ   = 5'b11000;
   localparam ALU_NE   = 5'b11001;

   // set lower than operations
   localparam ALU_SLTS = 5'b00010;
   localparam ALU_SLTU = 5'b00011;

   // multiplication and division
   localparam ALU_MUL = 5'b10000;
   localparam ALU_MULH = 5'b10001;
   localparam ALU_MULHSU = 5'b10010;
   localparam ALU_MULHU = 5'b10011;
   localparam ALU_DIV = 5'b10100;
   localparam ALU_DIVU = 5'b10101;
   localparam ALU_REM = 5'b10110;
   localparam ALU_REMU = 5'b10111;



endpackage
`endif
