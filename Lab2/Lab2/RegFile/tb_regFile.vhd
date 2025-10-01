-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_regFile.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- register file
--
--
-- NOTES:
-- 09/21/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_regFile is
  generic(gCLK_HPER   : time := 50 ns);
end tb_regFile;

architecture behavior of tb_regFile is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;

  component regFile
    port(i_CLK      : in std_logic;                         -- Clock
         i_RST      : in std_logic;                         -- Reset
         i_WE       : in std_logic;                         -- Write Enable
         i_rs1_addr : in std_logic_vector(4 downto 0);      -- Address of first register we want to read
	     i_rs2_addr : in std_logic_vector(4 downto 0);      -- Address of second register we want to read
	     i_rd_addr  : in std_logic_vector(4 downto 0);      -- Address of register we want to write to
	     i_rd_data  : in std_logic_vector(31 downto 0);	    -- The data we want to write
	     o_rs1_data : out std_logic_vector(31 downto 0);    -- The data held in the first register we read
         o_rs2_data : out std_logic_vector(31 downto 0));   -- The data held in the second register we read
  end component;

  -- Temporary signals to connect to the register component.
  signal s_iCLK, s_iRST, s_iWE  : std_logic;
  signal s_irs1_addr, s_irs2_addr, s_ird_addr : std_logic_vector(4 downto 0);
  signal s_ird_data, s_ors1_data, s_ors2_data : std_logic_vector(31 downto 0);

begin

  DUT: regFile  
  port map(i_CLK       => s_iCLK, 
           i_RST       => s_iRST,
           i_WE        => s_iWE,
           i_rs1_addr  => s_irs1_addr,
           i_rs2_addr  => s_irs2_addr,
		   i_rd_addr   => s_ird_addr,
		   i_rd_data   => s_ird_data,
		   o_rs1_data  => s_ors1_data,
		   o_rs2_data  => s_ors2_data);

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_iCLK <= '0';
    wait for gCLK_HPER;
    s_iCLK <= '1';
    wait for gCLK_HPER;
  end process;
  
  -- Testbench process  
  P_TB: process
  begin
	
    -- Test 1: Reset the register file
    s_iRST       <= '1';
    s_iWE        <= '0';
    s_irs1_addr  <= "00000";
	s_irs2_addr  <= "00000";
	s_ird_addr   <= "00000";
	s_ird_data   <= X"00000000";
    wait for cCLK_PER;
    -- EXPECT: o_rs1_data = 0x00000000 & o_rs2_data = 0x00000000
	
	-- Test 2: Write to register 1
    s_iRST       <= '0';
    s_iWE        <= '1';
    s_ird_addr   <= "00001";               -- Write to reg1
    s_ird_data   <= X"DEADBEEF";
    wait for cCLK_PER;

    -- Test 3: Read from register 1
    s_iWE        <= '0';
    s_irs1_addr  <= "00001";
    s_irs2_addr  <= "00000";              -- Should be reg0 = 0
    wait for cCLK_PER;
    -- EXPECT: o_rs1_data = 0xDEADBEEF, o_rs2_data = 0x00000000

    -- Test 4: Attempt to write to register 0 (should be ignored)
    s_iWE        <= '1';
    s_ird_addr   <= "00000";              -- Try writing to reg0
    s_ird_data   <= X"FFFFFFFF";
    wait for cCLK_PER;

    -- Test 5: Read register 0 again to confirm it's still 0
    s_iWE        <= '0';
    s_irs1_addr  <= "00000";
    wait for cCLK_PER;
    -- EXPECT: o_rs1_data = 0x00000000

    -- Test 6: Write to reg2 and reg3, read both
    s_iWE        <= '1';
    s_ird_addr   <= "00010";              -- Write to reg2
    s_ird_data   <= X"11111111";
    wait for cCLK_PER;

    s_ird_addr   <= "00011";              -- Write to reg3
    s_ird_data   <= X"22222222";
    wait for cCLK_PER;

    -- Read both
    s_iWE        <= '0';
    s_irs1_addr  <= "00010";              -- reg2
    s_irs2_addr  <= "00011";              -- reg3
    wait for cCLK_PER;
    -- EXPECT: o_rs1_data = 0x11111111, o_rs2_data = 0x22222222

    -- Test 7: Make sure reset works
    s_iRST       <= '1';
    s_iWE        <= '0';
    s_irs1_addr  <= "00010";
    s_irs2_addr  <= "00011";
    wait for cCLK_PER;
    -- EXPECT: o_rs1_data = 0x00000000 & o_rs2_data = 0x00000000
	
	-- Test 8: Write to reg5 and read it in the same cycle
	s_iRST       <= '0';
    s_iWE        <= '1';
    s_ird_addr   <= "00101";              -- Write to reg5
    s_ird_data   <= X"12345678";
    s_irs1_addr  <= "00101";              -- Read reg5 in same cycle
    wait for cCLK_PER;
    -- EXPECT: o_rs1_data = 0x12345678

	-- Test 9: Write to reg5 again to see if it updates
    s_iWE        <= '1';
    s_ird_addr   <= "00101";              -- Write to reg5
    s_ird_data   <= X"87654321";
    s_irs1_addr  <= "00101";              -- Read reg5 in same cycle
    wait for cCLK_PER;
    -- EXPECT: o_rs1_data = 0x87654321

    wait;
  end process;
  
end behavior;
