// ----------------------------------------------------------------------------
// Module:  contact.v
// Project:
// Author:  George Castillo
// Date:    22 Oct 2021
//
// Description: Heartbeat module for debug and hardware checkout purposes
//
// Usage: 
//
//   Simply instantiate the module along with an appropriate clock and
//   instantiation parameters matching the desired heartbeat characteristics.
//   The default values were intended to be paired with an 8 MHz clock and
//   yield relatively useful visual feedback to a user. It is recommended that
//   a synchronous reset be applied as well
// 
// Background:
//
//   Initial 
//   - Limitations
//   - Target platform
//
// ----------------------------------------------------------------------------

module contact #(
  // Number of clock cycles determining the duration that the output pulse is
  // held high and low
  parameter integer       PULSE_LEN_COUNT         = 32'h007A_1200,
  // Number of clock cycles between each prime number in a sequence.
  // Generally, this should be some multiple of `PULSE_LEN_COUNT` to make
  // individual prime numbers discernible
  parameter integer       INTER_PRIME_GAP         = 32'h00F4_2400,
  // Number of clock cycles between each sequence of prime numbers. Generally,
  // this should be some multiple of `INTER_PRIME_GAP` to make the sequence of
  // prime numbers obvious
  parameter integer       INTER_SEQUENCE_GAP      = 32'h01E8_4800,
  // Set this to enable an ILA core for this module if desired and supported
  // by the target technology (e.g., Xilinx)
  parameter integer       ILA_CONTACT_DEBUG       = 1'b0 
)
(
  input   wire            clk,
  // Reset synchronous to the rising edge of `clk`
  input   wire            rst,

  output  reg             prime_seq,
  // Number of prime number sequences completed since reset
  output  reg [31:0]      prime_seq_cnt
);

  localparam [31:0] NUM_PRIMES                = 32'd5;
  localparam [31:0] PRIMES [0:(NUM_PRIMES-1)] = '{ 32'd2, 32'd3, 32'd5, 32'd7, 32'd11 };

  localparam S0 = 32'd0;
  localparam S1 = 32'd1;
  localparam S2 = 32'd2;
  localparam S3 = 32'd3;
  
  // synthesis translate_off
  reg  [15:0]       prime_state_ascii;
  always @(*) begin
    case (prime_state)
      S0:      begin prime_state_ascii = "S0"; end
      S1:      begin prime_state_ascii = "S1"; end
      S2:      begin prime_state_ascii = "S2"; end
      S3:      begin prime_state_ascii = "S3"; end
      default: begin end
    endcase
  end
  // synthesis translate_on

  reg   [31:0]      pulse_cnt;
  reg   [31:0]      prime_cnt;
  reg   [31:0]      prime_idx;
  reg   [31:0]      prime_state;

  always @(posedge clk) begin
    if ( rst == 1'b1 ) begin

      prime_seq               <= 1'b0;
      prime_seq_cnt           <= 32'd0;

      pulse_cnt               <= 32'd0;  // Count from 0 to PULSE_LEN_COUNT
      prime_cnt               <= 32'd0;  // Count from 0 to N where N is the currently selected prime number to send
      prime_idx               <= 32'd0;  // Selects a prime number to send

      prime_state             <= S0;

    end else begin

      case (prime_state)

        S0: begin
          prime_seq           <= 1'b1;
          if ( pulse_cnt != ( PULSE_LEN_COUNT - 32'd1 ) ) begin
            prime_state       <= S0;
            pulse_cnt         <= pulse_cnt + 32'd1;
            prime_cnt         <= prime_cnt;
          end else begin
            if ( prime_cnt != ( PRIMES[prime_idx] - 32'd1 ) ) begin
              prime_state     <= S1;
              prime_cnt       <= prime_cnt + 32'd1;
            end else begin
              if ( prime_idx == ( NUM_PRIMES - 32'd1 ) ) begin
                prime_state   <= S3;
              end else begin
                prime_state   <= S2;
              end
              prime_cnt       <= 32'd0;
            end
            pulse_cnt         <= 32'd0;
          end
        end

        S1: begin
          prime_seq           <= 1'b0;
          prime_idx           <= prime_idx;
          if ( pulse_cnt != ( PULSE_LEN_COUNT - 32'd1 ) ) begin
            prime_state       <= S1;
            pulse_cnt         <= pulse_cnt + 32'd1;
          end else begin
            prime_state       <= S0;
            pulse_cnt         <= 32'd0;
          end
        end

        S2: begin
          prime_seq           <= 1'b0;
          prime_cnt           <= 32'd0;
          if ( pulse_cnt != ( INTER_PRIME_GAP - 32'd1 ) ) begin
            prime_state       <= S2;
            pulse_cnt         <= pulse_cnt + 32'd1;
            prime_idx         <= prime_idx;
          end else begin
            prime_state       <= S0;
            pulse_cnt         <= 32'd0;
            prime_idx         <= prime_idx + 32'd1;
          end
        end

        S3: begin
          prime_seq           <= 1'b0;
          prime_idx           <= 32'd0;
          prime_cnt           <= 32'd0;
          if ( pulse_cnt != ( INTER_SEQUENCE_GAP - 32'd1 ) ) begin
            prime_state       <= S3;
            pulse_cnt         <= pulse_cnt + 32'd1;
            prime_seq_cnt     <= prime_seq_cnt;
          end else begin
            prime_state       <= S0;
            pulse_cnt         <= 32'd0;
            prime_seq_cnt     <= prime_seq_cnt + 32'd1;
          end
        end

        default: begin end
      endcase
    end
  end

  generate
    if ( ILA_CONTACT_DEBUG == 1'b1 ) begin
      ila_contact //#(
      //)
      ila_contact_i0 (
        .clk         (clk),
        .probe0      (rst),
        .probe1      (prime_seq),
        .probe2      (prime_seq_cnt),
        .probe3      (pulse_cnt),
        .probe4      (prime_cnt),
        .probe5      (prime_idx),
        .probe6      (prime_state)
      ) /* synthesis syn_keep=1 syn_preserve=1 syn_noprune */;
    end
  endgenerate

endmodule  // contact
