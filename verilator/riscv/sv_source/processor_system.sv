// `include "decoder_pkg.sv"
// `include "peripheral_pkg.sv"
module processor_system
  (
   input logic         clk_i,
   input logic         resetn_i,

   // Входы и выходы периферии
   input logic [15:0]  sw_i,      // Переключатели

   output logic [15:0] led_o,     // Светодиоды

   input logic         kclk_i,    // Тактирующий сигнал клавиатуры
   input logic         kdata_i,   // Сигнал данных клавиатуры

   output logic [6:0]  hex_led_o, // Вывод семисегментных индикаторов
   output logic [ 7:0] hex_sel_o, // Селектор семисегментных индикаторов

   input logic         rx_i,      // Линия приёма по UART
   output logic        tx_o,      // Линия передачи по UART

   output logic [3:0]  vga_r_o,   // Красный канал vga
   output logic [3:0]  vga_g_o,   // Зелёный канал vga
   output logic [3:0]  vga_b_o,   // Синий канал vga
   output logic        vga_hs_o,  // Линия горизонтальной синхронизации vga
   output logic        vga_vs_o   // Линия вертикальной синхронизации vga

   );

   // import decoder_pkg::*;
   // import peripheral_pkg::*;

   logic sysclk, rst;
   assign sysclk = clk_i;

  /* sys_clk_rst_gen divider (
      .ex_clk_i(clk_i),
      .ex_areset_n_i(resetn_i),
      .div_i(5),
      .sys_clk_o(sysclk),
      .sys_reset_o(rst)
  ); */



   logic stall, stall_tg, mwe, mreq;
   logic [31:0] rom_addr;
   logic [31:0] rom_ins;
   logic [31:0] mwd, maddr, mrd;
   logic [2:0]  msize;
   logic        lsu_req, lsu_we, ready;
   logic [3:0]  lsu_be;
   logic [31:0] lsu_wd, addr, lsu_rd;
   logic        irq_req, irq_ret;
   logic [31:0] dmem_rd, hex_rd, ps2_rd, tim_rd, ua_tx;
   logic [255:0] ohe;
   logic         rst_bl;
   logic [31:0]  bl_instr_wdata_o;
   logic [31:0]  bl_instr_addr_o;
   logic         bl_instr_we_o;
   logic [31:0]  bl_wdata_o;
   logic [31:0]  bl_daddr_o;
   logic         bl_data_we_o;
   logic [31:0]  vga_rd;

   logic [7:0]   uart_tx_data;
   logic         tx_o_bl;
   logic         tx_o_dev;

   assign tx_o = rst_bl ? tx_o_bl : tx_o_dev;

   logic rx_bluster;

   assign rx_bluster = rst_bl ? rx_i : 1'bz;

   logic req;

   assign req = rst_bl ? bl_data_we_o : lsu_req;

   logic write_enable;

   assign write_enable = rst_bl ? bl_data_we_o : lsu_we;

   logic [3:0] byte_enable;

   assign byte_enable = rst_bl ? 4'hf : lsu_be;

   logic [31:0] write_data;

   assign write_data = rst_bl ? bl_wdata_o : lsu_wd;

   logic [31:0] mem_addr;
   assign mem_addr = rst_bl ? bl_daddr_o : addr;
   assign ohe = 255'd1 << mem_addr[31:24];
   assign led_o[0] = rst_bl;
   logic ua_rx_dev;
   logic [31:0] ua_rx;
   assign ua_rx_dev = rst_bl ? 1'bz : rx_i;


   processor_core core_inst
     (
      .clk_i(sysclk),
      .rst_i(rst_bl),
      .stall_i(stall),
      .instr_i(rom_ins),
      .mem_rd_i(mrd),
      .irq_req_i(irq_req),

      .instr_addr_o(rom_addr),
      .mem_addr_o(maddr),
      .mem_size_o(msize),
      .mem_req_o(mreq),
      .mem_we_o(mwe),
      .mem_wd_o(mwd),
      .irq_ret_o(irq_ret)
      );

   lsu lsu_main
     (
      .clk_i(sysclk),
      .rst_i(rst),
      .core_req_i(mreq),
      .core_we_i(mwe),
      .core_size_i(msize),
      .core_addr_i(maddr),
      .core_wd_i(mwd),
      .core_rd_o(mrd),
      .core_stall_o(stall),
      .mem_req_o(lsu_req),
      .mem_we_o(lsu_we),
      .mem_be_o(lsu_be),
      .mem_addr_o(addr),
      .mem_wd_o(lsu_wd),
      .mem_rd_i(lsu_rd),
      .mem_ready_i(  /* ready */ 1'b1)
      );


   rw_instr_mem imem
     (
      .clk_i(sysclk),
      .read_addr_i(rom_addr),
      .read_data_o(rom_ins),
      .write_addr_i(bl_instr_addr_o),
      .write_data_i(bl_instr_wdata_o),
      .write_enable_i(bl_instr_we_o)
      );


   bluster prg
     (
      .clk_i(sysclk),
      .rst_i(rst),
      .rx_i(rx_bluster),
      .tx_o(tx_o_bl),
      .instr_addr_o(bl_instr_addr_o),
      .instr_wdata_o(bl_instr_wdata_o),
      .instr_we_o(bl_instr_we_o),
      .data_addr_o(bl_daddr_o),
      .data_wdata_o(bl_wdata_o),
      .data_we_o(bl_data_we_o),
      .core_reset_o(rst_bl)
      );


   data_mem dmem
    (
     .clk_i(sysclk),
     .mem_req_i(req & ohe[DMEM_ADDR_HIGH]),
     .write_enable_i(write_enable),
     .byte_enable_i(byte_enable),
     .addr_i({8'd0, mem_addr[23:0]}),
     .write_data_i(write_data),
     .read_data_o(dmem_rd),
     .ready_o(ready)
     );


   hex_sb_ctrl hex
    (
     .clk_i(sysclk),
     .rst_i(rst),
     .addr_i({8'd0, mem_addr[23:0]}),
     .req_i(req & ohe[HEX_ADDR_HIGH]),
     .write_data_i(write_data),
     .write_enable_i(write_enable),
     .read_data_o(hex_rd),
     .hex_led(hex_led_o),
     .hex_sel(hex_sel_o)
     );

   ps2_sb_ctrl ps2
    (
     .clk_i(sysclk),
     .rst_i(rst),
     .addr_i({8'd0, mem_addr[23:0]}),
     .req_i(req & ohe[PS2_ADDR_HIGH]),
     .write_data_i(write_data),
     .write_enable_i(write_enable),
     .read_data_o(ps2_rd),
     .interrupt_request_o(),
     .interrupt_return_i(),
     .kclk_i(kclk_i),
     .kdata_i(kdata_i)
     );

   timer_sb_ctrl timer
     (
     .clk_i(sysclk),
     .rst_i(rst_bl),
     .req_i(req & ohe[TIMER_ADDR_HIGH]),
     .write_enable_i(write_enable),
     .addr_i({8'd0, mem_addr[23:0]}),
     .write_data_i(write_data),
     .read_data_o(tim_rd),
     .ready_o(),
     .interrupt_request_o(/*irq_req*/)
     );

   uart_tx_sb_ctrl uart_tx
     (
      .clk_i(sysclk),
      .rst_i(rst),
      .addr_i({8'd0, mem_addr[23:0]}),
      .req_i(req & ohe[TX_ADDR_HIGH]),
      .write_data_i(write_data),
      .write_enable_i(write_enable),
      .read_data_o(ua_tx),
      .tx_o(tx_o_dev)
      );


   uart_rx_sb_ctrl uart_rx
    (
     .clk_i(sysclk),
     .rst_i(rst),
     .addr_i({8'd0, mem_addr[23:0]}),
     .req_i(req & ohe[RX_ADDR_HIGH]),
     .write_data_i(write_data),
     .write_enable_i(write_enable),
     .read_data_o(ua_rx),
     .rx_i(ua_rx_dev),
     .interrupt_request_o(irq_req),
     .interrupt_return_i(irq_ret)
     );

   vga_sb_ctrl VGA
     (
      .clk_i         (sysclk),
      .rst_i         (rst),
      .clk100m_i     (clk_i),
      .req_i         (req & ohe[VGA_ADDR_HIGH]),
      .write_enable_i(write_enable),
      .mem_be_i      (byte_enable),
      .addr_i        ({8'd0, mem_addr[23:0]}),
      .write_data_i  (write_data),
      .read_data_o   (vga_rd),
      .vga_r_o       (vga_r_o),
      .vga_g_o       (vga_g_o),
      .vga_b_o       (vga_b_o),
      .vga_hs_o      (vga_hs_o),
      .vga_vs_o      (vga_vs_o)
      );



   always @(*) begin
     case (mem_addr[31:24])
       DMEM_ADDR_HIGH: lsu_rd = dmem_rd;
       HEX_ADDR_HIGH: lsu_rd = hex_rd;
       PS2_ADDR_HIGH: lsu_rd = ps2_rd;
       TIMER_ADDR_HIGH: lsu_rd = tim_rd;
       TX_ADDR_HIGH: lsu_rd = ua_tx;
       RX_ADDR_HIGH: lsu_rd = ua_rx;
       VGA_ADDR_HIGH: lsu_rd = vga_rd;
       default: lsu_rd = 'd0;
     endcase
   end


endmodule
