library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity porfgen is
  generic (
    -- Number of clocks to hold the synchronous reset after deassertion of
    -- asynchronous reset.  Will result in an additional N - 1 FDPE instances
    -- after synthesis.  Only supported in UltraScale+ for now.
    constant DEASSERT_DELAY : integer := 8
  );
  port (
    clk        : in  std_logic;
    arst       : in  std_logic;
    rst        : out std_logic;
    rstn       : out std_logic
  );
end porfgen;

architecture Xilinx of porfgen is

  signal cascade    : std_logic_vector(0 to (DEASSERT_DELAY - 1));
  signal cascaden   : std_logic_vector(0 to (DEASSERT_DELAY - 1));
  
begin

  cascade(0)      <= '0';
  rst             <= cascade(cascade'right);

  -- Create a synchronous active high reset with the appropriate number
  -- of delays after deassertion
  rst_chain : for i in 1 to (cascade'length - 1) generate
  begin
    FDPE_i : FDPE
      generic map (
        INIT            => '1',
        IS_C_INVERTED   => '0',
        IS_D_INVERTED   => '0',
        IS_PRE_INVERTED => '0'
      )
      port map (
        D               => cascade(i-1),
        C               => clk,
        CE              => '1',
        PRE             => arst,
        Q               => cascade(i)
      );
  end generate rst_chain;

  cascaden(0)     <= '1';
  rstn            <= cascaden(cascaden'right);

  -- Create a synchronous active low reset with the appropriate number
  -- of delays after deassertion (do not just invert the active high reset)
  rstn_chain : for j in 1 to (cascaden'length - 1) generate
  begin
    FDPE_j : FDPE
      generic map (
        INIT            => '0',
        IS_C_INVERTED   => '0',
        IS_D_INVERTED   => '0',
        IS_PRE_INVERTED => '1'
      )
      port map (
        D               => cascaden(j-1),
        C               => clk,
        CE              => '1',
        PRE             => not arst,
        Q               => cascaden(j)
      );
  end generate rstn_chain;

end Xilinx;
