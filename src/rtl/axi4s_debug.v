module axi4s_debug #(
	// AXI4 stream parameters (all in bits)
	parameter	integer		TDATA_WIDTH			= 32,
	parameter	integer		TID_WIDTH				= 1,
	parameter	integer		TDEST_WIDTH			= 4,
	parameter	integer		TUSER_WIDTH			= 4,
	// Instrument the AXI4 stream bus with an ILA
	parameter	integer		ILA_ENABLE			= 1
)
(
	input		wire														axi4s_aclk,
	input		wire														axi4s_aresetn,
	input		wire														axi4s_tvalid,
	input		wire														axi4s_tready,
	input		wire	[(TDATA_WIDTH-1):0]				axi4s_tdata,
	input		wire	[((TDATA_WIDTH/4)-1):0]		axi4s_tstrb,
	input		wire	[((TDATA_WIDTH/4)-1):0]		axi4s_tkeep,
	input		wire														axi4s_tlast,
	input		wire	[(TID_WIDTH)-1:0]					axi4s_tid,
	input		wire	[(TDEST_WIDTH)-1:0]				axi4s_tdest,
	input		wire	[(TUSER_WIDTH)-1:0]				axi4s_tuser
);

	reg		[31:0]		axi4s_start_cnt;
	reg		[31:0]		axi4s_pkt_cnt;

	reg							axi4s_tlast_q;
	reg							axi4s_tlast_qq;
	reg 						axi4s_tlast_red;

  always @(posedge axi4s_aclk) begin
    if ( axi4s_aresetn == 1'b0 ) begin
	    axi4s_tlast_q		  <= 1'b0;
	    axi4s_tlast_qq		<= 1'b0;
	    axi4s_tlast_red		<= 1'b0;
    end else begin
      axi4s_tlast_q     <= axi4s_tlast;
      axi4s_tlast_qq    <= axi4s_tlast_q;
      if ( ( axi4s_tlast_qq === 1'b0 ) && ( axi4s_tlast_q == 1'b1) ) begin
        axi4s_tlast_red <= 1'b1;
      end else begin
        axi4s_tlast_red <= 1'b0;
      end
    end
  end

  always @(posedge axi4s_aclk) begin
		if ( axi4s_aresetn == 1'b0 ) begin
			axi4s_pkt_cnt				<= 32'd0;
    end else begin
			// Also count the number of times that tlast is asserted by the master - the
			// AXI4 stream specification has a more complicated definition of what
			// consitutes a packet boundary, but for debug purposes (particularly of
			// non-conforming master behavior) we define the packet count to be the
			// number of times that tlast was asserted after reset
      if ( axi4s_tlast_red == 1'b1 ) begin
        axi4s_pkt_cnt     <= axi4s_pkt_cnt + 32'd1;
      end else begin
        axi4s_pkt_cnt     <= axi4s_pkt_cnt;
      end
		end
  end

	always @(posedge axi4s_aclk) begin
		if ( axi4s_aresetn == 1'b0 ) begin
			axi4s_start_cnt			<= 32'd0;
		end else begin
			// We wish to count the number of transactions that are initiated by the
			// AXI4 stream master (i.e., the number of valid and ready combinations that
			// are seen by the slave).  Note that per the AXI4 stream specification, the
			// use of ready is optional by both the master and the slave.
			if ( ( axi4s_tvalid == 1'b1 ) && ( axi4s_tready == 1'b1 ) ) begin
				axi4s_start_cnt		<= axi4s_start_cnt + 32'd1;
			end else begin
				axi4s_start_cnt		<= axi4s_start_cnt;
			end
		end
	end

endmodule

