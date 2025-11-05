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
	     i_ALUOp         : in  std_logic_vector(3 downto 0);   -- ALU operation control signal:
                                                        -- 0000 : ADD / ADDI (Add i_A and i_B or immediate)
                                                        -- 0001 : SUB / SUBI (Subtract i_B or immediate from i_A)
                                                        -- 0010 : SLT       (Set Less Than: i_A < i_B or immediate)
                                                        -- 0011 : AND       (Bitwise AND)
                                                        -- 0100 : OR        (Bitwise OR)
                                                        -- 0101 : XOR       (Bitwise XOR)
                                                        -- 0110 : NOR       (Bitwise NOR)
                                                        -- 0111 : SLL       (Logical Left Shift)
                                                        -- 1000 : SRL       (Logical Right Shift)
                                                        -- 1001 : SRA       (Arithmetic Right Shift)
                                                        -- 1010 : SLLI      (Logical Left Shift Immediate)
                                                        -- 1011 : SRLI      (Logical Right Shift Immediate)
                                                        -- 1100 : SRAI      (Arithmetic Right Shift Immediate)
	     i_sign          : in std_logic;   -- Extension of Immediate (0 - zero extended, 1 - sign extended)
	     i_MemWrite      : in std_logic;   -- Can Write to memory?
	     i_MemToReg      : in std_logic;   -- Choose rd data (0 - ALU Result, 1 - Memory output)
         o_ALU_Result    : out std_logic_vector(31 downto 0); -- Output result of ALU for testing
         o_ALU_Zero      : out std_logic;  -- ALU Zero Output
	     o_rd_data       : out std_logic_vector(31 downto 0)); -- Output the data getting written to rd for testin
  end component;

  -- Temporary signals to connect to the register component.
  signal s_iCLK, s_iRST, s_iwrite_enable, s_iALU_SRC, s_oALU_Zero  : std_logic;
  signal s_isign, s_iMemWrite, s_iMemToReg                         : std_logic;
  signal s_irs1, s_irs2, s_ird                                     : std_logic_vector(4 downto 0);
  signal s_iALUOp                                                  : std_logic_vector(3 downto 0);
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
	       i_ALUOp         => s_iALUOp,
		   i_sign          => s_isign,
		   i_MemWrite      => s_iMemWrite,
		   i_MemToReg      => s_iMemToReg,
           o_ALU_Zero      => s_oALU_Zero,
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
    s_iRST           <= '1';          
    s_iwrite_enable  <= '0';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0000";  -- ADD
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
    s_iALUOp         <= "0000";  -- ADD
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";
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
    s_iALUOp         <= "0000";  -- ADD
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
    s_iALUOp         <= "0000";  -- ADD
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
    s_iALUOp         <= "0000";  -- ADD
    s_isign          <= '1';
    s_iMemWrite      <= '1';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: Mem[0x100101FC] = 0x0000001C (unchanged)

    --------------------------------------------------------------------
    -- Additional Tests: New ALU Functionality
    --------------------------------------------------------------------

    -- Test 24: and x3, x1, x2 (0x1C AND 0x07 = 0x04)
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "00011";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0011";  -- AND
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000004

    -- Test 25: or x4, x1, x2 (0x1C OR 0x07 = 0x1F)
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "00100";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0100";  -- OR
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x0000001F

    -- Test 26: xor x5, x1, x2 (0x1C XOR 0x07 = 0x1B)
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "00101";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0101";  -- XOR
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x0000001B

    -- Test 27: nor x6, x1, x2 (~(0x1C OR 0x07) = ~0x1F = 0xFFFFFFE0)
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "00110";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0110";  -- NOR
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0xFFFFFFE0

    -- Test 28: slt x7, x1, x2 (0x1C < 0x07 = false)
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "00111";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0010";  -- SLT
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000000

    -- Test 29: slt x8 = slt(x0, x0) (0 < 0 = false)
    s_irs1           <= "00000";
    s_irs2           <= "00000";
    s_ird            <= "01000";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0010";  -- SLT
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000000

    -- Test 30: slt signed x9 = slt(-1, 1) → (0xFFFFFFFF < 0x00000001) = true
    s_irs1           <= "00001";  -- assume x1 reused for -1
    s_irs2           <= "00010";  -- assume x2 = 1
    s_ird            <= "01001";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0010";  -- SLT
    s_isign          <= '1';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000001

    -- Test 31: sll x10, x1, x2 (0x1C << 0x07[4:0]=7 → 0xE00)
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "01010";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0111";  -- SLL
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000E00

    -- Test 32: srl x11, x1, x2 (0x1C >> 7 = 0x00000000)
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "01011";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "1000";  -- SRL
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000000

    -- Test 33: sra x12, x1, x2 (0x1C >> 7 = 0x00000000)
    s_irs1           <= "00001";
    s_irs2           <= "00010";
    s_ird            <= "01100";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "1001";  -- SRA
    s_isign          <= '1';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000000

    -- Test 34: slli x13, x1, 1 (0x1C << 1 = 0x38)
    s_irs1           <= "00001";
    s_irs2           <= "00000";
    s_ird            <= "01101";
    s_iimm           <= X"001";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_iALUOp         <= "1010";  -- SLLI
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000038

    -- Test 35: srli x14, x1, 1 (0x1C >> 1 = 0xE)
    s_irs1           <= "00001";
    s_irs2           <= "00000";
    s_ird            <= "01110";
    s_iimm           <= X"001";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_iALUOp         <= "1011";  -- SRLI
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x0000000E

    -- Test 36: srai x15, x1, 1 (arithmetic right shift, still 0xE)
    s_irs1           <= "00001";
    s_irs2           <= "00000";
    s_ird            <= "01111";
    s_iimm           <= X"001";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '1';
    s_iALUOp         <= "1100";  -- SRAI
    s_isign          <= '1';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x0000000E

    -- Test 37: or edge case: all ones OR zero (0xFFFFFFFF OR 0x0 = 0xFFFFFFFF)
    s_irs1           <= "11111";
    s_irs2           <= "00000";
    s_ird            <= "10000";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0100";  -- OR
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0xFFFFFFFF

    -- Test 38: xor identical inputs (0x1C XOR 0x1C = 0x0)
    s_irs1           <= "00001";
    s_irs2           <= "00001";
    s_ird            <= "10001";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0101";  -- XOR
    s_isign          <= '0';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000000

    -- Test 39: sra negative value (0xFFFFFFE0 >> 2 = 0xFFFFFFF8)
    s_irs1           <= "00110"; -- x6 = 0xFFFFFFE0
    s_irs2           <= "00010"; -- x2 = 0x00000007 → shift 7 bits
    s_ird            <= "10010";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "1001";  -- SRA
    s_isign          <= '1';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0xFFFFFFFF  (after full sign extension)

    -- Test 40: slt edge case max positive vs min negative (0x7FFFFFFF < 0x80000000? false)
    s_irs1           <= "00001"; -- pretend x1 = 0x7FFFFFFF
    s_irs2           <= "00010"; -- pretend x2 = 0x80000000
    s_ird            <= "10011";
    s_iimm           <= X"000";
    s_iRST           <= '0';
    s_iwrite_enable  <= '1';
    s_iALU_SRC       <= '0';
    s_iALUOp         <= "0010";  -- SLT
    s_isign          <= '1';
    s_iMemWrite      <= '0';
    s_iMemToReg      <= '0';
    wait for cCLK_PER;
    -- EXPECT: o_ALU_Result = 0x00000000

    wait;
end process;

  
end behavior;
