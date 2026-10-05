module timer_sb_ctrl(
/*
    Часть интерфейса модуля, отвечающая за подключение к системной шине
*/
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        req_i,
  input  logic        write_enable_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] write_data_i,
  output logic [31:0] read_data_o,
  output logic        ready_o,
/*
    Часть интерфейса модуля, отвечающая за отправку запросов на прерывание
    процессорного ядра
*/
  output logic        interrupt_request_o
);

    logic [63:0] system_counter;
    logic [63:0] delay;
    enum logic [1:0] {OFF, NTIMES, FOREVER} mode, next_mode;
    logic [31:0] repeat_counter;
    logic [63:0] system_counter_at_start;
    logic rst;
    assign rst = req_i && write_enable_i && (addr_i[7:0] == 8'h24) && (write_data_i[0] == 1'b1);
    assign ready_o = 1'b1;

    /* system_counter */

    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            system_counter <= 'd0;
        end
        else if (rst) begin
            system_counter <= 'd0;
        end
        else begin
            system_counter <= system_counter + 1;
        end
    end

    /* ~system_counter */

    /* delay */

    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            delay <= 'd0;
        end
        else if (rst) begin
            delay <= 'd0;
        end
        else if (req_i && write_enable_i) begin
            case (addr_i[7:0])
                8'h08: delay[31:0] <= write_data_i;
                8'h0c: delay[63:32] <= write_data_i;
                default: delay <= delay;
            endcase
        end
    end

    /* ~delay */

    /* mode fsm */

    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            mode <= OFF;
        end
        else if (rst) begin
            mode <= OFF;
        end
        else begin
            mode <= next_mode;
        end
    end

    always_comb begin
        if (req_i && write_enable_i && (addr_i[7:0] == 8'h10)) begin
            case (write_data_i[1:0])
                2'h0: next_mode = OFF;
                2'h1: begin
                    next_mode = NTIMES;
                end
                2'h2: begin
                    next_mode = FOREVER;
                end
                default: next_mode = OFF;
            endcase
        end
        else if ((mode == NTIMES) && !repeat_counter) begin
            next_mode = OFF;
        end
        else begin
            next_mode = mode;
        end
    end

    /* ~mode fsm */

    /* repeat counter */

    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            repeat_counter <= 'd0;
        end
        else if (rst) begin
            repeat_counter <= 'd0;
        end
        else if (req_i && write_enable_i) begin
            if (addr_i[7:0] == 8'h14) begin
                repeat_counter <= write_data_i;
            end
        end
        else if (repeat_counter) begin
            repeat_counter <=  repeat_counter - (system_counter_at_start + delay == system_counter);
        end
        else begin
            repeat_counter <= repeat_counter;
        end
    end

    /* ~rpt counter */

    /* system_counter_at_start */

    /*always_comb begin
        if ((system_counter_at_start + delay == system_counter) && (repeat_counter != 1) && mode == NTIMES) begin
            system_counter_at_start = system_counter;
        end
        else if (req_i && write_enable_i && (addr_i[7:0] == 8'h10) && (write_data_i != 0)) begin
            system_counter_at_start = system_counter;
        end
        else if ((system_counter_at_start + delay == system_counter) && mode == FOREVER) begin
            system_counter_at_start = system_counter;
        end
    end*/
    
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            system_counter_at_start <= 'd0;
        end
        else if (rst) begin
            system_counter_at_start <= 'd0;
        end
        else if ((mode != OFF) && (system_counter_at_start + delay == system_counter)) begin
            system_counter_at_start <= system_counter;
        end
        else if (req_i && write_enable_i && (addr_i[7:0] == 8'h10)) begin
            system_counter_at_start <= system_counter;
        end
    end
    

    /* ~system_counter_at_start */

    /* interrupt_request_o */

    // assign interrupt_request_o = ((mode != OFF) && system_counter_at_start + delay == system_counter);
    /*always_comb begin
        if (mode != OFF) begin
            if (system_counter_at_start + delay == system_counter) begin
               interrupt_request_o = 1'b1;
            end
            else begin
               interrupt_request_o = 1'b0;
            end
        end
        else if (rst | rst_i) begin
            interrupt_request_o = 'd0;
        end
    end*/
    
    assign interrupt_request_o = (system_counter_at_start + delay == system_counter) && (mode != OFF);

    /* ~interrupt_request_o */

    /* read_data_o */

    always_ff @(posedge clk_i) begin
            case (addr_i[7:0])
                8'h00: read_data_o <= system_counter[31:0];
                8'h04: read_data_o <= system_counter[63:32];
                8'h08: read_data_o <= delay[31:0];
                8'h0c: read_data_o <= delay[63:32];
                8'h10: read_data_o <= mode;
                8'h14: read_data_o <= repeat_counter;
                default: read_data_o <= 32'h0;
            endcase
    end

    /* ~read_data_o */


endmodule
