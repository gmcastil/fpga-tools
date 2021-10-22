`timescale 1ns / 1ps

module contact_tb ();

  localparam          N = 125;  // Use an 8MHz system clock for simulation purposes

  logic                clk;
  logic                rst;
  logic                prime_seq;
  logic    [31:0]      prime_seq_cnt;

  initial begin
    clk = 1'b0;
    forever begin
      #(N/2);
      clk = ~clk;
    end
  end

  initial begin
    rst = 1'b0;
    #(10*N);
    rst = 1'b1;
    #(10*N);
    rst = 1'b0;
  end

  initial begin

    $dumpfile("contact_tb.vcd");
    $dumpvars(0, contact_tb);

    #(1000*N);

    $finish();
    $stop();
  end

  contact #(
    .PULSE_LEN_COUNT          (32'd8),
    .INTER_PRIME_GAP          (32'd32),
    .INTER_SEQUENCE_GAP       (32'd128),
    .ILA_CONTACT_DEBUG        (32'd0)
  )
  contact_i0 (
    .clk                      (clk),
    .rst                      (rst),
    .prime_seq                (prime_seq),
    .prime_seq_cnt            (prime_seq_cnt)
  );

endmodule  // contact

