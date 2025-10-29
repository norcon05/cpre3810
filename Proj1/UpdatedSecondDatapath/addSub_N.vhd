-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- addSub_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 
-- Adder/Subtractor with Control
--
--
-- NOTES:
-- 09/05/25 by CWM::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity addSub_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A         : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
	   i_nAdd_Sub  : in std_logic;
       o_S         : out std_logic_vector(N-1 downto 0);
	   o_Cout      : out std_logic);


end addSub_N;

architecture structural of addSub_N is

  component adder_N is
    port(i_A         : in std_logic_vector(N-1 downto 0);
         i_B         : in std_logic_vector(N-1 downto 0);
	     i_Cin 	     : in std_logic;
         o_S         : out std_logic_vector(N-1 downto 0);
	     o_Cout      : out std_logic);
  end component;
  
  component mux2t1_N is
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;
  
  component onesComp_N is
    port(i_I         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  signal s_onesCompB : std_logic_vector(N-1 downto 0);  -- Output from one's compliment of i_B
  signal s_MUXB : std_logic_vector(N-1 downto 0); -- Output from the MUX of i_B and one's-compliment of i_B
  
begin
  
  ----------------------------------------------------------------------------------------
  -- Level 0: Get the result of the One's Compliment of i_B
  ----------------------------------------------------------------------------------------
  ones_comp: onesComp_N
    port map(i_I  => i_B,
             o_O  => s_onesCompB);
			 
  -----------------------------------------------------------------------------------------
  -- Level 1: Get the result of the MUX (If 0 should output i_B, if not output one's comp.
  -----------------------------------------------------------------------------------------
  MUX2to1: mux2t1_N
    port map(i_S  => i_nAdd_Sub,
             i_D0 => i_B,
			 i_D1 => s_onesCompB,
             o_O  => s_MUXB);

  ---------------------------------------------------------------------------------
  -- Level 2: Get the result of the Adder and set the output
  ---------------------------------------------------------------------------------
  adder: adder_N
    port map(i_A    => i_A,
             i_B    => s_MUXB,
			 i_Cin  => i_nAdd_Sub,
			 o_S    => o_S,
             o_Cout => o_Cout);
  
end structural;
