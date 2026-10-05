module interrupt_controller(
                            input logic         clk_i,
                            input logic         rst_i,
                            input logic         exception_i,
                            input logic         irq_req_i,
                            input logic         mie_i,
                            input logic         mret_i,

                            output logic        irq_ret_o,
                            output logic [31:0] irq_cause_o,
                            output logic        irq_o
                            );


   logic                                        exc_h_d;
   logic                                        irq_h_d;
   logic                                        exc_h_q;
   logic                                        irq_h_q;
   logic                                        irq_out;
   logic                                        exc_set;
   logic                                        exc_rst;
   logic                                        irq_set;
   logic                                        irq_rst;

   assign exc_set = exc_h_q | exception_i;
   assign exc_rst = exc_set & ~mret_i;
   assign irq_set = irq_h_q | irq_out;
   assign irq_rst = irq_set & ~(mret_i & ~exc_set);

   assign exc_h_d = exc_rst;
   assign irq_h_d = irq_rst;

   assign irq_out = ~(exc_set | irq_h_q) & (irq_req_i & mie_i);
   assign irq_ret_o = mret_i & ~exc_set;
   assign irq_o = irq_out;
   assign irq_cause_o = 32'h8000_0010;

   always @ (posedge clk_i or posedge rst_i) begin
      if (rst_i) begin
         exc_h_q <= 1'd0;
         irq_h_q <= 1'd0;
      end
      else begin
         exc_h_q <= exc_h_d;
         irq_h_q <= irq_h_d;
      end
   end

endmodule
