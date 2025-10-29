-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- extender.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an extender
-- using both sign-extension and zero-extension
--
-- NOTES:
-- 09/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity extender is

  port (i_imm12bit  : in  STD_LOGIC_VECTOR(11 downto 0);   -- 12-bit input
        i_imm13bit  : in  STD_LOGIC_VECTOR(12 downto 0);   -- 13-bit input
        i_imm20bit  : in  STD_LOGIC_VECTOR(19 downto 0);   -- 20-bit input
        i_immType   : in  STD_LOGIC_VECTOR(1 downto 0);    -- Immediate Types:
                                                              -- 00: No immediate used (output 0)
                                                              -- 01: 12-bit immediate used
                                                              -- 10: 13-bit immediate used
                                                              -- 11: 20-bit immediate used

        i_sign      : in  STD_LOGIC;                       -- '1' = sign-extend, '0' = zero-extend
        o_out       : out STD_LOGIC_VECTOR(31 downto 0));  -- 32-bit output

end extender;

aarchitecture dataflow of extender is
  signal s_result : STD_LOGIC_VECTOR(31 downto 0);
begin

  process(i_imm12bit, i_imm13bit, i_imm20bit, i_immType, i_sign)
  begin
    case i_immType is
      when "00" =>  -- No immediate used
        s_result <= (others => '0');

      when "01" =>  -- 12-bit immediate
        if i_sign = '1' then
          s_result <= (31 downto 12 => i_imm12bit(11)) & i_imm12bit;
        else
          s_result <= (31 downto 12 => '0') & i_imm12bit;
        end if;

      when "10" =>  -- 13-bit immediate
        if i_sign = '1' then
          s_result <= (31 downto 13 => i_imm13bit(12)) & i_imm13bit;
        else
          s_result <= (31 downto 13 => '0') & i_imm13bit;
        end if;

      when others =>  -- "11" => 20-bit immediate
        if i_sign = '1' then
          s_result <= (31 downto 20 => i_imm20bit(19)) & i_imm20bit;
        else
          s_result <= (31 downto 20 => '0') & i_imm20bit;
        end if;
    end case;
  end process;

  o_out <= s_result;

end dataflow;
