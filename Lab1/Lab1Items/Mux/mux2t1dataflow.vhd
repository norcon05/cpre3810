-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1dataflow.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2 to 1 Multiplexer using dataflow VHDL
--
-- NOTES:
-- 09/04/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux2t1dataflow is

  port(i_S 		                : in std_logic;
       i_D0 		            : in std_logic;
       i_D1 		            : in std_logic;
       o_O 		                : out std_logic);

end mux2t1dataflow;

architecture dataflow of mux2t1dataflow is

begin

  ---------------------------------------------------------------------------------
  -- Output i_D1 when the select bit is 1, and i_D0 when the select bit is 0.
  ---------------------------------------------------------------------------------
  o_O  <= i_D1 when (i_S = '1') else i_D0;

  end dataflow;
