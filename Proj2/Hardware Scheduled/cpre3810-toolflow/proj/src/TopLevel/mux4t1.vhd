-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux4t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 4 to 1 Multiplexer
--
-- NOTES:
-- 10/17/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux4t1 is

  port(i_S 		                : in std_logic_vector(1 downto 0);
       i_D0 		            : in std_logic;
       i_D1 		            : in std_logic;
	   i_D2 		            : in std_logic;
	   i_D3 		            : in std_logic;
       o_O 		                : out std_logic);

end mux4t1;

architecture dataflow of mux4t1 is

  begin 
  
  ---------------------------------------------------------------------------------
  -- Output i_D0 when the select is 00, 
  --        i_D1 when the select is 01,
  --        i_D2 when the select is 10,
  --        i_D3 when the select is 11
  ---------------------------------------------------------------------------------
  o_O <= i_D0 when i_S = "00" else
         i_D1 when i_S = "01" else
         i_D2 when i_S = "10" else
         i_D3;  -- default when i_S = "11"
  
end dataflow;
