-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_reg_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- N-bit register
--
--
-- NOTES:
-- 09/20/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_reg_N is
  generic(gCLK_HPER   : time := 50 ns);
end tb_reg_N;

architecture behavior of tb_reg_N is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;
  constant N         : integer := 32; -- Set register width here


  component reg_N
    generic(N : integer := 32);
    port(i_CLK : in std_logic;                         -- Clock
         i_RST : in std_logic;                         -- Reset
         i_WE  : in std_logic;                         -- Write Enable
         i_D   : in std_logic_vector(N-1 downto 0);    -- Input data
         o_Q   : out std_logic_vector(N-1 downto 0));  -- Output data
  end component;

  -- Temporary signals to connect to the register component.
  signal s_iCLK, s_iRST, s_iWE  : std_logic;
  signal s_iD, s_oQ : std_logic_vector(N-1 downto 0);

begin

  DUT: reg_N 
  port map(i_CLK => s_iCLK, 
           i_RST => s_iRST,
           i_WE  => s_iWE,
           i_D   => s_iD,
           o_Q   => s_oQ);

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
	
    -- Reset the register
    s_iRST <= '1';
    s_iWE  <= '0';
    s_iD   <= X"00000000";
    wait for cCLK_PER;
    -- EXPECT: o_Q = 0x00000000

    -- Store '0x10101010'
    s_iRST <= '0';
    s_iWE  <= '1';
    s_iD   <= X"10101010";
    wait for cCLK_PER;
    -- EXPECT: o_Q = 0x10101010

    -- Keep '0x10101010'
    s_iRST <= '0';
    s_iWE  <= '0';
    s_iD   <= X"00000000"; -- Should not matter
    wait for cCLK_PER;
    -- EXPECT: o_Q = 0x10101010

    -- Store '0x01010101'
    s_iRST <= '0';
    s_iWE  <= '1';
    s_iD   <= X"01010101";
    wait for cCLK_PER;
    -- EXPECT: o_Q = 0x01010101

    -- Keep '0x01010101'
    s_iRST <= '0';
    s_iWE  <= '0';
    s_iD   <= X"11111111"; -- Should not affect output
    wait for cCLK_PER;
    -- EXPECT: o_Q = 0x01010101
	
	-- Reset the register
    s_iRST <= '1';
    s_iWE  <= '0';
    s_iD   <= X"00000000";
    wait for cCLK_PER;
    -- EXPECT: o_Q = 0x00000000

    wait;
  end process;
  
end behavior;
