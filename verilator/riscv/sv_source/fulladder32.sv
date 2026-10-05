module fulladder32(
                    input logic [31:0]  a_i,
                    input logic [31:0]  b_i,
                    input logic         carry_i,
                    output logic [31:0] sum_o,
                    output logic        carry_o);
                    
    logic [7:0] c;
    assign carry_o = c[7];
    
    generate
        genvar i;
        fulladder4 fa_0(
                        .a_i(a_i[3:0]),
                        .b_i(b_i[3:0]),
                        .carry_i(carry_i),
                        .sum_o(sum_o[3:0]),
                        .carry_o(c[0])
                        );
        for (i = 4'd1; i < 4'd8; i = i + 1) begin
            fulladder4 fa_i(
                            .a_i(a_i[i * 4 + 3 : i * 4]),
                            .b_i(b_i[i * 4 + 3 : i * 4]),
                            .carry_i(c[i - 1]),
                            .sum_o(sum_o[i * 4 + 3 : i * 4]),
                            .carry_o(c[i])
            );        
        end
    
    endgenerate

endmodule
