-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- IF_ID.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an IF/ID Pipeline Register
--
--
-- NOTES:
-- 11/16/25 by CWM::Created.
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity IF_ID is
  port (
    iCLK    : in  std_logic;
    iRST    : in  std_logic;

    -- Inputs from IF stage
    i_pc    : in  std_logic_vector(31 downto 0);
    i_inst  : in  std_logic_vector(31 downto 0);

    -- Outputs to ID stage
    o_pc    : out std_logic_vector(31 downto 0);
    o_inst  : out std_logic_vector(31 downto 0)
  );
end entity IF_ID;


architecture structural of IF_ID is

  component reg_N is
    generic(N : integer := 32);
    port(
      i_CLK : in  std_logic;
      i_RST : in  std_logic;
      i_WE  : in  std_logic;
      i_D   : in  std_logic_vector(N-1 downto 0);
      o_Q   : out std_logic_vector(N-1 downto 0)
    );
  end component;

begin

  -------------------------------------------------------------------
  -- PC pipeline register
  -------------------------------------------------------------------
  PC_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',        -- Always write IF/ID; no stalls in this design
      i_D   => i_pc,
      o_Q   => o_pc
    );

  -------------------------------------------------------------------
  -- Instruction pipeline register
  -------------------------------------------------------------------
  INST_REG: reg_N
    generic map(N => 32)
    port map(
      i_CLK => iCLK,
      i_RST => iRST,
      i_WE  => '1',        -- Always write IF/ID; software handles hazards
      i_D   => i_inst,
      o_Q   => o_inst
    );

end structural;
