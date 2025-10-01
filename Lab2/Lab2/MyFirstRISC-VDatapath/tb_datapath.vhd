-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_datapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- RISCV-like datapath
--
--
-- NOTES:
-- 09/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_datapath is
  generic(gCLK_HPER   : time := 50 ns);
end tb_datapath;

architecture behavior of tb_datapath is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;
  constant N         : integer := 32; -- Set register width here


  component datapath
    port(i_rs1           : in std_logic_vector(4 downto 0);
         i_rs2           : in std_logic_vector(4 downto 0);
	     i_rd 	       : in std_logic_vector(4 downto 0);
	     i_imm 	       : in std_logic_vector(31 downto 0);
	     i_CLK           : in std_logic;
	     i_RST           : in std_logic;
	     i_write_enable  : in std_logic;
	     i_ALU_SRC       : in std_logic;
	     i_nAdd_Sub      : in std_logic;
         o_ALU_Result    : out std_logic_vector(31 downto 0));
  end component;

  -- Temporary signals to connect to the register component.
  signal s_iCLK, s_iRST, s_iwrite_enable, s_iALU_SRC, s_inAdd_Sub  : std_logic;
  signal s_irs1, s_irs2, s_ird                                     : std_logic_vector(4 downto 0);
  signal s_iimm, s_oALU_Result                                     : std_logic_vector(31 downto 0);
begin

  DUT: datapath
  port map(i_rs1           => s_irs1, 
           i_rs2           => s_irs2, 
	       i_rd 	       => s_ird, 
	       i_imm 	       => s_iimm, 
	       i_CLK           => s_iCLK, 
           i_RST           => s_iRST,
	       i_write_enable  => s_iwrite_enable, 
	       i_ALU_SRC       => s_iALU_SRC,
	       i_nAdd_Sub      => s_inAdd_Sub, 
           o_ALU_Result    => s_oALU_Result);

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
  -- Testbench process  
  P_TB: process
   begin

    -- Reset the datapath
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "00000";
    s_iimm           <= X"00000000";
    s_iRST           <= '1';          -- Reset
    s_iwrite_enable  <= '0';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000000

    -- Test 1: x1 = x0 + 1
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "00001";
    s_iimm           <= X"00000001";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000001

    -- Test 2: x2 = x0 + 2
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "00010";
    s_iimm           <= X"00000002";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000002

    -- Test 3: x3 = x0 + 3
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "00011";
    s_iimm           <= X"00000003";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000003

    -- Test 4: x4 = x0 + 4
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "00100";
    s_iimm           <= X"00000004";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000004

    -- Test 5: x5 = x0 + 5
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "00101";
    s_iimm           <= X"00000005";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000005

    -- Test 6: x6 = x0 + 6
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "00110";
    s_iimm           <= X"00000006";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000006

    -- Test 7: x7 = x0 + 7
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "00111";
    s_iimm           <= X"00000007";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000007

    -- Test 8: x8 = x0 + 8
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "01000";
    s_iimm           <= X"00000008";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000008

    -- Test 9: x9 = x0 + 9
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "01001";
    s_iimm           <= X"00000009";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000009

    -- Test 10: x10 = x0 + 10
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "01010";
    s_iimm           <= X"0000000A";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x0000000A

    -- Test 11: x11 = x1 + x2
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "01011";
    s_iimm           <= X"00000000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000003

    -- Test 12: x12 = x11 - x3
    s_irs1           <= "01011";
    s_irs2           <= "00011";
    s_ird            <= "01100";
    s_iimm           <= X"00000000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '1';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000000

    -- Test 13: x13 = x12 + x4
    s_irs1           <= "01100";
    s_irs2           <= "00100";
    s_ird            <= "01101";
    s_iimm           <= X"00000000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000004

    -- Test 14: x14 = x13 - x5
    s_irs1           <= "01101";
    s_irs2           <= "00101";
    s_ird            <= "01110";
    s_iimm           <= X"00000000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '1';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0xFFFFFFFF (–1 in two's complement)

    -- Test 15: x15 = x14 + x6
    s_irs1           <= "01110";
    s_irs2           <= "00110";
    s_ird            <= "01111";
    s_iimm           <= X"00000000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000005

    -- Test 16: x16 = x15 - x7
    s_irs1           <= "01111";
    s_irs2           <= "00111";
    s_ird            <= "10000";
    s_iimm           <= X"00000000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '1';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0xFFFFFFFE (–2 in two's complement)

    -- Test 17: x17 = x16 + x8
    s_irs1           <= "10000";
    s_irs2           <= "01000";
    s_ird            <= "10001";
    s_iimm           <= X"00000000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000006

    -- Test 18: x18 = x17 - x9
    s_irs1           <= "10001";
    s_irs2           <= "01001";
    s_ird            <= "10010";
    s_iimm           <= X"00000000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '1';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0xFFFFFFFD (–3 in two's complement)

    -- Test 19: x19 = x18 + x10
    s_irs1           <= "10010";
    s_irs2           <= "01010";
    s_ird            <= "10011";
    s_iimm           <= X"00000000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000007

    -- Test 20: x20 = x0 + (-35)
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "10100";
    s_iimm           <= X"FFFFFFDD";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0xFFFFFFDD

    -- Test 21: x21 = x19 + x20
    s_irs1           <= "10011";
    s_irs2           <= "10100";
    s_ird            <= "10101";
    s_iimm           <= X"00000000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0xFFFFFFE4 (–28 in two's complement)


    wait;
end process;

  
end behavior;
