-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- reg_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 
-- register using structural VHDL.
--
--
-- NOTES:
-- 09/20/25 by CWM::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity reg_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_CLK : in std_logic;                         -- Clock
       i_RST : in std_logic;                         -- Reset
       i_WE  : in std_logic;                         -- Write Enable
       i_D   : in std_logic_vector(N-1 downto 0);    -- Input data
       o_Q   : out std_logic_vector(N-1 downto 0));  -- Output data

end reg_N;

architecture structural of reg_N is

  component dffg is
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic;     -- Data value input
         o_Q          : out std_logic);   -- Data value output
  end component;

begin

  -- Instantiate N dffg instances.
  G_NBit_Reg: for i in 0 to N-1 generate
    RegI: dffg port map(
              i_CLK    => i_CLK,      -- All instances share the same clock.
              i_RST    => i_RST,      -- All instances share the same reset.
              i_WE     => i_WE,       -- All instances share the same write enable.
              i_D      => i_D(i),     -- ith instance's data input hooked up to ith input data.
			  o_Q      => o_Q(i));    -- ith instance's data output hooked up to ith output data.
  end generate G_NBit_Reg;
  
end structural;
