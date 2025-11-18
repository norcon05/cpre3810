-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- EX_MEM.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an EX/MEM Pipeline Register
--
--
-- NOTES:
-- 11/16/25 by CWM::Created.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity EX_MEM is
  port (
    iCLK : in std_logic;
    iRST : in std_logic;

    -- Datapath inputs
    i_ALU_result : in std_logic_vector(31 downto 0);
    i_rs2_data   : in std_logic_vector(31 downto 0);
    i_rd         : in std_logic_vector(4 downto 0);
    i_func3     : in std_logic_vector(2 downto 0);
    i_func7     : in std_logic_vector(6 downto 0);
    i_opcode    : in std_logic_vector(6 downto 0);

    -- Control inputs
    i_Branch     : in std_logic;
    i_MemWr      : in std_logic;
    i_MemReg     : in std_logic;
    i_RegWr      : in std_logic;
    i_Halt       : in std_logic;

    -- Datapath outputs
    o_ALU_result : out std_logic_vector(31 downto 0);
    o_rs2_data   : out std_logic_vector(31 downto 0);
    o_rd         : out std_logic_vector(4 downto 0);
    o_func3     : out std_logic_vector(2 downto 0);
    o_func7     : out std_logic_vector(6 downto 0); 
    o_opcode    : out std_logic_vector(6 downto 0);

    -- Control outputs
    o_Branch     : out std_logic;
    o_MemWr      : out std_logic;
    o_MemReg     : out std_logic;
    o_RegWr      : out std_logic;
    o_Halt       : out std_logic
  );
end entity;


architecture structural of EX_MEM is

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

begin

  -------------------------------------------------------------------
  -- Datapath registers
  -------------------------------------------------------------------

  ALU_RESULT_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_ALU_result,
      o_Q   => o_ALU_result
    );

  RS2_DATA_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_rs2_data,
      o_Q   => o_rs2_data
    );

  RD_REG: reg_N
    generic map(N => 5)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_rd,
      o_Q   => o_rd
    );

  FUNC3_REG: reg_N
    generic map(N => 3)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_func3,
      o_Q   => o_func3
    );

  FUNC7_REG: reg_N
    generic map(N => 7) 
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_func7,
      o_Q   => o_func7
    );
  
  OPCODE_REG: reg_N
    generic map(N => 7) 
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_opcode,
      o_Q   => o_opcode
    );

  -------------------------------------------------------------------
  -- Control registers
  -------------------------------------------------------------------

  BRANCH_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_Branch,
      o_Q   => o_Branch
    );

  MEMWR_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_MemWr,
      o_Q   => o_MemWr
    );

  MEMREG_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_MemReg,
      o_Q   => o_MemReg
    );

  REGWR_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_RegWr,
      o_Q   => o_RegWr
    );

  HALT_REG: dffg
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_Halt,
      o_Q   => o_Halt
    );

end structural;