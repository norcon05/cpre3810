-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_dmem.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- memory and dmem files
--
--
-- NOTES:
-- 09/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_dmem is
  generic(gCLK_HPER   : time := 50 ns);
end tb_dmem;

architecture behavior of tb_dmem is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER   : time := gCLK_HPER * 2;
  constant cDATA_WIDTH : natural := 32;
  constant cADDR_WIDTH : natural := 10;


  component mem
    generic (DATA_WIDTH : natural := 32;
		     ADDR_WIDTH : natural := 10);
	port (clk	   : in std_logic;
		  addr	   : in std_logic_vector((ADDR_WIDTH-1) downto 0);
		  data     : in std_logic_vector((DATA_WIDTH-1) downto 0);
		  we	   : in std_logic := '1';
		  q		   : out std_logic_vector((DATA_WIDTH -1) downto 0));
  end component;

  -- Temporary signals to connect to the dff component.
  signal s_CLK, s_WE                    : std_logic;
  signal s_addr                         : std_logic_vector((cADDR_WIDTH-1) downto 0);
  signal s_data, s_q                    : std_logic_vector((cDATA_WIDTH-1) downto 0);
  signal s_r0, s_r1, s_r2, s_r3, s_r4   : std_logic_vector((cDATA_WIDTH-1) downto 0);
  signal s_r5, s_r6, s_r7, s_r8, s_r9   : std_logic_vector((cDATA_WIDTH-1) downto 0);
begin

  dmem: mem 
  port map(clk  => s_CLK, 
           addr => s_addr,
		   data => s_data,
           we   => s_WE,
           q    => s_q);

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;
  
  -- Testbench process  
  P_TB: process
  begin
	
	-------------------------------------------------------------------------------------------------
	-- STEP 1: READ ALL OF THE REGISTERS (0-9)
	-------------------------------------------------------------------------------------------------
  
    -- TEST 1: Read the memory at address 0
    s_addr <= "0000000000";
    s_data <= x"00000000";
	s_WE   <= '0';
    wait for cCLK_PER;
	s_r0 <= s_q;
	--EXPECT: q to be 0xFFFFFFFF (-1)

    -- TEST 2: Read the memory at address 1
    s_addr <= "0000000001";
    wait for cCLK_PER;
	s_r1 <= s_q;
	--EXPECT: q to be 0x00000002 (2) 
	
	-- TEST 3: Read the memory at address 2
    s_addr <= "0000000010";
    wait for cCLK_PER;
	s_r2 <= s_q;
	--EXPECT: q to be 0xFFFFFFFD (-3) 
	
	-- TEST 4: Read the memory at address 3
    s_addr <= "0000000011";
    wait for cCLK_PER;
	s_r3 <= s_q;
	--EXPECT: q to be 0x00000004 (4) 
	
	-- TEST 5: Read the memory at address 4
    s_addr <= "0000000100";
    wait for cCLK_PER;
	s_r4 <= s_q;
	--EXPECT: q to be 0x00000005 (5)
	
	-- TEST 6: Read the memory at address 5
    s_addr <= "0000000101";
    wait for cCLK_PER;
	s_r5 <= s_q;
	--EXPECT: q to be 0x00000006 (6)
	
	-- TEST 7: Read the memory at address 6
    s_addr <= "0000000110";
    wait for cCLK_PER;
	s_r6 <= s_q;
	--EXPECT: q to be 0xFFFFFFF9 (-7) 
	
	-- TEST 8: Read the memory at address 7
    s_addr <= "0000000111";
    wait for cCLK_PER;
	s_r7 <= s_q;
	--EXPECT: q to be 0xFFFFFFF8 (-8) 
	
	-- TEST 9: Read the memory at address 8
    s_addr <= "0000001000";
    wait for cCLK_PER;
	s_r8 <= s_q;
	--EXPECT: q to be 0x00000009 (9)
	
	-- TEST 10: Read the memory at address 9
    s_addr <= "0000001001";
    wait for cCLK_PER;
	s_r9 <= s_q;
	--EXPECT: q to be 0xFFFFFFF6 (-10) 


	-------------------------------------------------------------------------------------------------
	-- STEP 2: Write the read values to memory starting at address 0x100
	-------------------------------------------------------------------------------------------------
	
	-- TEST 1: Write the memory at address 0x100
	s_WE <= '1';
    s_addr <= "0100000000";
    s_data <= s_r0;
    wait for cCLK_PER;
	--EXPECT: 0xFFFFFFFF (-1) to be written to memory address: 0x00000100
	
	-- TEST 2: Write the memory at address 0x101
    s_addr <= "0100000001";
    s_data <= s_r1;
    wait for cCLK_PER;
	--EXPECT: 0x00000002 (2) to be written to memory address: 0x00000101
	
	-- TEST 3: Write the memory at address 0x102
    s_addr <= "0100000010";
    s_data <= s_r2;
    wait for cCLK_PER;
	--EXPECT: 0xFFFFFFFD (-3) to be written to memory address: 0x00000102
	
	-- TEST 4: Write the memory at address 0x103
    s_addr <= "0100000011";
    s_data <= s_r3;
    wait for cCLK_PER;
    --EXPECT: 0x00000004 (4) to be written to memory address: 0x00000103

    -- TEST 5: Write the memory at address 0x104
    s_addr <= "0100000100";
    s_data <= s_r4;
    wait for cCLK_PER;
    --EXPECT: 0x00000005 (5) to be written to memory address: 0x00000104

    -- TEST 6: Write the memory at address 0x105
    s_addr <= "0100000101";
    s_data <= s_r5;
    wait for cCLK_PER;
    --EXPECT: 0x00000006 (6) to be written to memory address: 0x00000105

    -- TEST 7: Write the memory at address 0x106
    s_addr <= "0100000110";
    s_data <= s_r6;
    wait for cCLK_PER;
    --EXPECT: 0xFFFFFFF9 (-7) to be written to memory address: 0x00000106

    -- TEST 8: Write the memory at address 0x107
    s_addr <= "0100000111";
    s_data <= s_r7;
    wait for cCLK_PER;
    --EXPECT: 0xFFFFFFF8 (-8) to be written to memory address: 0x00000107

    -- TEST 9: Write the memory at address 0x108
    s_addr <= "0100001000";
    s_data <= s_r8;
    wait for cCLK_PER;
    --EXPECT: 0x00000009 (9) to be written to memory address: 0x00000108

    -- TEST 10: Write the memory at address 0x109
    s_addr <= "0100001001";
    s_data <= s_r9;
    wait for cCLK_PER;
    --EXPECT: 0xFFFFFFF6 (-10) to be written to memory address: 0x00000109
	
	-------------------------------------------------------------------------------------------------
	-- STEP 3: Read the values at the new memory addresses to make sure they were written correctly.
	-------------------------------------------------------------------------------------------------
	
	-- TEST 1: Read the memory at address 0x100
    s_addr <= "0100000000";
    s_data <= x"00000000";
	s_WE   <= '0';
    wait for cCLK_PER;
	s_r0 <= s_q;
	--EXPECT: q to be 0xFFFFFFFF (-1)

    -- TEST 2: Read the memory at address 0x101
    s_addr <= "0100000001";
    wait for cCLK_PER;
	s_r1 <= s_q;
	--EXPECT: q to be 0x00000002 (2) 
	
	-- TEST 3: Read the memory at address 0x102
    s_addr <= "0100000010";
    wait for cCLK_PER;
	s_r2 <= s_q;
	--EXPECT: q to be 0xFFFFFFFD (-3) 
	
	-- TEST 4: Read the memory at address 0x103
    s_addr <= "0100000011";
    wait for cCLK_PER;
	s_r3 <= s_q;
	--EXPECT: q to be 0x00000004 (4) 
	
	-- TEST 5: Read the memory at address 0x104
    s_addr <= "0100000100";
    wait for cCLK_PER;
	s_r4 <= s_q;
	--EXPECT: q to be 0x00000005 (5)
	
	-- TEST 6: Read the memory at address 0x105
    s_addr <= "0100000101";
    wait for cCLK_PER;
	s_r5 <= s_q;
	--EXPECT: q to be 0x00000006 (6)
	
	-- TEST 7: Read the memory at address 0x106
    s_addr <= "0100000110";
    wait for cCLK_PER;
	s_r6 <= s_q;
	--EXPECT: q to be 0xFFFFFFF9 (-7) 
	
	-- TEST 8: Read the memory at address 0x107
    s_addr <= "0100000111";
    wait for cCLK_PER;
	s_r7 <= s_q;
	--EXPECT: q to be 0xFFFFFFF8 (-8) 
	
	-- TEST 9: Read the memory at address 0x108
    s_addr <= "0100001000";
    wait for cCLK_PER;
	s_r8 <= s_q;
	--EXPECT: q to be 0x00000009 (9)
	
	-- TEST 10: Read the memory at address 0x109
    s_addr <= "0100001001";
    wait for cCLK_PER;
	s_r9 <= s_q;
	--EXPECT: q to be 0xFFFFFFF6 (-10)
	
    wait;
  end process;
  
end behavior;
