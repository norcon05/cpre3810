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
        i_imm20bit  : in  STD_LOGIC_VECTOR(19 downto 0);   -- 20-bit input
        i_immType   : in  STD_LOGIC;  -- Immediate Types:             
                                        -- 0: 12-bit immediate used
                                        -- 1: 20-bit immediate used
	i_branchJump    : in STD_LOGIC;			   -- '1' is branch or jump instruction, '0' is else
        i_sign      : in  STD_LOGIC;                       -- '1' = sign-extend, '0' = zero-extend
        i_upperIMM       : in  STD_LOGIC;			   -- '1' = shift upper, '0' = normal handling
        o_out       : out STD_LOGIC_VECTOR(31 downto 0));  -- 32-bit output

end extender;

architecture dataflow of extender is
  signal s_result : STD_LOGIC_VECTOR(31 downto 0);
begin

  process(i_imm12bit, i_imm20bit, i_immType, i_sign, i_upperIMM, i_branchJump)
  begin
    if i_branchJump = '1' then
      -- Handle both branch and jump using immType selector
      if i_immType = '0' then
        -- Branch immediate (12-bit, already formatted)
        if i_sign = '1' then
          s_result <= (31 downto 13 => i_imm12bit(11)) & i_imm12bit & '0'; -- shift left 1
        else
          s_result <= (31 downto 13 => '0') & i_imm12bit & '0';
        end if;
      else
        -- Jump immediate (20-bit, already formatted)
        if i_sign = '1' then
          s_result <= (31 downto 21 => i_imm20bit(19)) & i_imm20bit & '0'; -- shift left 1
        else
          s_result <= (31 downto 21 => '0') & i_imm20bit & '0';
        end if;
      end if;

    else
      -- Normal immediates (I-type, U-type, etc.)
      case i_immType is
        when '0' =>  -- 12-bit immediate
          if i_sign = '1' then
            s_result <= (31 downto 12 => i_imm12bit(11)) & i_imm12bit;
          else
            s_result <= (31 downto 12 => '0') & i_imm12bit;
          end if;

        when '1' =>  -- 20-bit immediate
          if i_upperIMM = '1' then
            s_result <= i_imm20bit & (11 downto 0 => '0');
          else
            if i_sign = '1' then
              s_result <= (31 downto 20 => i_imm20bit(19)) & i_imm20bit;
            else
              s_result <= (31 downto 20 => '0') & i_imm20bit;
            end if;
          end if;

        when others =>
          s_result <= (others => '0');
      end case;
    end if;
  end process;

  o_out <= s_result;
end dataflow;
