// ----------------------------------------------------------------------------
// Module:  porfgen.v
// Project:
// Author:  George Castillo
// Date:    01 March 2022
//
// Description: A programmable reset pulse generator for Xilinx FPGA and MPSoC
//
// Usage:
//
// Background:
//
// ----------------------------------------------------------------------------

module porfgen #(
  // Minimum length of PORF to be created in number of clock cycles
  parameter integer PORF_LEN      = 10,
  // If set to 1, add a VIO instance to allow manually cycling the reset
  parameter integer PORF_VIO      = 0,
  // Specify target device type:
  //   "7SERIES"            Xilinx 7-Series FPGA or ZYNQ 7000
  //   "ULTRASCALE"         Xilinx UltraScale
  //   "ULTRASCALE_PLUS"    UltraScale+, ZYNQ MPSoC
  //   "INFER"        
  parameter         DEVICE        = "7SERIES"
)
(
  input   wire  clk,
  // Input reset signal to be synchronized
  input   wire  async_rst,
  // Output reset signal which is asserted and deasserted synchronously to the
  // input `clk` signal.  See note discussing VIO instantiation.
  output  wire  sync_rst
);

  localparam GND = 1'b0;

  wire              rst_start;
  wire [PORF_LEN:0] rst_chain;

  assign rst_chain[0]  = GND;
  assign sync_rst = rst_chain[PORF_LEN];

  genvar i;
  generate
    // See UG974 for FDPE instantiation details. Note that default initialization
    // values for 7-Series and UltraScale devices are different
    case (DEVICE)

      "7SERIES": begin
        for (i = 0; i < PORF_LEN; i = i + 1) begin
          FDPE #(
            .INIT             (1'b1)
          )
          fdpe_i0 (
            .PRE              (rst_start),
            .D                (rst_chain[i]),
            .C                (clk),
            .CE               (1'b1),
            .Q                (rst_chain[i+1])
          );
        end
      end

      "ULTRASCALE",
      "ULTRASCALE_PLUS": begin
        for (i = 0; i < PORF_LEN; i = i + 1) begin
          FDPE #(
            .INIT             (1'b1),
            .IS_C_INVERTED    (1'b0),
            .IS_D_INVERTED    (1'b0),
            .IS_PRE_INVERTED  (1'b0)
          )
          fdpe_i0 (
            .PRE              (rst_start),
            .D                (rst_chain[i]),
            .C                (clk),
            .CE               (1'b1),
            .Q                (rst_chain[i+1])
          );
        end
      end

      default: begin end
    endcase
  endgenerate

  // Here we instantiate a VIO core if indicated and then mux its output with
  // the input async reset to drive the reset chain.  The point of these
  // shenanigans is so that the output reset signal is synchronized to the
  // rising edge of the input clock, regardless of the source (i.e., downstream
  // hardware should receive the same reset signal and timing regardless of
  // whether it was poked by the VIO or the async reset).
  generate
    if (PORF_VIO == 1) begin
      wire              vio_rst;
      assign rst_start = async_rst | vio_rst;

      vio_porfgen //#(
      //)
      vio_porfgen_i0 (
        .clk            (clk),
        .probe_in0      (async_rst),
        .probe_out0     (vio_rst)
      );

    end else begin
      assign rst_start = async_rst;
    end
  endgenerate

endmodule
