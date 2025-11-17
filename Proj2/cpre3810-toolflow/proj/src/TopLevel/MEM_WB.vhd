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
    iRST : in std_logic;

    -- Datapath inputs
    i_MEM_data   : in std_logic_vector(31 downto 0);
    i_ALU_result : in std_logic_vector(31 downto 0);
    i_rd         : in std_logic_vector(4 downto 0);

    -- Control inputs
    i_MemReg     : in std_logic;
    i_RegWr      : in std_logic;

    -- Datapath outputs
    o_MEM_data   : out std_logic_vector(31 downto 0);
    o_ALU_result : out std_logic_vector(31 downto 0);
    o_rd         : out std_logic_vector(4 downto 0);

    -- Control outputs
    o_MemReg     : out std_logic;
    o_RegWr      : out std_logic
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

begin

  -------------------------------------------------------------------
  -- Datapath registers
  -------------------------------------------------------------------

  MEM_DATA_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_MEM_data,
      o_Q   => o_MEM_data
    );

  ALU_RESULT_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_ALU_result,
      o_Q   => o_ALU_result
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

  -------------------------------------------------------------------
  -- Control registers
  -------------------------------------------------------------------

  MEMREG_REG: reg_N
    generic map(N => 1)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_MemReg,
      o_Q   => o_MemReg
    );

  REGWR_REG: reg_N
    generic map(N => 1)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',
      i_D   => i_RegWr,
      o_Q   => o_RegWr
    );

end structural;

