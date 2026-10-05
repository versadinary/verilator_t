module test(
            input logic clk,
            input logic  a,
            input logic  b,
            output logic res
            );

   logic res1;

   sub1 mod1 (
              .a(a),
              .b(b),
              .res(res1)
              );

     assign res = ~res1;

endmodule
