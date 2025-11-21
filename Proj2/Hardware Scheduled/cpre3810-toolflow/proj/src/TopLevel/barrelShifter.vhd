-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- barrelShifter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural implementation of a
-- 32-bit right barrel shifter using five instances of the shiftBinary
-- component. Each instance handles one binary bit of the shift amount:
-- shift by 1, 2, 4, 8, or 16.
--
-- Supports both logical right shift (SRL) and arithmetic right shift (SRA),
-- based on the i_arith input.
--
-- NOTES:
-- 10/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity barrelShifter is
  port (
    i_data       : in  std_logic_vector(31 downto 0); -- Input value to shift
    i_shiftAmnt  : in  std_logic_vector(4 downto 0);  -- 5-bit shift amount
    i_arith      : in  std_logic;                     -- '1' for SRA, '0' for anything else
    i_dir        : in  std_logic;                     -- '0' = right shift, '1' = left shift
    o_data       : out std_logic_vector(31 downto 0)  -- Shifted output
  );
end barrelShifter;

architecture structure of barrelShifter is

  -- Component declaration for shiftBinary
  component shiftBinary
    generic (N : integer := 1);
    port (
      i_data   : in  std_logic_vector(31 downto 0);
      i_S      : in  std_logic;
      i_fill   : in  std_logic;
      i_dir    : in  std_logic;
      o_data   : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Values after each bit of shift
  signal s_bit0Shift, s_bit1Shift, s_bit2Shift, s_bit3Shift, s_bit4Shift : std_logic_vector(31 downto 0);
  -- What to fill values that were shifted from out of bounds with
  signal s_fill : std_logic;

begin

  -- Determine fill bit based on shift type
  -- If arithmetic shift and right shift (SRA), replicate sign bit (MSB); else fill with '0'
  s_fill <= i_data(31) when (i_arith = '1' and i_dir = '0') else '0';

  -- Shift by 1 (bit 0 of shift amount)
  shift1: shiftBinary
    generic map (N => 1)
    port map (
      i_data => i_data,
      i_S    => i_shiftAmnt(0),
      i_fill => s_fill,
      i_dir  => i_dir,
      o_data => s_bit0Shift
    );

  -- Shift by 2 (bit 1)
  shift2: shiftBinary
    generic map (N => 2)
    port map (
      i_data => s_bit0Shift,
      i_S    => i_shiftAmnt(1),
      i_fill => s_fill,
      i_dir  => i_dir,
      o_data => s_bit1Shift
    );

  -- Shift by 4 (bit 2)
  shift4: shiftBinary
    generic map (N => 4)
    port map (
      i_data => s_bit1Shift,
      i_S    => i_shiftAmnt(2),
      i_fill => s_fill,
      i_dir  => i_dir,
      o_data => s_bit2Shift
    );

  -- Shift by 8 (bit 3)
  shift8: shiftBinary
    generic map (N => 8)
    port map (
      i_data => s_bit2Shift,
      i_S    => i_shiftAmnt(3),
      i_fill => s_fill,
      i_dir  => i_dir,
      o_data => s_bit3Shift
    );

  -- Shift by 16 (bit 4)
  shift16: shiftBinary
    generic map (N => 16)
    port map (
      i_data => s_bit3Shift,
      i_S    => i_shiftAmnt(4),
      i_fill => s_fill,
      i_dir  => i_dir,
      o_data => s_bit4Shift
    );

  -- Final output after all shift stages
  o_data <= s_bit4Shift;

end structure;
