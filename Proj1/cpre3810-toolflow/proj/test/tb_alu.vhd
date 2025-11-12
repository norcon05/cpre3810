-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_alu.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the ALU
--
-- NOTES:
-- 10/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_alu is
  generic(gCLK_HPER   : time := 50 ns);
end tb_alu;

architecture behavior of tb_alu is

  constant cCLK_PER  : time := gCLK_HPER * 2;
  constant N         : integer := 32; -- 32 bit width

  component alu
    generic(N : integer := 32);
    port (
    i_A         : in  std_logic_vector(N-1 downto 0); -- Operand A input
    i_B         : in  std_logic_vector(N-1 downto 0); -- Operand B input
    i_imm       : in  std_logic_vector(N-1 downto 0); -- Immediate value input (used if i_ALUSrc = '1')
    
    i_ALUOp     : in  std_logic_vector(3 downto 0);   -- ALU operation control signal:
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

    i_ALUSrc    : in  std_logic;                      -- Selects second ALU operand source:
                                                      -- '0' = i_B
                                                      -- '1' = i_imm (immediate)

    o_F         : out std_logic_vector(N-1 downto 0); -- ALU output result
    o_Zero      : out std_logic                       -- Zero flag, '1' if o_F is zero, else '0'
  );
  end component;

  -- Temporary signals to connect to the register component.
  signal s_iALUSrc, s_oZero                                        : std_logic;
  signal s_iALUop                                                  : std_logic_vector(3 downto 0);
  signal s_iA, s_iB, s_iimm, s_oF                                  : std_logic_vector(31 downto 0);
begin

  DUT: alu
  port map(i_A            => s_iA, 
           i_B            => s_iB, 
	         i_imm	        => s_iimm, 
           i_ALUOp	      => s_iALUOp,
           i_ALUSrc	      => s_iALUSrc,
           o_F            => s_oF,
		       o_Zero         => s_oZero);
   
    -- Testbench process  
    P_TB: process
  begin

    --------------------------------------------------------------------
    -- Test 1: ADD (0x00001234 + 0x00005678 = 0x000068AC)
    --------------------------------------------------------------------
    s_iA       <= x"00001234";
    s_iB       <= x"00005678";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0000";          -- ADD
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x000068AC, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 2: SUB (0x0000ABCD - 0x00004567 = 0x00006666)
    --------------------------------------------------------------------
    s_iA       <= x"0000ABCD";
    s_iB       <= x"00004567";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0001";          -- SUB
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00006666, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 3: ADDI (0x00001000 + 0x00000010 = 0x00001010)
    --------------------------------------------------------------------
    s_iA       <= x"00001000";
    s_iB       <= x"00000000";
    s_iimm     <= x"00000010";
    s_iALUSrc  <= '1';
    s_iALUOp   <= "0000";          -- ADDI
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00001010, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 4: SUBI (0x0000AAAA - 0x0000000F = 0x0000AA9B)
    --------------------------------------------------------------------
    s_iA       <= x"0000AAAA";
    s_iB       <= x"00000000";
    s_iimm     <= x"0000000F";
    s_iALUSrc  <= '1';
    s_iALUOp   <= "0001";          -- SUBI
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x0000AA9B, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 5: SLT (0xFFFFFFFE < 0x00000005 → 1)
    --------------------------------------------------------------------
    s_iA       <= x"FFFFFFFE";     -- -2
    s_iB       <= x"00000005";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0010";          -- SLT
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000001, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 6: AND (0x1234ABCD AND 0x0F0F0F0F = 0x02040B0D)
    --------------------------------------------------------------------
    s_iA       <= x"1234ABCD";
    s_iB       <= x"0F0F0F0F";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0011";          -- AND
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x02040B0D, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 7: OR (0x12340000 OR 0x0000ABCD = 0x1234ABCD)
    --------------------------------------------------------------------
    s_iA       <= x"12340000";
    s_iB       <= x"0000ABCD";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0100";          -- OR
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x1234ABCD, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 8: XOR (0x55AA55AA XOR 0x0F0F0F0F = 0x5AA55AA5)
    --------------------------------------------------------------------
    s_iA       <= x"55AA55AA";
    s_iB       <= x"0F0F0F0F";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0101";          -- XOR
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x5AA55AA5, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 9: NOR (0x12345678 NOR 0x87654321 = 0x688AA886)
    --------------------------------------------------------------------
    s_iA       <= x"12345678";
    s_iB       <= x"87654321";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0110";          -- NOR
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x688AA886, o_Zero = '0'   

    --------------------------------------------------------------------
    -- Test 10: SLL (0x00000011 << 4 = 0x00000110)
    --------------------------------------------------------------------
    s_iA       <= x"00000011";
    s_iB       <= x"00000004";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0111";          -- SLL
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000110, o_Zero = '0'    

    --------------------------------------------------------------------
    -- Test 11: SRL (0xF0000000 >> 4 = 0x0F000000)
    --------------------------------------------------------------------
    s_iA       <= x"F0000000";
    s_iB       <= x"00000004";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "1000";          -- SRL
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x0F000000, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 12: SRA (0x80000000 >> 2 = 0xE0000000)
    --------------------------------------------------------------------
    s_iA       <= x"80000000";
    s_iB       <= x"00000002";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "1001";          -- SRA
    wait for cCLK_PER;
    -- EXPECT: o_F = 0xE0000000, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 13: SLLI (0x00001234 << 3 = 0x000091A0)
    --------------------------------------------------------------------
    s_iA       <= x"00001234";
    s_iB       <= x"00000000";
    s_iimm     <= x"00000003";
    s_iALUSrc  <= '1';
    s_iALUOp   <= "1010";          -- SLLI
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x000091A0, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 14: SRLI (0x80001234 >> 3 = 0x10000246)
    --------------------------------------------------------------------
    s_iA       <= x"80001234";
    s_iB       <= x"00000000";
    s_iimm     <= x"00000003";
    s_iALUSrc  <= '1';
    s_iALUOp   <= "1011";          -- SRLI
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x10000246, o_Zero = '0'

    --------------------------------------------------------------------
    -- Test 15: SRAI (0xF0001234 >> 3 = 0xFE000246)
    --------------------------------------------------------------------
    s_iA       <= x"F0001234";
    s_iB       <= x"00000000";
    s_iimm     <= x"00000003";
    s_iALUSrc  <= '1';
    s_iALUOp   <= "1100";          -- SRAI
    wait for cCLK_PER;
    -- EXPECT: o_F = 0xFE000246, o_Zero = '0'


    --------------------------------------------------------------------
    -- Zero Flag Tests
    --------------------------------------------------------------------

    -- Z1: ADD (0x00000001 + 0xFFFFFFFF = 0x00000000)
    s_iA       <= x"00000001";
    s_iB       <= x"FFFFFFFF";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0000";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000000, o_Zero = '1'

    -- Z2: SUB (0xABCDEF01 - 0xABCDEF01 = 0x00000000)
    s_iA       <= x"ABCDEF01";
    s_iB       <= x"ABCDEF01";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0001";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000000, o_Zero = '1'

    -- Z3: SLT (5 < 3 => 0)
    s_iA       <= x"00000005";
    s_iB       <= x"00000003";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0010";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000000, o_Zero = '1'

    -- Z4: AND (0xFFFF0000 AND 0x0000FFFF = 0x00000000)
    s_iA       <= x"FFFF0000";
    s_iB       <= x"0000FFFF";
    s_iimm     <= x"00000000";
    s_iALUSrc  <= '0';
    s_iALUOp   <= "0011";
    wait for cCLK_PER;
    -- EXPECT: o_F = 0x00000000, o_Zero = '1'

    wait;
  end process;

end behavior;
