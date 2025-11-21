-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- xorg2_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2-input N-Bit 
-- wide XOR gate.
--
--
-- NOTES:
-- 10/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity xorg2_N is

  generic (N : integer := 32);       -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0));

end xorg2_N;

architecture structure of xorg2_N is

  component xorg2
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

begin

  -- Instantiate N xorg2 instances.
  G_NBit_XOR: for i in 0 to N-1 generate
    XORI: xorg2 port map(
              i_A      => i_A(i),  -- ith instance's a input hooked up to ith data a input.
              i_B      => i_B(i),  -- ith instance's b input hooked up to ith data b input.
              o_F      => o_F(i)); -- ith instance's output hooked up to ith data output.
  end generate G_NBit_XOR;
  
end structure;

