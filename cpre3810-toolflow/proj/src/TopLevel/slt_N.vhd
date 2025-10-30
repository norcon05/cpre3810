-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- slt_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an SLT 
-- (Set less than) operation.
--
--
-- NOTES:
-- 10/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity slt_N is
  generic (N : integer := 32);   -- Generic of type integer for input/output data width. Default value is 32.
  port (
    i_A : in  std_logic_vector(N-1 downto 0);
    i_B : in  std_logic_vector(N-1 downto 0);
    i_sign : in std_logic;			-- '1' for signed, '0' for unsigned
    o_F : out std_logic_vector(N-1 downto 0)); -- 0x0 --> i_A >= i_B
                                               -- 0x1 --> i_A < i_B
end slt_N;

architecture dataflow of slt_N is
begin
  process(i_A, i_B, i_sign)
  begin
    if i_sign = '1' then
      -- Signed comparison
      if (signed(i_A) < signed(i_B)) then
        o_F <= (others => '0');
        o_F(0) <= '1';
      else
        o_F <= (others => '0');
      end if;
    else
      -- Unsigned comparison
      if (unsigned(i_A) < unsigned(i_B)) then
        o_F <= (others => '0');
        o_F(0) <= '1';
      else
        o_F <= (others => '0');
      end if;
    end if;
  end process;
end dataflow;
