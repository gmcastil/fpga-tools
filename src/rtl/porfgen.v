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
  parameter integer PORF_LEN     = 10,
  // Specify target device type:
  //   "7SERIES"            Xilinx 7-Series FPGA or ZYNQ 7000
  //   "ULTRASCALE"         Xilinx UltraScale
  //   "ULTRASCALE_PLUS"    UltraScale+, ZYNQ MPSoC
  //   "INFER"        
  parameter         DEVICE       = "7SERIES"
)
(
  input   wire  clk,
  input   wire  async_rst,
  output  wire  sync_rst
);

  localparam GND = 1'b0;

  wire [PORF_LEN:0] data;

  assign data[0]  = GND;
  assign sync_rst = data[PORF_LEN];

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
          fdpe_inst (
            .PRE              (async_rst),
            .D                (data[i]),
            .C                (clk),
            .CE               (1'b1),
            .Q                (data[i+1])
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
          fdpe_inst (
            .PRE              (async_rst),
            .D                (data[i]),
            .C                (clk),
            .CE               (1'b1),
            .Q                (data[i+1])
          );
        end
      end

      default: begin end
    endcase
  endgenerate

endmodule
