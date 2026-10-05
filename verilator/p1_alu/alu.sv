module alu #(parameter WIDTH = 8)
   (
    input logic              clk_i,
    input logic              rst_i,
    input logic              op_type_i,
    input logic [WIDTH-1:0]  op_a_i,
    input logic [WIDTH-1:0]  op_b_i,
    input logic              valid_i,

    output logic [WIDTH-1:0] res_o,
    output logic             valid_res_o
    );

   logic op_type_ff;
   logic [WIDTH-1:0] op_a_ff;
   logic [WIDTH-1:0] op_b_ff;
   logic             valid_ff;
   logic [WIDTH-1:0] res;

   always_ff @ (posedge clk_i or posedge rst_i) begin
      if (rst_i) begin
         op_type_ff <= 'd0;
         op_a_ff    <= 'd0;
         op_b_ff    <= 'd0;
         valid_ff   <= 'd0;
      end
      else begin
         op_type_ff <= op_type_i;
         op_a_ff    <= op_a_i;
         op_b_ff    <= op_b_i;
         valid_ff   <= valid_i;
      end
   end

   always_comb begin
      res = 'd0;
      if (valid_ff) begin
         res = op_type_ff ? op_a_ff + op_b_ff : op_a_ff - op_b_ff;
      end
   end

   always_ff @ (posedge clk_i or posedge rst_i) begin
      if (rst_i) begin
         res_o       <= 'd0;
         valid_res_o <= 'd0;
      end
      else begin
         res_o       <= res;
         valid_res_o <= valid_ff;
      end
   end


endmodule
