-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_datapath2.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- second RISCV-like datapath
--
--
-- NOTES:
-- 09/23/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_datapath2 is
  generic(gCLK_HPER   : time := 50 ns);
end tb_datapath2;

architecture behavior of tb_datapath2 is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;
  constant N         : integer := 32; -- Set register width here


  component datapath2
    port(i_rs1           : in std_logic_vector(4 downto 0);
         i_rs2           : in std_logic_vector(4 downto 0);
	     i_rd 	       : in std_logic_vector(4 downto 0);
	     i_imm 	       : in std_logic_vector(11 downto 0);
	     i_CLK           : in std_logic;
	     i_RST           : in std_logic;
	     i_write_enable  : in std_logic;
	     i_ALU_SRC       : in std_logic;   -- Second value in ALU (0 - rs2, 1 - immediate)
	     i_nAdd_Sub      : in std_logic;   -- Add or Sub (0 - add, 1 - sub)
	     i_sign          : in std_logic;   -- Extension of Immediate (0 - zero extended, 1 - sign extended)
	     i_MemWrite      : in std_logic;   -- Can Write to memory?
	     i_MemToReg      : in std_logic;   -- Choose rd data (0 - ALU Result, 1 - Memory output)
         o_ALU_Result    : out std_logic_vector(31 downto 0); -- Output result of ALU for testing
	     o_rd_data       : out std_logic_vector(31 downto 0)); -- Output the data getting written to rd for testing
  end component;

  -- Temporary signals to connect to the register component.
  signal s_iCLK, s_iRST, s_iwrite_enable, s_iALU_SRC, s_inAdd_Sub  : std_logic;
  signal s_isign, s_iMemWrite, s_iMemToReg                         : std_logic;
  signal s_irs1, s_irs2, s_ird                                     : std_logic_vector(4 downto 0);
  signal s_ord_data, s_oALU_Result                                 : std_logic_vector(31 downto 0);
  signal s_iimm                                                    : std_logic_vector(11 downto 0);
begin

  DUT: datapath2
  port map(i_rs1           => s_irs1, 
           i_rs2           => s_irs2, 
	       i_rd 	       => s_ird, 
	       i_imm 	       => s_iimm, 
	       i_CLK           => s_iCLK, 
           i_RST           => s_iRST,
	       i_write_enable  => s_iwrite_enable, 
	       i_ALU_SRC       => s_iALU_SRC,
	       i_nAdd_Sub      => s_inAdd_Sub,
		   i_sign          => s_isign,
		   i_MemWrite      => s_iMemWrite,
		   i_MemToReg      => s_iMemToReg,
           o_ALU_Result    => s_oALU_Result,
		   o_rd_data       => s_ord_data);

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
    s_iimm           <= X"000";
    s_iRST           <= '1';          -- Reset
    s_iwrite_enable  <= '0';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
	s_isign          <= '0';
	s_iMemWrite      <= '0';
	s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0x00000000
	
	-- Test 1: addi x25, x25, 0
    s_irs1           <= "11001";
    s_irs2           <= "00000";
    s_ird            <= "11001";
    s_iimm           <= X"000";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000000

    -- Test 2: addi x26, x26, 256
    s_irs1           <= "11010";
    s_irs2           <= "00000";
    s_ird            <= "11010";
    s_iimm           <= X"100";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000100

    -- Test 3: lw x1, 0(x25)
    s_irs1           <= "11001";
    s_irs2           <= "00000";
    s_ird            <= "00001";
    s_iimm           <= X"000";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '1';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0xFFFFFFFF

    -- Test 4: lw x2, 4(x25)
    s_irs1           <= "11001";
    s_irs2           <= "00000";
    s_ird            <= "00010";
    s_iimm           <= X"004";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '1';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0x00000002

    -- Test 5: add x1, x1, x2
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "00001";
    s_iimm           <= X"000";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0x00000001

    -- Test 6: sw x1, 0(x26)
    s_irs1           <= "11010";
    s_irs2           <= "00001";
    s_ird            <= "00000";
    s_iimm           <= X"000";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '0';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '1';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: Mem[0x10010100] = 0xFFFFFFFE

    -- Test 7: lw x2, 8(x25)
    s_irs1           <= "11001";
    s_irs2           <= "00000";
    s_ird            <= "00010";
    s_iimm           <= X"008";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '1';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0xFFFFFFFD

    -- Test 8: add x1, x1, x2
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "00001";
    s_iimm           <= X"000";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0xFFFFFFFE (-3 + 1 = -2)

    -- Test 9: sw x1, 4(x26)
    s_irs1           <= "11010";
    s_irs2           <= "00001";
    s_ird            <= "00000";
    s_iimm           <= X"004";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '0';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '1';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: Mem[0x10010104] = 0x00000006

    -- Test 10: lw x2, 12(x25)
    s_irs1           <= "11001";
    s_irs2           <= "00000";
    s_ird            <= "00010";
    s_iimm           <= X"00C";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '1';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0x00000004
	
    -- Test 11: add x1, x1, x2
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "00001";
    s_iimm           <= X"000";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0x0000000A

    -- Test 12: sw x1, 8(x26)
    s_irs1           <= "11010";
    s_irs2           <= "00001";
    s_ird            <= "00000";
    s_iimm           <= X"008";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '0';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '1';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: Mem[0x10010108] = 0x0000000A

    -- Test 13: lw x2, 16(x25)
    s_irs1           <= "11001";
    s_irs2           <= "00000";
    s_ird            <= "00010";
    s_iimm           <= X"010";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '1';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0x00000005

    -- Test 14: add x1, x1, x2
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "00001";
    s_iimm           <= X"000";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0x0000000F

    -- Test 15: sw x1, 12(x26)
    s_irs1           <= "11010";
    s_irs2           <= "00001";
    s_ird            <= "00000";
    s_iimm           <= X"00C";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '0';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '1';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: Mem[0x1001010C] = 0x0000000F

    -- Test 16: lw x2, 20(x25)
    s_irs1           <= "11001";
    s_irs2           <= "00000";
    s_ird            <= "00010";
    s_iimm           <= X"014";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '1';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0x00000006

    -- Test 17: add x1, x1, x2
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "00001";
    s_iimm           <= X"000";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0x00000015

    -- Test 18: sw x1, 16(x26)
    s_irs1           <= "11010";
    s_irs2           <= "00001";
    s_ird            <= "00000";
    s_iimm           <= X"010";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '0';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '1';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: Mem[0x10010110] = 0x00000015

    -- Test 19: lw x2, 24(x25)
    s_irs1           <= "11001";
    s_irs2           <= "00000";
    s_ird            <= "00010";
    s_iimm           <= X"018";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '1';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0x00000007

    -- Test 20: add x1, x1, x2
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "00001";
    s_iimm           <= X"000";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_rd_data = 0x0000001C

    -- Test 21: addi x27, x27, 512
    s_irs1           <= "11011";
    s_irs2           <= "00000";
    s_ird            <= "11011";
    s_iimm           <= X"200";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000200

    -- Test 22: sw x1, -4(x27)
    s_irs1           <= "11011";
    s_irs2           <= "00001";
    s_ird            <= "00000";
    s_iimm           <= X"FFC";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '0';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '1'; -- Important: for negative offset
    s_iMemWrite      <= '1';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: Mem[0x100101FC] = 0x0000001C

    -- Test 23: sw x1, -4(x27)
    s_irs1           <= "11011";
    s_irs2           <= "00001";
    s_ird            <= "00000";
    s_iimm           <= X"FFC";
	s_iRST           <= '0'; 
    s_iwrite_enable  <= '0';
    s_iALU_SRC       <= '1';
    s_inAdd_Sub      <= '0';
    s_isign          <= '1';
    s_iMemWrite      <= '1';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: Mem[0x100101FC] = 0x0000001C (unchanged)

    wait;
end process;

  
end behavior;
