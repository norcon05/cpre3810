-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- pcLogic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the fetch logic
-- required for a RISC-V processor
--
--
-- NOTES:
-- 10/17/25 by CWM::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity pcLogic is
  port(
    i_CLK          : in std_logic;                          -- Clock signal for synchronous PC updates
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
end pcLogic;


architecture structural of pcLogic is
  
  component mux4t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_S          : in std_logic_vector(1 downto 0);
         i_D0         : in std_logic_vector(31 downto 0);
         i_D1         : in std_logic_vector(31 downto 0);
		 i_D2         : in std_logic_vector(31 downto 0);
		 i_D3         : in std_logic_vector(31 downto 0);
         o_O          : out std_logic_vector(31 downto 0));
  end component;
  
  component reg_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(i_CLK : in std_logic;                         -- Clock
         i_RST : in std_logic;                         -- Reset
         i_WE  : in std_logic;                         -- Write Enable
         i_D   : in std_logic_vector(31 downto 0);    -- Input data
         o_Q   : out std_logic_vector(31 downto 0));  -- Output data
  end component;
  
  component adder_N is
    port(i_A         : in std_logic_vector(31 downto 0);
         i_B         : in std_logic_vector(31 downto 0);
	       i_Cin 	     : in std_logic;
         o_S         : out std_logic_vector(31 downto 0);
	       o_Cout      : out std_logic);
  end component;

  signal s_pc                  : std_logic_vector(31 downto 0); -- Current PC value (from the PC register)
  signal s_pc_next             : std_logic_vector(31 downto 0); -- Next PC value to load into the PC register on next clock
  signal s_pc_plus4            : std_logic_vector(31 downto 0); -- PC + 4 (default next instruction for sequential execution)
  signal s_pc_branch           : std_logic_vector(31 downto 0); -- Target address for conditional branch (PC + imm)
  signal s_jalr_target         : std_logic_vector(31 downto 0); -- Target address for JALR (rs1 + imm)
  signal s_jalr_target_aligned : std_logic_vector(31 downto 0); -- Target address for JALR with LSB cleared (byte addressable memory)
  signal s_jalr_adjusted : std_logic_vector(31 downto 0);       -- 
  signal s_PC_BA         : std_logic_vector(31 downto 0) := x"FFC00000"; -- = -0x00400000 in 2’s complement  (PC base address)

  signal s_unused_carry        : std_logic;                     -- Holds the value of the carries (not used)

begin
  -- PC register
  PC_Register : reg_N
    generic map (N => 32)
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_WE  => i_PC_WE ,
      i_D   => s_pc_next,
      o_Q   => s_pc
    );

  -- PC + 4 adder
  PC_Plus_4 : adder_N
    port map (
      i_A => s_pc,
      i_B => x"00000004",
	  i_Cin  => '0',
      o_S => s_pc_plus4,
	  o_Cout => s_unused_carry 
    );
	
  -- PC + imm (for branches or jal)
  PC_Plus_imm : adder_N
    port map (
      i_A => s_pc,
      i_B => i_imm,
	  i_Cin  => '0',
      o_S => s_pc_branch,
	  o_Cout => s_unused_carry 
    );
	
  -- rs1 + imm (for JALR)
  -- TODO: Subtract x"00400000" from this value only for JALR
  rs1_Plus_imm : adder_N
    port map (
      i_A => i_rs1,
      i_B => i_imm,
	    i_Cin  => '0',
      o_S => s_jalr_target,
	    o_Cout => s_unused_carry 
    );

  -- Target address for JALR with LSB cleared (byte addressable memory)
  s_jalr_target_aligned <= s_jalr_target and x"FFFFFFFE";

  JALR_Adjust_Subtract : adder_N
  port map (
    i_A    => s_jalr_target_aligned,
    i_B    => s_PC_BA,
    i_Cin  => '0',
    o_S    => s_jalr_adjusted,
    o_Cout => s_unused_carry
  );
  
  -- 4-to-1 Mux for PC source selection
  PC_Select_Mux : mux4t1_N
    generic map (N => 32)
    port map (
      i_S  => i_PC_SEL,
      i_D0 => s_pc_plus4,            -- 00: PC + 4
      i_D1 => s_pc_branch,           -- 01: PC + imm (Branch)
      i_D2 => s_pc_branch,           -- 10: PC + imm (JAL, same as branch)
      i_D3 => s_jalr_adjusted,       -- 11: rs1 + imm (JALR)
      o_O  => s_pc_next
    );
    

  -- Current PC value to be used by instruction memory
  o_PC <= s_pc;

end structural;
