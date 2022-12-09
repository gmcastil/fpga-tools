module mipi_rx_debug #(
  // Allowed values are 1, 2, and 4 lanes - IBUFDS primitives will be inferred
  // for Xilinx architectures
  parameter integer   MIPI_LANES  = 1,
  // Supported technologies are Xilinx UltraScale and UltraScale+ FPGA and MPSoC
  // families
  parameter           TARGET      = "ULTRASCALE"
  // For Xilinx applications that require pull-up/pull-down features or DC bias.
  // Note that all IBUFDS instances will be instaniated the same
  parameter           DQS_BIAS    = "FALSE"
)
(
  // Note that the ILA clock uses this as its input clock - this module may
  // require rework to add an external clock instead later if the lab tools
  // complain that the external clock is not present
  input   wire    mipi_rx_clk_p,
  input   wire    mipi_rx_clk_n,

  input   wire  [(MIPI_LANES-1):0]  mipi_rx_data_p,
  input   wire  [(MIPI_LANES-1):0]  mipi_rx_data_n
);

  localparam      GND   = 1'b0;

  wire                        mipi_rx_clk;
  wire  [(MIPI_LANES-1]):0]   mipi_rx_data;
  wire  [3:0]                 mipi_rx_data_dbg;

  generate
    case (TARGET)

      "ULTRASCALE": begin

        IBUFDS #(
          .DQS_BIAS     (DQS_BIAS)
        )
        IBUFDS_MIPI_CLK (
          .I            (mipi_rx_clk_p),
          .IB           (mipi_rx_clk_n),
          .O            (mipi_rx_clk)
        );

        for (int i=0; i<MIPI_LANES; i=i+1) begin

          // Wire up the single-ended signals to the ILA (we will ground any
          // unused signals to the ILA to avoid whinging by the synthesis tools)
          assign  mipi_rx_data_dbg[i] = mipi_rx_data[i];

          IBUFDS #(
            .DQS_BIAS      (DQS_BIAS)
          )
          IBUFDS_MIPI_DATA (
            .I             (mipi_rx_data_p[i]),
            .IB            (mipi_rx_data_n[i]),
            .O             (mipi_rx_data[i])
          );

        end

        // Tie off remaining debug nets to ground
        case (MIPI_LANES)

          1: begin
            mipi_rx_data_dbg[1] = GND;
            mipi_rx_data_dbg[2] = GND;
            mipi_rx_data_dbg[3] = GND;
          end

          2: begin
            mipi_rx_data_dbg[2] = GND;
            mipi_rx_data_dbg[3] = GND;
          end

          4: begin
          end

          default: begin end

        endcase // "MIPI_LANES"

      end // "ULTRASCALE"
      
      // The ILA is always instantiated assuming four serial lanes are required
      ila_mipi_rx_debug //(
      //)
      ila_mipi_rx_debug_i0 (
        .clk            (mipi_rx_clk),
        .probe0         (mipi_rx_data_dbg[0]),
        .probe1         (mipi_rx_data_dbg[1]),
        .probe2         (mipi_rx_data_dbg[2]),
        .probe3         (mipi_rx_data_dbg[3])
      );

      default: begin end

    endcase

  endgenerate

endmodule
