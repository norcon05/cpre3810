-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- shiftBinary.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a shifter that 
-- handles one binary value of shift. 
--
-- For example: If we want to shift a value by 01001, (9) then two shift 
-- binary instances would be created, one for   ^  ^  the 1's value 
-- (shift by one) and the other for the 8's value (shift by eight)
--
-- NOTES:
-- 10/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shiftBinary is

  generic (N : integer := 1);                    -- Shift amount for this binary value: 1, 2, 4, 8, 16
  port (
    i_data   : in std_logic_vector(31 downto 0); -- The value we are shifting
    i_S      : in std_logic;                     -- Shift control for this binary value (from shift amount)
    i_fill   : in std_logic;                     -- Fill value (MSB or '0')
    i_dir    : in std_logic;                     -- Shift direction: '0' = right, '1' = left
    o_data   : out std_logic_vector(31 downto 0) -- The result of the shift from this binary value
  );

end shiftBinary;

architecture structure of shiftBinary is
  
  -- Describe the component entities.
  component mux2t1
    port(i_S 		                : in std_logic;
         i_D0                   : in std_logic;
         i_D1 		              : in std_logic;
         o_O 		                : out std_logic);
  end component;

  -- Signal to carry the non-shifted data
  signal s_same_data            : std_logic_vector(31 downto 0);
  -- Signal to carry the data shifted by N
  signal s_shifted_data         : std_logic_vector(31 downto 0);
begin

  ---------------------------------------------------------
  -- Create 32 Muxes to choose the next value of the data
  -- (shifted vs unshifted)
  ---------------------------------------------------------
  gen_mux_inputs: for i in 0 to 31 generate
    -- Unshifted data
    s_same_data(i) <= i_data(i);

    -- Shifted data (depends on shift left/right and i_fill if out of bounds)
    process(i_data, i_fill, i_dir)
    begin
      if i_dir = '0' then  -- Right shift
        if (i + N <= 31) then
          s_shifted_data(i) <= i_data(i + N);
        else
          s_shifted_data(i) <= i_fill;
        end if;
      else  -- Left shift
        if (i - N >= 0) then
          s_shifted_data(i) <= i_data(i - N);
        else
          s_shifted_data(i) <= '0'; -- Hard coded to 0 to prevent SLA (doesn't exist in RISC-V)
        end if;
      end if;
    end process;

    mux_inst: mux2t1
      port map (
        i_S  => i_S,
        i_D0 => s_same_data(i),
        i_D1 => s_shifted_data(i),
        o_O  => o_data(i)
      );
  end generate;


end structure;
