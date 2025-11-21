-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_barrelShifter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- barrelShifter that will be a part of the ALU
--
-- NOTES:
-- 10/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_barrelShifter is
  generic(gCLK_HPER   : time := 50 ns);
end tb_barrelShifter;

architecture behavior of tb_barrelShifter is

  constant cCLK_PER  : time := gCLK_HPER * 2;

  component barrelShifter
    port (i_data       : in  std_logic_vector(31 downto 0); -- Input value to shift
          i_shiftAmnt  : in  std_logic_vector(4 downto 0);  -- 5-bit shift amount
          i_arith      : in  std_logic;                     -- '1' for SRA, '0' for anything else
          i_dir        : in  std_logic;                     -- '0' = right shift, '1' = left shift
          o_data       : out std_logic_vector(31 downto 0)  -- Shifted output
    );
  end component;

  -- Temporary signals to connect to the register component.
  signal s_iarith, s_dir                                           : std_logic;
  signal s_ishiftAmnt                                              : std_logic_vector(4 downto 0);
  signal s_idata, s_odata                                          : std_logic_vector(31 downto 0);
begin

  DUT: barrelShifter
  port map(i_data            => s_idata, 
           i_shiftAmnt       => s_ishiftAmnt, 
	         i_arith 	         => s_iarith, 
	         i_dir	           => s_dir, 
		       o_data            => s_odata);
   
    -- Testbench process  
  P_TB: process
  begin

    -- Test 1: Logical Left Shift (Shift 0x00000001 by 1 to the left)
    s_idata      <= x"00000001";
    s_ishiftAmnt <= "00001";       -- shift by 1
    s_iarith     <= '0';           -- not arithmetic (ignored for left shift)
    s_dir        <= '1';           -- left shift
    wait for cCLK_PER;
    -- EXPECT: o_data = 0x00000002

    -- Test 2: Logical Right Shift (Shift 0x80000000 by 1 to the right)
    s_idata      <= x"80000000";
    s_ishiftAmnt <= "00001";
    s_iarith     <= '0';           -- logical
    s_dir        <= '0';           -- right shift
    wait for cCLK_PER;
    -- EXPECT: o_data = 0x40000000

    -- Test 3: Arithmetic Right Shift (Shift 0x80000000 by 1 to the right)
    s_idata      <= x"80000000";   -- MSB = 1
    s_ishiftAmnt <= "00001";
    s_iarith     <= '1';           -- arithmetic shift
    s_dir        <= '0';           -- right shift
    wait for cCLK_PER;
    -- EXPECT: o_data = 0xC0000000

    -- Test 4: Shift by 0 (Should return original input)
    s_idata      <= x"DEADBEEF";
    s_ishiftAmnt <= "00000";
    s_iarith     <= '1';           -- doesn't matter
    s_dir        <= '0';           -- right shift
    wait for cCLK_PER;
    -- EXPECT: o_data = 0xDEADBEEF

    -- Test 5: Left Shift by 4 (Make sure arethmetic shift left doesn't work)
    s_idata      <= x"0000000F";
    s_ishiftAmnt <= "00100";       -- shift by 4
    s_iarith     <= '1';           -- Shouldn't matter
    s_dir        <= '1';           -- left
    wait for cCLK_PER;
    -- EXPECT: o_data = 0x000000F0

    wait;
  end process;


  
end behavior;
