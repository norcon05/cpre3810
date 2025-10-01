-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- datapath.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the RISCV-like datapath
--
--
-- NOTES:
-- 09/21/25 by CWM::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity datapath is
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
end datapath;

architecture structural of datapath is

  component addiSubi_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_A         : in std_logic_vector(N-1 downto 0);
         i_B         : in std_logic_vector(N-1 downto 0);
	     i_immediate : in std_logic_vector(N-1 downto 0);
	     i_nAdd_Sub  : in std_logic;
	     i_ALU_SRC   : in std_logic;
         o_S         : out std_logic_vector(N-1 downto 0);
	     o_Cout      : out std_logic);
  end component;
  
  component regFile is
    port(i_CLK      : in std_logic;                         -- Clock
         i_RST      : in std_logic;                         -- Reset
         i_WE       : in std_logic;                         -- Write Enable
         i_rs1_addr : in std_logic_vector(4 downto 0);      -- Address of first register we want to read
	     i_rs2_addr : in std_logic_vector(4 downto 0);      -- Address of second register we want to read
	     i_rd_addr  : in std_logic_vector(4 downto 0);      -- Address of register we want to write to
	     i_rd_data  : in std_logic_vector(31 downto 0);	  -- The data we want to write
	     o_rs1_data : out std_logic_vector(31 downto 0);    -- The data held in the first register we read
         o_rs2_data : out std_logic_vector(31 downto 0));   -- The data held in the second register we read
  end component;

  signal s_iA : std_logic_vector(31 downto 0);           -- A in the adder
  signal s_iB : std_logic_vector(31 downto 0);           -- B in the adder
  signal s_Cout : std_logic;                             -- Carry Out not needed
  signal s_oALU_Result : std_logic_vector(31 downto 0);  -- The result of the addition
begin
  RegFileInst : regFile
    port map(
      i_CLK      => i_CLK,
      i_RST      => i_RST,
      i_WE       => i_write_enable,
      i_rs1_addr => i_rs1,
      i_rs2_addr => i_rs2,
      i_rd_addr  => i_rd,
      i_rd_data  => s_oALU_Result,
      o_rs1_data => s_iA,
      o_rs2_data => s_iB
    );
	
  ALUInst : addiSubi_N
    generic map(N => 32)
    port map(
      i_A         => s_iA,
      i_B         => s_iB,
	  i_immediate => i_imm,
	  i_nAdd_Sub  => i_nAdd_Sub,
	  i_ALU_SRC   => i_ALU_SRC,
      o_S         => s_oALU_Result,
	  o_Cout      => s_Cout
    );

  o_ALU_Result <= s_oALU_Result;
  
end structural;
