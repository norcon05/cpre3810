-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- extender.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an extender
-- using both sign-extension and zero-extension (12 to 32 bit extension)
--
-- NOTES:
-- 09/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity extender is

  port (i_in  : in  STD_LOGIC_VECTOR(11 downto 0);   -- 12-bit input
        i_sel : in  STD_LOGIC;                       -- '1' = sign-extend, '0' = zero-extend
        o_out : out STD_LOGIC_VECTOR(31 downto 0));  -- 32-bit output

end extender;

architecture dataflow of extender is
  signal s_extended_zero : STD_LOGIC_VECTOR(31 downto 0);
  signal s_extended_sign : STD_LOGIC_VECTOR(31 downto 0);

begin
	-- Zero extension: pad 20 '0's to the top of input
    s_extended_zero <= (31 downto 12 => '0') & i_in;

    -- Sign extension: replicate input(11) (MSB of input) 20 times
    s_extended_sign <= (31 downto 12 => i_in(11)) & i_in;

    -- Select output based on sel
    o_out <= s_extended_sign when i_sel = '1' else s_extended_zero;
end dataflow;
