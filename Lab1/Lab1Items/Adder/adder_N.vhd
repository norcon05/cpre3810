-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- adder_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 
-- ripple-carry adder
--
--
-- NOTES:
-- 09/05/25 by CWM::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity adder_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A         : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
	   i_Cin 	   : in std_logic;
       o_S         : out std_logic_vector(N-1 downto 0);
	   o_Cout      : out std_logic);

end adder_N;

architecture structural of adder_N is

  component adder is
    port(i_A 		            : in std_logic;
         i_B 		            : in std_logic;
         i_Cin 		            : in std_logic;
         o_S 		            : out std_logic;
	     o_Cout 		        : out std_logic);
  end component;

  signal s_carry : std_logic_vector(N downto 0);  -- Carry bits
begin
  carry(0) <= i_Cin;  -- Initial carry-in

  -- Instantiate N adder instances.
  G_NBit_ADDER: for i in 0 to N-1 generate
    ADDER_I: adder port map(
           i_A    => i_A(i),
           i_B    => i_B(i),
           i_Cin  => s_carry(i),
           o_S    => o_S(i),
           o_Cout => s_carry(i+1)
    );
  end generate G_NBit_ADDER;
  
  o_Cout <= s_carry(N); -- Final carry-out 
  
end structural;
