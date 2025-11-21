-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_pcLogic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- fetch logic required for a RISC-V processor
--
-- NOTES:
-- 10/17/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_pcLogic is
  generic(gCLK_HPER   : time := 50 ns);
end tb_pcLogic;

architecture behavior of tb_pcLogic is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;
  constant N         : integer := 32; -- Set register width here


  component pcLogic
    port(i_CLK          : in std_logic;                          -- Clock signal for synchronous PC updates
         i_RST          : in std_logic;                          -- Reset signal (typically sets PC to 0)
         i_PC_WE        : in std_logic;                          -- Enable signal for writing to PC (for wfi)
         i_rs1          : in std_logic_vector(31 downto 0);      -- Value from register rs1 (used for JALR)
         i_imm          : in std_logic_vector(31 downto 0);      -- 32-bit immediate from instruction (used in branches, JAL, JALR)
         i_PC_SEL       : in std_logic_vector(1 downto 0);       -- PC Next Value Selection: 
	                                                             -- 00: PC + 4         (Default)
                                                                 -- 01: PC + imm       (Branch)
                                                                 -- 10: PC + imm       (JAL)
                                                                 -- 11: rs1 + imm      (JALR)
         o_PC           : out std_logic_vector(31 downto 0)      -- Output: current PC value (used by instruction memory)
    );
  end component;

  -- Temporary signals to connect to the register component.
  signal s_iCLK, s_iRST, s_iPC_WE                                  : std_logic;
  signal s_iPC_SEL                                                 : std_logic_vector(1 downto 0);
  signal s_irs1, s_iimm, s_oPC                                     : std_logic_vector(31 downto 0);
begin

  DUT: pcLogic
  port map(i_CLK           => s_iCLK, 
           i_RST           => s_iRST, 
	       i_PC_WE 	       => s_iPC_WE, 
	       i_rs1 	       => s_irs1, 
	       i_imm           => s_iimm, 
           i_PC_SEL        => s_iPC_SEL,
		   o_PC            => s_oPC);

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
   
   -- Reset PC
   s_iRST         <= '1';
   s_iPC_WE       <= '1';
   s_iPC_SEL      <= "00";
   s_irs1         <= x"00000000";
   s_iimm         <= x"00000000";
   wait for cCLK_PER;
   -- EXPECT: PC = 0x00000000

   -- Test 1: PC + 4 (normal sequential execution)
   s_iRST         <= '0';
   s_iPC_WE       <= '1';
   s_iPC_SEL      <= "00";
   s_irs1         <= x"00000000";
   s_iimm         <= x"00000000";
   wait for cCLK_PER;
   -- EXPECT: PC = 0x00000004

   -- Test 2: Branch - PC + imm (imm = 0x0000000C)
   s_iRST         <= '0';
   s_iPC_WE       <= '1';
   s_iimm         <= x"0000000C";
   s_iPC_SEL      <= "01";
   s_irs1         <= x"00000000";
   wait for cCLK_PER;
   -- EXPECT: PC = 0x00000010

   -- Test 3: JAL - PC + imm (imm = -4 -> 0xFFFFFFFC)
   s_iRST         <= '0';
   s_iPC_WE       <= '1';
   s_iimm         <= x"FFFFFFFC";  -- -4 in 2's complement
   s_iPC_SEL      <= "10";
   s_irs1         <= x"00000000";
   wait for cCLK_PER;
   -- EXPECT: PC = 0x0000000C

   -- Test 4: JALR - rs1 + imm (rs1 = 0x10000000, imm = 8)
   s_iRST         <= '0';
   s_iPC_WE       <= '1';
   s_irs1         <= x"10000000";
   s_iimm         <= x"00000008";
   s_iPC_SEL      <= "11";
   wait for cCLK_PER;
   -- EXPECT: PC = 0x10000008 (aligned)

   -- Test 5: PC Write Disable (PC_WE = 0), PC should hold value
   s_iRST         <= '0';
   s_iPC_WE       <= '0';  -- Disable write
   s_iimm         <= x"00000004";
   s_irs1         <= x"11111111";
   s_iPC_SEL      <= "11";
   wait for cCLK_PER;
   -- EXPECT: PC = 0x10000008 (no change)


   wait;
end process;

  
end behavior;
