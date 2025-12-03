-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MEM_WB.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an MEM_WB Pipeline Register
--
--
-- NOTES:
-- 11/16/25 by CWM::Created.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity MEM_WB is
  port (
    iCLK : in std_logic;
    iFLush : in std_logic;
    iStall : in std_logic;
    iRST : in std_logic;

    -- Datapath inputs
    i_MEM_data   : in std_logic_vector(31 downto 0);
    i_ALU_result : in std_logic_vector(31 downto 0);
    i_rd         : in std_logic_vector(4 downto 0);
    i_func3     : in std_logic_vector(2 downto 0);
    i_func7     : in std_logic_vector(6 downto 0);
    i_opcode    : in std_logic_vector(6 downto 0);

    -- Control inputs
    i_MemReg     : in std_logic;
    i_RegWr      : in std_logic;
    i_Halt       : in std_logic;

    -- Datapath outputs
    o_MEM_data   : out std_logic_vector(31 downto 0);
    o_ALU_result : out std_logic_vector(31 downto 0);
    o_rd         : out std_logic_vector(4 downto 0);
    o_func3     : out std_logic_vector(2 downto 0);
    o_func7     : out std_logic_vector(6 downto 0);
    o_opcode    : out std_logic_vector(6 downto 0);

    -- Control outputs
    o_MemReg     : out std_logic;
    o_RegWr      : out std_logic;
    o_Halt       : out std_logic
  );
end entity;


architecture structural of MEM_WB is

  component reg_N is
    generic(N : integer := 32);
    port(
      i_CLK : in std_logic;
      i_RST : in std_logic;
      i_WE  : in std_logic;
      i_D   : in std_logic_vector(N-1 downto 0);
      o_Q   : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component dffg is
    port(
      i_CLK : in std_logic;
      i_RST : in std_logic;
      i_WE  : in std_logic;
      i_D   : in std_logic;
      o_Q   : out std_logic
    );
  end component;

  signal s_MEM_data_in   : std_logic_vector(31 downto 0);
  signal s_ALU_result_in : std_logic_vector(31 downto 0);
  signal s_rd_in         : std_logic_vector(4 downto 0);
  signal s_func3_in      : std_logic_vector(2 downto 0);
  signal s_func7_in      : std_logic_vector(6 downto 0);
  signal s_opcode_in     : std_logic_vector(6 downto 0);
  signal s_MemReg_in     : std_logic;
  signal s_RegWr_in      : std_logic;
  signal s_Halt_in       : std_logic;

begin

  -------------------------------------------------------------------
  -- Datapath registers
  -------------------------------------------------------------------

  s_MEM_data_in <= (others => '0') when iFlush = '1' else i_MEM_data;

  MEM_DATA_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_MEM_data_in,
      o_Q   => o_MEM_data
    );

  s_ALU_result_in <= (others => '0') when iFlush = '1' else i_ALU_result;

  ALU_RESULT_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_ALU_result_in,
      o_Q   => o_ALU_result
    );

  s_rd_in <= (others => '0') when iFlush = '1' else i_rd;

  RD_REG: reg_N
    generic map(N => 5)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_rd_in,
      o_Q   => o_rd
    );

  s_func3_in <= (others => '0') when iFlush = '1' else i_func3;
  
  FUNC3_REG: reg_N
    generic map(N => 3)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_func3_in,
      o_Q   => o_func3
    );

  s_func7_in <= (others => '0') when iFlush = '1' else i_func7;

  FUNC7_REG: reg_N
    generic map(N => 7)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_func7_in,
      o_Q   => o_func7
    );

  s_opcode_in <= (others => '0') when iFlush = '1' else i_opcode;

  OPCODE_REG: reg_N
    generic map(N => 7)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_opcode_in,
      o_Q   => o_opcode
    );

  -------------------------------------------------------------------
  -- Control registers
  -------------------------------------------------------------------

  s_MemReg_in <= '0' when iFlush = '1' else i_MemReg;

  MEMREG_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_MemReg_in,
      o_Q   => o_MemReg
    );

  s_RegWr_in <= '0' when iFlush = '1' else i_RegWr;

  REGWR_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_RegWr_in,
      o_Q   => o_RegWr
    );
  
  s_Halt_in <= '0' when iFlush = '1' else i_Halt;

  HALT_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => not iStall,
      i_D   => s_Halt_in,
      o_Q   => o_Halt
    );

end structural;