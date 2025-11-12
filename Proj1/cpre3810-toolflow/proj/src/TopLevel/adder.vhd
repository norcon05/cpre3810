-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- adder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an adder
--
-- NOTES:
-- 09/05/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder is

  port(i_A 		                : in std_logic;
       i_B 		                : in std_logic;
       i_Cin 		            : in std_logic;
       o_S 		                : out std_logic;
	   o_Cout 		            : out std_logic);

end adder;

architecture structure of adder is
  
  -- Describe the component entities as defined in org2.vhd, invg.vhd, andg2.vhd.
  component org2
    port (i_A : in std_logic;
          i_B : in std_logic;
          o_F : out std_logic);
  end component;
  
  component xorg2
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

  component andg2
    port (i_A : in std_logic;
          i_B : in std_logic;
          o_F : out std_logic);
  end component;

  -- Signal to carry the result of the first AND Gate
  signal s_ANDAB      : std_logic;
  -- Signal to carry the result of the second AND Gate
  signal s_ANDBC      : std_logic;
  -- Signal to carry the result of the third AND Gate
  signal s_ANDAC      : std_logic;
  -- Signal to carry the result of the OR Gate
  signal s_OR         : std_logic;
  -- Signal to carry the result of the XOR Gate
  signal s_XOR        : std_logic;

begin

  ---------------------------------------------------------------------------------
  -- Level 0: Get the Cout
  ---------------------------------------------------------------------------------
 
  and_gate1: andg2
    port map(i_A => i_A,
             i_B => i_B,
             o_F => s_ANDAB);
			 
  and_gate2: andg2
    port map(i_A => i_B,
             i_B => i_Cin,
             o_F => s_ANDBC);
			 
  and_gate3: andg2
    port map(i_A => i_A,
             i_B => i_Cin,
             o_F => s_ANDAC);

  or_gate1: org2
    port map(i_A => s_ANDAB,
             i_B => s_ANDBC,
             o_F => s_OR);
			 
  or_gate2: org2
    port map(i_A => s_ANDAC,
             i_B => s_OR,
             o_F => o_Cout);


  ---------------------------------------------------------------------------------
  -- Level 1: Get the Sum
  ---------------------------------------------------------------------------------
  xor_gate1: xorg2
    port map(i_A => i_A,
             i_B => i_B,
             o_F => s_XOR);

  xor_gate2: xorg2
    port map(i_A => i_Cin,
             i_B => s_XOR,
             o_F => o_S);

  end structure;
