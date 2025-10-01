-------------------------------------------------------------------------
-- Connor Moroney
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_extender.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- extender (both zero and sign extension) (12 to 32 bit extension)
--
--
-- NOTES:
-- 09/22/25 by CWM::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_extender is
  generic(gCLK_HPER   : time := 50 ns);
end tb_extender;

architecture behavior of tb_extender is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component extender
    port (i_in  : in  std_logic_vector(11 downto 0);   -- 12-bit input
          i_sel : in  std_logic;                       -- '1' = sign-extend, '0' = zero-extend
          o_out : out std_logic_vector(31 downto 0));  -- 32-bit output
  end component;

  -- Temporary signals to connect to the dff component.
  signal s_iin   : std_logic_vector(11 downto 0);
  signal s_isel : std_logic;
  signal s_oout : std_logic_vector(31 downto 0);

begin

  DUT: extender 
  port map(i_in   => s_iin, 
           i_sel  => s_isel,
           o_out  => s_oout);
  
  -- Testbench process  
  P_TB: process
  begin
  
    -- Test 1: Zero Extension
    s_iin   <= "111111111111";
    s_isel  <= '0';
    wait for cCLK_PER; 
	-- EXPECT: o_out to be 0x00000FFF
	
	-- Test 2: Sign Extension (With MSB = 1)
    s_iin   <= "111111111111";
    s_isel  <= '1';
    wait for cCLK_PER; 
	-- EXPECT: o_out to be 0xFFFFFFFF
	
	-- Test 3: Sign Extension (With MSB = 0)
    s_iin   <= "011111111111";
    s_isel  <= '1';
    wait for cCLK_PER; 
	-- EXPECT: o_out to be 0x000007FF

    wait;
  end process;
  
end behavior;
