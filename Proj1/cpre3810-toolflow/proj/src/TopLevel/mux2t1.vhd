-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2 to 1 Multiplexer
--
-- NOTES:
-- 09/03/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux2t1 is

  port(i_S 		                : in std_logic;
       i_D0 		            : in std_logic;
       i_D1 		            : in std_logic;
       o_O 		                : out std_logic);

end mux2t1;

architecture structure of mux2t1 is
  
  -- Describe the component entities as defined in org2.vhd, invg.vhd, andg2.vhd.
  component org2
    port (i_A : in std_logic;
          i_B : in std_logic;
          o_F : out std_logic);
  end component;

  component invg
    port (i_A : in std_logic;
          o_F : out std_logic);
  end component;

  component andg2
    port (i_A : in std_logic;
          i_B : in std_logic;
          o_F : out std_logic);
  end component;

  -- Signal to carry the result of the Not Gate
  signal s_NOTS         : std_logic;
  -- Signal to carry the result of the i_D0 And Gate
  signal s_AND0        : std_logic;
  -- Signal to carry the result of the i_D1 And Gate
  signal s_AND1        : std_logic;

begin

  ---------------------------------------------------------------------------------
  -- Level 0: Get the result of the NOT gate
  ---------------------------------------------------------------------------------
 
  not_gate: invg
    port map(i_A  => i_S,
             o_F  => s_NOTS);


  ---------------------------------------------------------------------------------
  -- Level 1: Get the result of the AND gates
  ---------------------------------------------------------------------------------
  and_gate0: andg2
    port map(i_A => i_D0,
             i_B => s_NOTS,
             o_F => s_AND0);

  and_gate1: andg2
    port map(i_A => i_D1,
             i_B => i_S,
             o_F => s_AND1);
			 
  ---------------------------------------------------------------------------------
  -- Level 2: Get the result of the OR gate and set the output
  ---------------------------------------------------------------------------------

  or_gate: org2
    port map(i_A => s_AND0,
             i_B => s_AND1,
             o_F => o_O);

  end structure;
