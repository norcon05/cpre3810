-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- onesComp_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide
-- Ones Compliment using structural VHDL
--
--
-- NOTES:
-- 09/05/25 by CWM::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity onesComp_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_I         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

end onesComp_N;

architecture structural of onesComp_N is

  component invg
    port (i_A : in std_logic;
          o_F : out std_logic);
  end component;

begin

  -- Instantiate N not gate instances.
  G_NBit_NOT: for i in 0 to N-1 generate
    NOT_GATE: invg port map(
              i_A     =>  i_I(i),  -- ith instance's input hooked up to ith input.
              o_F     => o_O(i));  -- ith instance's output hooked up to ith output.
  end generate G_NBit_NOT;
  
end structural;
