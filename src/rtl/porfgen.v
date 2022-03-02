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
  parameter integer PORF_LEN     = 10
)
(
  input   wire  clk,
  input   wire  async_rst,
  output  wire  sync_rst
);

  wire [PORF_LEN:0] data;

  assign data[0]  = 1'b0;
  assign sync_rst = data[PORF_LEN];

  genvar i;
  for (i = 0; i < PORF_LEN; i = i + 1) begin
    FDPE #(
      .INIT       (1'b0)
    )
    fdpe_inst (
      .PRE        (async_rst),
      .D          (data[i]),
      .C          (clk),
      .CE         (1'b1),
      .Q          (data[i+1])
    );
  end

endmodule
