module contact_wrapper #(
  parameter integer       PULSE_LEN_COUNT         = 32'h007A_1200,
  parameter integer       INTER_PRIME_GAP         = 32'h00F4_2400,
  parameter integer       INTER_SEQUENCE_GAP      = 32'h01E8_4800,
  parameter integer       ILA_CONTACT_DEBUG       = 1'b0 
)
(
  input   wire            clk,
  input   wire            rst,
  output  wire            prime_seq,
  output  wire [31:0]     prime_seq_cnt
);

  contact #(
    .PULSE_LEN_COUNT      (PULSE_LEN_COUNT),
    .INTER_PRIME_GAP      (INTER_PRIME_GAP),
    .INTER_SEQUENCE_GAP   (INTER_SEQUENCE_GAP),
    .ILA_CONTACT_DEBUG    (ILA_CONTACT_DEBUG)
  )
  contact_i0 (
    .clk                  (clk),
    .rst                  (rst),
    .prime_seq            (prime_seq),
    .prime_seq_cnt        (prime_seq_cnt)
  );

endmodule  // contact_wrapper
